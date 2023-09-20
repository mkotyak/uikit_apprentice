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

    var categoryName = "No Category"

    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        descriptionTextView.text = ""
        categoryLabel.text = categoryName

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

        // Hide keyboard
        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(hideKeyboard)
        )

        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }

    @objc private func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)

        if indexPath != nil
            && indexPath!.section == 0
            && indexPath!.row == 0
        {
            return
        }

        descriptionTextView.resignFirstResponder()
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

    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
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

// MARK: Navigation

extension LocationDetailsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
}

// MARK: - Table View Delegates

extension LocationDetailsViewController {
    override func tableView(
        _ tableView: UITableView,
        willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
        indexPath.section == 0 || indexPath.section == 1 ? indexPath : nil
    }

    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        guard indexPath.section == 0 && indexPath.row == 0 else {
            return
        }

        descriptionTextView.becomeFirstResponder()
    }
}
