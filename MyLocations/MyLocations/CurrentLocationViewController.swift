import UIKit

class CurrentLocationViewController: UIViewController {
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!

    @IBOutlet var tagButton: UIButton!
    @IBOutlet var getButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

// MARK: - Actions

extension CurrentLocationViewController {
    @IBAction func getLocation() {}
}
