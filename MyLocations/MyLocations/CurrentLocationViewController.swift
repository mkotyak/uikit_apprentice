import CoreLocation
import UIKit

class CurrentLocationViewController: UIViewController {
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!

    @IBOutlet var tagButton: UIButton!
    @IBOutlet var getButton: UIButton!

    private let locationManager = CLLocationManager()
    private var location: CLLocation?
    private var isUpdatingLocation: Bool = false
    private var lastLocationError: Error?

    private let geocoder = CLGeocoder()
    private var placemark: CLPlacemark?
    private var isPerformingReverseGeocoding = false
    private var lastGeocodingError: Error?

    private var retrieveLocationTimeoutTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
    }

    private func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(
                format: "%.8f",
                location.coordinate.latitude
            )
            longitudeLabel.text = String(
                format: "%.8f",
                location.coordinate.longitude
            )
            tagButton.isHidden = false
            messageLabel.text = ""

            if let placemark = placemark {
                addressLabel.text = string(from: placemark)
            } else if isPerformingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true

            let statusMessage: String
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if locationManager.authorizationStatus == .denied {
                statusMessage = "Location Services Disabled"
            } else if isUpdatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location' to Start"
            }
            messageLabel.text = statusMessage
        }

        configureGetButton()
    }

    private func configureGetButton() {
        if isUpdatingLocation {
            getButton.setTitle("Stop", for: .normal)
        } else {
            getButton.setTitle("Get My Location", for: .normal)
        }
    }

    private func startLocationManager() {
        guard locationManager.authorizationStatus != .denied else {
            return
        }

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        isUpdatingLocation = true

        retrieveLocationTimeoutTimer = Timer.scheduledTimer(
            withTimeInterval: 60,
            repeats: false,
            block: { [weak self] _ in
                guard let self else {
                    return
                }

                debugPrint("*** Time out")
                if location == nil {
                    stopLocationManager()
                    lastLocationError = NSError(
                        domain: "MyLocationsErrorDomain",
                        code: 1,
                        userInfo: nil
                    )
                    updateLabels()
                }
            }
        )
    }

    private func stopLocationManager() {
        guard isUpdatingLocation else {
            return
        }

        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        isUpdatingLocation = false

        retrieveLocationTimeoutTimer?.invalidate()
    }

    private func string(from placemark: CLPlacemark) -> String {
        // 1
        var line1 = ""
        // 2
        if let tmp = placemark.subThoroughfare {
            line1 += tmp + " "
        }
        // 3
        if let tmp = placemark.thoroughfare {
            line1 += tmp
        }
        // 4
        var line2 = ""
        if let tmp = placemark.locality {
            line2 += tmp + " "
        }
        if let tmp = placemark.administrativeArea {
            line2 += tmp + " "
        }
        if let tmp = placemark.postalCode {
            line2 += tmp
        }
        // 5
        return line1 + "\n" + line2
    }
}

// MARK: - Actions

extension CurrentLocationViewController {
    @IBAction func getLocation() {
        let authStatus = locationManager.authorizationStatus

        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }

        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            updateLabels()
            return
        }

        if isUpdatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil

            startLocationManager()
        }

        updateLabels()
    }
}

// MARK: - CLLocationManagerDelegate

extension CurrentLocationViewController: CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        debugPrint("didFailWithError \(error.localizedDescription)")

        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }

        lastLocationError = error
        stopLocationManager()
        updateLabels()
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let newLocation = locations.last else {
            return
        }

        print("didUpdateLocations \(newLocation)")

        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }

        if newLocation.horizontalAccuracy < 0 {
            return
        }

        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location {
            distance = newLocation.distance(from: location)
        }

        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation

            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** We're done!")
                stopLocationManager()

                if distance > 0 {
                    isPerformingReverseGeocoding = false
                }
            }

            if !isPerformingReverseGeocoding {
                print("*** Going to geocode")

                isPerformingReverseGeocoding = true

                geocoder.reverseGeocodeLocation(newLocation) { placemarks, error in
                    self.lastGeocodingError = error
                    if error == nil, let places = placemarks, !places.isEmpty {
                        self.placemark = places.last!
                    } else {
                        self.placemark = nil
                    }

                    self.isPerformingReverseGeocoding = false
                    self.updateLabels()
                }
            }

            updateLabels()
        } else if distance < 1 {
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            if timeInterval > 10 {
                print("*** Force done!")
                stopLocationManager()
                updateLabels()
            }
        }
    }
}

// MARK: - Helper Methods

extension CurrentLocationViewController {
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services for this app in Settings.",
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil
        )
        alert.addAction(okAction)

        present(
            alert,
            animated: true,
            completion: nil
        )
    }
}
