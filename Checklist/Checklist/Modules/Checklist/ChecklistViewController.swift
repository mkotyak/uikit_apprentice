import Foundation
import UIKit

class ChecklistViewController: UITableViewController {
    var checklist: Checklist!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        title = checklist?.name ?? "Unknown"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        checklist.sortItems()
        tableView.reloadData()
    }

    private func configureCheckmark(
        for cell: UITableViewCell,
        with item: ChecklistItem
    ) {
        let label = cell.viewWithTag(1001) as! UILabel
        label.text = item.isChecked ? "√" : ""
    }

    private func configureText(
        for cell: UITableViewCell,
        with item: ChecklistItem
    ) {
        let label = cell.viewWithTag(1000) as! UILabel
        label.text = item.text
    }

    private func addNewItem(_ item: ChecklistItem) {
        let newRawIndex = checklist.items.count
        let indexPath: IndexPath = .init(row: newRawIndex, section: 0)

        checklist.items.append(item)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - Table view Data Source

extension ChecklistViewController {
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return checklist.items.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ChecklistItem",
            for: indexPath
        )

        let item = checklist.items[indexPath.row]

        configureText(for: cell, with: item)
        configureCheckmark(for: cell, with: item)

        return cell
    }
}

// MARK: - Table view Delegate

extension ChecklistViewController {
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let item = checklist.items[indexPath.row]

            item.isChecked.toggle()
            configureCheckmark(for: cell, with: item)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        checklist.items.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - Navigation

extension ChecklistViewController {
    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {
        if segue.identifier == "ChecklistItemDetail" {
            let controller = segue.destination as! ChecklistItemDetailViewController
            controller.delegate = self
        } else if segue.identifier == "ChecklistItemEditor" {
            let controller = segue.destination as! ChecklistItemDetailViewController
            controller.delegate = self

            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.itemToEdit = checklist.items[indexPath.row]
            }
        }
    }
}

// MARK: - ChecklistItemCreatorDelegate

extension ChecklistViewController: ChecklistItemDetailDelegate {
    func checklistItemDetailViewControllerDidCancel(_ controller: ChecklistItemDetailViewController) {
        navigationController?.popViewController(animated: true)
    }

    func checklistItemDetailViewController(
        _ controller: ChecklistItemDetailViewController,
        didFinishCreation item: ChecklistItem
    ) {
        addNewItem(item)
        navigationController?.popViewController(animated: true)
    }

    func checklistItemDetailViewController(
        _ controller: ChecklistItemDetailViewController,
        didFinishEditing item: ChecklistItem
    ) {
        if let index = checklist.items.firstIndex(of: item) {
            let indexPath = IndexPath(row: index, section: 0)

            if let cell = tableView.cellForRow(at: indexPath) {
                configureText(for: cell, with: item)
            }
        }

        navigationController?.popViewController(animated: true)
    }
}
