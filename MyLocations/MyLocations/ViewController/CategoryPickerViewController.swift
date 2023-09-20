import UIKit

class CategoryPickerViewController: UITableViewController {
    private var selectedIndexPath: IndexPath = .init()

    var selectedCategoryName = ""
    let categories: [String] = [
        "No Category",
        "Apple Store",
        "Bar",
        "Boorstore",
        "Club",
        "Grosery Store",
        "Historic Buildings",
        "House",
        "Icecream Vendor",
        "Landmark",
        "Park"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        categories.indices.forEach { categoryIndex in
            if categories[categoryIndex] == selectedCategoryName {
                selectedIndexPath = IndexPath(row: categoryIndex, section: 0)
                return
            }
        }
    }
}

// MARK: - Table View Delegates

extension CategoryPickerViewController {
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        categories.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "Cell",
            for: indexPath
        )

        let categoryName = categories[indexPath.row]
        cell.textLabel!.text = categoryName

        if categoryName == selectedCategoryName {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        guard indexPath.row != selectedIndexPath.row else {
            return
        }

        if let newCell = tableView.cellForRow(at: indexPath) {
            newCell.accessoryType = .checkmark
        }

        if let oldCell = tableView.cellForRow(at: selectedIndexPath) {
            oldCell.accessoryType = .none
        }

        selectedIndexPath = indexPath
    }
}
