import CoreData
import CoreLocation
import UIKit

class LocationsViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!

    var locations: [Location] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let fetchRequest: NSFetchRequest<Location> = .init(entityName: "Location")

        let sortDescriptor: NSSortDescriptor = .init(
            key: "date",
            ascending: true
        )
        fetchRequest.sortDescriptors = [sortDescriptor]

        do {
            locations = try managedObjectContext.fetch(fetchRequest)
        } catch {
            fatalCoreDataError(error)
        }
    }
}

// MARK: - Table View Delegate

extension LocationsViewController {
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        locations.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "LocationCell",
            for: indexPath
        )
        let location = locations[indexPath.row]

        let descriptionLabel = cell.viewWithTag(100) as! UILabel
        descriptionLabel.text = location.locationDescription

        let addressLabel = cell.viewWithTag(101) as! UILabel
        if let placemark = location.placemark {
            var text = ""
            if let tmp = placemark.subThoroughfare {
                text += tmp + " "
            }
            if let tmp = placemark.thoroughfare {
                text += tmp + ", "
            }
            if let tmp = placemark.locality {
                text += tmp
            }
            addressLabel.text = text
        } else {
            addressLabel.text = ""
        }

        return cell
    }
}
