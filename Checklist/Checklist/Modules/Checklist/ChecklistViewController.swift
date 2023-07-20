import UIKit

class ChecklistViewController: UITableViewController {
    private var items: [ChecklistItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true

        items = [
            .init(text: "Walk the dog"),
            .init(text: "Brush my teeth"),
            .init(text: "Learn iOS development"),
            .init(text: "Soccer practice"),
            .init(text: "Eat ice cream")
        ]
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
        let newRawIndex = items.count
        let indexPath: IndexPath = .init(row: newRawIndex, section: 0)

        items.append(item)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - Table view Data Source

extension ChecklistViewController {
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return items.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ChecklistItem",
            for: indexPath
        )

        let item = items[indexPath.row]

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
            let item = items[indexPath.row]

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
        items.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - Navigation

extension ChecklistViewController {
    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {
        if segue.identifier == "ChecklistItemCreator" {
            let controller = segue.destination as! ChecklistItemCreatorViewController
            controller.delegate = self
        } else if segue.identifier == "ChecklistItemEditor" {
            let controller = segue.destination as! ChecklistItemCreatorViewController
            controller.delegate = self

            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.itemToEdit = items[indexPath.row]
            }
        }
    }
}

// MARK: - ChecklistItemCreatorDelegate

extension ChecklistViewController: ChecklistItemCreatorDelegate {
    func checklistItemCreatorViewControllerDidCancel(_ controller: ChecklistItemCreatorViewController) {
        navigationController?.popViewController(animated: true)
    }

    func checklistItemCreatorViewController(
        _ controller: ChecklistItemCreatorViewController,
        didFinishCreation item: ChecklistItem
    ) {
        addNewItem(item)
        navigationController?.popViewController(animated: true)
    }
}
