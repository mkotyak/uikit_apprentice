import UIKit

class AllListsViewController: UITableViewController {
    private enum Constants {
        static var cellIdentifier: String { "ChecklistCell" }
    }

    private var lists: [Checklist] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Constants.cellIdentifier
        )

        lists = [
            .init(name: "Birthdays"),
            .init(name: "Groceries"),
            .init(name: "Cool Apps"),
            .init(name: "To Do")
        ]
    }
}

// MARK: - Table view data source

extension AllListsViewController {
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return lists.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.cellIdentifier,
            for: indexPath
        )

        cell.textLabel?.text = lists[indexPath.row].name
        cell.accessoryType = .detailDisclosureButton

        return cell
    }
}

// MARK: - Table view delegates

extension AllListsViewController {
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        performSegue(
            withIdentifier: "ShowChecklist",
            sender: nibName
        )
    }
}
