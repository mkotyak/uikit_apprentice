import UIKit

class ChecklistItemCreatorViewController: UITableViewController {
    @IBOutlet private var doneBarButton: UIBarButtonItem!
    @IBOutlet private var textField: UITextField!

    var itemToEdit: ChecklistItem?
    weak var delegate: ChecklistItemCreatorDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never

        if let itemToEdit {
            title = "Edit Item"
            textField.text = itemToEdit.text
            doneBarButton.isEnabled = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
}

// MARK: - Actions

extension ChecklistItemCreatorViewController {
    @IBAction private func cancel() {
        delegate?.checklistItemCreatorViewControllerDidCancel(self)
    }

    @IBAction private func done() {
        if let itemToEdit {
            itemToEdit.text = textField.text ?? ""
            delegate?.addItemViewController(
                self,
                didFinishEditing: itemToEdit
            )
        } else {
            let item: ChecklistItem = .init(text: textField.text ?? "")

            delegate?.checklistItemCreatorViewController(
                self,
                didFinishCreation: item
            )
        }
    }
}

// MARK: - Table view Delegate

extension ChecklistItemCreatorViewController {
    override func tableView(
        _ tableView: UITableView,
        willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
        return nil
    }
}

// MARK: - Text field delegate

extension ChecklistItemCreatorViewController: UITextFieldDelegate {
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
