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
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        let newLocation = locations.last
        debugPrint("didUpdateLocations \(newLocation)")
    }
}
