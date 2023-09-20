import CoreLocation
import UIKit

class LocationDetailsViewController: UITableViewController {
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!

    var coordinate = CLLocationCoordinate2D(
        latitude: 0,
        longitude: 0
    )
    var placemark: CLPlacemark?

    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        descriptionTextView.text = ""
        categoryLabel.text = ""

        latitudeLabel.text = String(
            format: "%.8f",
            coordinate.latitude
        )
        longitudeLabel.text = String(
            format: "%.8f",
            coordinate.longitude
        )

        if let placemark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }

        dateLabel.text = format(date: Date())
    }
}

// MARK: - Actions

extension LocationDetailsViewController {
    @IBAction func done() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Helper Methods

extension LocationDetailsViewController {
    func string(from placemark: CLPlacemark) -> String {
        var text = ""
        if let tmp = placemark.subThoroughfare {
            text += tmp + " "
        }
        if let tmp = placemark.thoroughfare {
            text += tmp + ", "
        }
        if let tmp = placemark.locality {
            text += tmp + ", "
        }
        if let tmp = placemark.administrativeArea {
            text += tmp + " "
        }
        if let tmp = placemark.postalCode {
            text += tmp + ", "
        }
        if let tmp = placemark.country {
            text += tmp
        }
        return text
    }

    func format(date: Date) -> String {
        dateFormatter.string(from: date)
    }
}
