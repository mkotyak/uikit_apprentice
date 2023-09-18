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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

// MARK: - Actions

extension CurrentLocationViewController {
    @IBAction func getLocation() {
        let authStatus = locationManager.authorizationStatus

        guard authStatus != .notDetermined else {
            locationManager.requestWhenInUseAuthorization()
            return
        }

        guard authStatus != .denied || authStatus != .restricted else {
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
        showLocationServicesDeniedAlert()
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        let newLocation = locations.last
        debugPrint("didUpdateLocations \(newLocation)")
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
