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
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            messageLabel.text = "Tap 'Get My Location' to Start"
        }
    }

    private func stopLocationManager() {}
}

// MARK: - Actions

extension CurrentLocationViewController {
    @IBAction func getLocation() {
        let authStatus = locationManager.authorizationStatus

        guard authStatus != .notDetermined else {
            locationManager.requestWhenInUseAuthorization()
            return
        }

        guard authStatus == .authorizedAlways || authStatus == .authorizedAlways else {
            showLocationServicesDeniedAlert()
            return
        }

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
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
        location = locations.last
        updateLabels()
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
            style: .default
        )

        alert.addAction(okAction)

        present(alert, animated: true)
    }
}
