import CoreData
import CoreLocation
import UIKit

class CurrentLocationViewController: UIViewController {
    var managedObjectContext: NSManagedObjectContext!

    @IBOutlet var containerView: UIView!

    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var latitudeTextLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var longitudeTextLabel: UILabel!
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

    private var isLogoVisible: Bool = false

    private lazy var logoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(
            .init(named: "Logo"),
            for: .normal
        )
        button.sizeToFit()
        button.addTarget(
            self,
            action: #selector(getLocation),
            for: .touchUpInside
        )
        button.center.x = self.view.bounds.midX
        button.center.y = 220

        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
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
            latitudeTextLabel.isHidden = false
            longitudeTextLabel.isHidden = false
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
            latitudeTextLabel.isHidden = true
            longitudeTextLabel.isHidden = true
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
                statusMessage = ""
                showLogoView()
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
        var line1 = ""
        line1.add(text: placemark.subThoroughfare)
        line1.add(text: placemark.thoroughfare, separatedBy: " ")

        var line2 = ""
        line2.add(text: placemark.locality)
        line2.add(text: placemark.administrativeArea, separatedBy: " ")
        line2.add(text: placemark.postalCode, separatedBy: " ")

        line1.add(text: line2, separatedBy: "\n")

        return line1
    }

    private func showLogoView() {
        guard !isLogoVisible else {
            return
        }

        isLogoVisible = true
        containerView.isHidden = true
        view.addSubview(logoButton)
    }

    private func hideLogoView() {
        guard isLogoVisible else {
            return
        }

        isLogoVisible = false
        containerView.isHidden = false
        containerView.center.x = view.bounds.size.width * 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2

        let centerX = view.bounds.midX

        let panelMover = CABasicAnimation(keyPath: "position")
        panelMover.isRemovedOnCompletion = false
        panelMover.fillMode = CAMediaTimingFillMode.forwards
        panelMover.duration = 0.6
        panelMover.fromValue = NSValue(cgPoint: containerView.center)
        panelMover.toValue = NSValue(
            cgPoint: CGPoint(
                x: centerX,
                y: containerView.center.y
            )
        )
        panelMover.timingFunction = CAMediaTimingFunction(name: .easeOut)
        panelMover.delegate = self
        containerView.layer.add(panelMover, forKey: "panelMover")

        let logoMover = CABasicAnimation(keyPath: "position")
        logoMover.isRemovedOnCompletion = false
        logoMover.fillMode = CAMediaTimingFillMode.forwards
        logoMover.duration = 0.5
        logoMover.fromValue = NSValue(cgPoint: logoButton.center)
        logoMover.toValue = NSValue(
            cgPoint: CGPoint(
                x: -centerX,
                y: logoButton.center.y
            )
        )
        logoMover.timingFunction = CAMediaTimingFunction(name: .easeIn)
        logoButton.layer.add(logoMover, forKey: "logoMover")

        let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
        logoRotator.isRemovedOnCompletion = false
        logoRotator.fillMode = CAMediaTimingFillMode.forwards
        logoRotator.duration = 0.5
        logoRotator.fromValue = 0.0
        logoRotator.toValue = -2 * Double.pi
        logoRotator.timingFunction = CAMediaTimingFunction(name: .easeIn)
        logoButton.layer.add(logoRotator, forKey: "logoRotator")
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

        if isLogoVisible {
            hideLogoView()
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

// MARK: - Navigation

extension CurrentLocationViewController {
    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {
        if segue.identifier == "TagLocation" {
            let controller = segue.destination as! LocationDetailsViewController
            controller.coordinate = location?.coordinate ?? .init(latitude: 0, longitude: 0)
            controller.placemark = placemark
            controller.managedObjectContext = managedObjectContext
        }
    }
}

// MARK: - CAAnimationDelegate

extension CurrentLocationViewController: CAAnimationDelegate {
    func animationDidStop(
        _ anim: CAAnimation,
        finished flag: Bool
    ) {
        containerView.layer.removeAllAnimations()
        containerView.center.x = view.bounds.size.width / 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2
        logoButton.layer.removeAllAnimations()
        logoButton.removeFromSuperview()
    }
}
