import CoreData
import CoreLocation
import UIKit

class LocationsViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!
}

// MARK: - Table View Delegate

extension LocationsViewController {
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        1
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "LocationCell",
            for: indexPath
        )

        let descriptionLabel = cell.viewWithTag(100) as! UILabel
        descriptionLabel.text = "If you can see this"

        let address = cell.viewWithTag(101) as! UILabel
        address.text = "Then it works"

        return cell
    }
}
