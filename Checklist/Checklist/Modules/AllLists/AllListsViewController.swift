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
            sender: lists[indexPath.row]
        )
    }

    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        lists.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    override func tableView(
        _ tableView: UITableView,
        accessoryButtonTappedForRowWith indexPath: IndexPath
    ) {
        let controller = storyboard?.instantiateViewController(
            withIdentifier: "AllListsDetailViewController"
        ) as! AllListsDetailViewController

        controller.delegate = self
        controller.checklistToEdit = lists[indexPath.row]

        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - Navigation

extension AllListsViewController {
    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {
        if segue.identifier == "ShowChecklist" {
            let controller = segue.destination as! ChecklistViewController
            controller.checklist = sender as? Checklist
        } else if segue.identifier == "AddChecklist" {
            let controller = segue.destination as! AllListsDetailViewController
            controller.delegate = self
        }
    }
}

// MARK: - AllListsDetailViewControllerDelegate

extension AllListsViewController: AllListsDetailViewControllerDelegate {
    func allListsDetailViewControllerDidCancel(_ controller: AllListsDetailViewController) {
        navigationController?.popViewController(animated: true)
    }

    func allListsDetailViewController(
        _ controller: AllListsDetailViewController,
        didFinishAdding checklist: Checklist
    ) {
        let newRowIndex = lists.count
        lists.append(checklist)

        let indexPath: IndexPath = .init(row: newRowIndex, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)

        navigationController?.popViewController(animated: true)
    }

    func allListsDetailViewController(
        _ controller: AllListsDetailViewController,
        didFinishEditing checklist: Checklist
    ) {
        if let index = lists.firstIndex(of: checklist) {
            let indexPath = IndexPath(row: index, section: 0)

            if let cell = tableView.cellForRow(at: indexPath) {
                cell.textLabel?.text = checklist.name
            }
        }

        navigationController?.popViewController(animated: true)
    }
}
