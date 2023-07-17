import UIKit

class ChecklistViewController: UITableViewController {
    let row0text: String = "Walk the dog"
    let row1text: String = "Brush my teeth"
    let row2text: String = "Learn iOS developmentg"
    let row3text: String = "Soccer practice"
    let row4text: String = "Eat ice cream"
    
    var row0checked: Bool = false
    var row1checked: Bool = false
    var row2checked: Bool = false
    var row3checked: Bool = false
    var row4checked: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    private func configureCheckmark(
        for cell: UITableViewCell,
        at indexPath: IndexPath
    ) {
        var isChecked = false
        
        if indexPath.row == 0 {
            isChecked = row0checked
        } else if indexPath.row == 1 {
            isChecked = row1checked
        } else if indexPath.row == 2 {
            isChecked = row2checked
        } else if indexPath.row == 3 {
            isChecked = row3checked
        } else if indexPath.row == 4 {
            isChecked = row4checked
        }
        
        cell.accessoryType = isChecked ? .checkmark : .none
    }
}

// MARK: - Table view Data Source

extension ChecklistViewController {
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return 5
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
        
        if indexPath.row == 0 {
            label.text = row0text
        } else if indexPath.row == 1 {
            label.text = row1text
        } else if indexPath.row == 2 {
            label.text = row2text
        } else if indexPath.row == 3 {
            label.text = row3text
        } else if indexPath.row == 4 {
            label.text = row4text
        }
        
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
            if indexPath.row == 0 {
                row0checked.toggle()
            } else if indexPath.row == 1 {
                row1checked.toggle()
            } else if indexPath.row == 2 {
                row2checked.toggle()
            } else if indexPath.row == 3 {
                row3checked.toggle()
            } else if indexPath.row == 4 {
                row4checked.toggle()
            }
            
            configureCheckmark(for: cell, at: indexPath)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
