import UIKit

class AddItemViewController: UITableViewController {
    @IBOutlet var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
}

// MARK: - Actions

extension AddItemViewController {
    @IBAction private func cancel() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction private func done() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Table view Delegate

extension AddItemViewController {
    override func tableView(
        _ tableView: UITableView,
        willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
        return nil
    }
}
