import UIKit

class AllListsDetailViewController: UITableViewController {
    @IBOutlet var textField: UITextField!
    @IBOutlet var doneBarButton: UIBarButtonItem!

    weak var delegate: AllListsDetailViewControllerDelegate?

    var checklistToEdit: Checklist?

    override func viewDidLoad() {
        if let checklistToEdit {
            title = "Edit Checklist"
            textField.text = checklistToEdit.name
            doneBarButton.isEnabled = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
}

// MARK: - Actions

extension AllListsDetailViewController {
    @IBAction func cancel() {
        delegate?.allListsDetailViewControllerDidCancel(self)
    }

    @IBAction func done() {
        if let checklistToEdit {
            checklistToEdit.name = textField.text ?? ""
            delegate?.allListsDetailViewController(
                self,
                didFinishEditing: checklistToEdit
            )
        } else {
            let checklist = Checklist(
                name: textField.text ?? "",
                items: []
            )
            
            delegate?.allListsDetailViewController(
                self,
                didFinishAdding: checklist
            )
        }
    }
}

// MARK: - Text Field Delegates

extension AllListsDetailViewController: UITextFieldDelegate {
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

// MARK: - Table View Delegates

extension AllListsDetailViewController {
    override func tableView(
        _ tableView: UITableView,
        willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
        return nil
    }
}
