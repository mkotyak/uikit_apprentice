import UIKit

class ChecklistViewController: UITableViewController {
    private var items: [CheckListItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        at indexPath: IndexPath
    ) {
        cell.accessoryType = items[indexPath.row].isChecked ? .checkmark : .none
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
        
        let label = cell.viewWithTag(1000) as! UILabel
        label.text = items[indexPath.row].text
    
        configureCheckmark(for: cell, at: indexPath)
        
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
            items[indexPath.row].isChecked.toggle()
            configureCheckmark(for: cell, at: indexPath)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
