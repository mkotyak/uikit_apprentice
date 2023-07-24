import UIKit

class AllListsViewController: UITableViewController {
    private enum Constants {
        static var cellIdentifier: String { "ChecklistCell" }
        static var segueShowChecklistIdentifier: String { "ShowChecklist" }
        static var segueAddChecklistIdentifier: String { "AddChecklist" }
    }

    var dataModel: DataModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Constants.cellIdentifier
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        navigationController?.delegate = self

        let index = dataModel.indexOfSelectedChecklist
        guard
            index >= 0,
            index < dataModel.lists.count
        else {
            return
        }

        performSegue(
            withIdentifier: Constants.segueShowChecklistIdentifier,
            sender: dataModel.lists[index]
        )
    }
}

// MARK: - Table view data source

extension AllListsViewController {
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return dataModel.lists.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.cellIdentifier,
            for: indexPath
        )

        cell.textLabel?.text = dataModel.lists[indexPath.row].name
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
            withIdentifier: Constants.segueShowChecklistIdentifier,
            sender: dataModel.lists[indexPath.row]
        )

        dataModel.indexOfSelectedChecklist = indexPath.row
    }

    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        dataModel.lists.remove(at: indexPath.row)
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
        controller.checklistToEdit = dataModel.lists[indexPath.row]

        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - Navigation

extension AllListsViewController {
    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {
        if segue.identifier == Constants.segueShowChecklistIdentifier {
            let controller = segue.destination as! ChecklistViewController
            controller.checklist = sender as? Checklist
        } else if segue.identifier == Constants.segueAddChecklistIdentifier {
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
        let newRowIndex = dataModel.lists.count
        dataModel.lists.append(checklist)

        let indexPath: IndexPath = .init(row: newRowIndex, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)

        navigationController?.popViewController(animated: true)
    }

    func allListsDetailViewController(
        _ controller: AllListsDetailViewController,
        didFinishEditing checklist: Checklist
    ) {
        if let index = dataModel.lists.firstIndex(of: checklist) {
            let indexPath = IndexPath(row: index, section: 0)

            if let cell = tableView.cellForRow(at: indexPath) {
                cell.textLabel?.text = checklist.name
            }
        }

        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Navigation Controller Delegate

extension AllListsViewController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        if viewController == self {
            dataModel.indexOfSelectedChecklist = -1
        }
    }
}
