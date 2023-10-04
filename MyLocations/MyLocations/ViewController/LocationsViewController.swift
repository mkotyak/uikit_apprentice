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
        ) as! LocationCell

        let location = locations[indexPath.row]
        cell.configure(for: location)

        return cell
    }
}

// MARK: - Navigation

extension LocationsViewController {
    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {
        if segue.identifier == "EditLocation" {
            let controller = segue.destination as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.locationToEdit = locations[indexPath.row]
            }
        }
    }
}
