import UIKit

class AddItemViewController: UITableViewController {
    @IBOutlet var doneBarButton: UIBarButtonItem!
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

// MARK: - Text field delegate

extension AddItemViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard
            let oldText = textField.text,
            let stringRange = Range(range, in: oldText)
        else {
            doneBarButton.isEnabled = false

            return false
        }

        let newText = oldText.replacingCharacters(
            in: stringRange,
            with: string
        )

        doneBarButton.isEnabled = !newText.isEmpty

        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        doneBarButton.isEnabled = false
        return true
    }
}
