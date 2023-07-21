import Foundation
import UIKit

class ChecklistViewController: UITableViewController {
    private var items: [ChecklistItem] = []

    private var documentsDirectoryURL: URL? {
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first
    }

    private var dataURL: URL? {
        guard let documentsDirectoryURL else {
            return nil
        }

        return documentsDirectoryURL.appendingPathComponent("Checklists.plist")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true

        loadChecklistItems()
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

    private func saveChecklistItems() {
        guard let dataURL else {
            return
        }

        let encoder: PropertyListEncoder = .init()

        do {
            let data = try encoder.encode(items)

            try data.write(
                to: dataURL,
                options: Data.WritingOptions.atomic
            )
        } catch {
            debugPrint("Error encoding item array: \(error.localizedDescription)")
        }
    }

    private func loadChecklistItems() {
        guard let dataURL else {
            return
        }

        let decoder: PropertyListDecoder = .init()

        do {
            items = try decoder.decode(
                [ChecklistItem].self,
                from: Data(contentsOf: dataURL)
            )
        } catch {
            debugPrint("Error decoding item array: \(error.localizedDescription)")
        }
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
            saveChecklistItems()

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
        saveChecklistItems()

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
                controller.itemToEdit = items[indexPath.row]
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
        saveChecklistItems()

        navigationController?.popViewController(animated: true)
    }

    func checklistItemDetailViewController(
        _ controller: ChecklistItemDetailViewController,
        didFinishEditing item: ChecklistItem
    ) {
        if let index = items.firstIndex(of: item) {
            let indexPath = IndexPath(row: index, section: 0)

            if let cell = tableView.cellForRow(at: indexPath) {
                configureText(for: cell, with: item)
            }

            saveChecklistItems()
        }

        navigationController?.popViewController(animated: true)
    }
}
