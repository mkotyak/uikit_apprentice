import UIKit

class AllListsDetailViewController: UITableViewController {
    @IBOutlet var textField: UITextField!
    @IBOutlet var doneBarButton: UIBarButtonItem!
    @IBOutlet var iconImage: UIImageView!

    var iconName: String = "Folder"

    weak var delegate: AllListsDetailViewControllerDelegate?
    var checklistToEdit: Checklist?

    override func viewDidLoad() {
        if let checklistToEdit {
            title = "Edit Checklist"
            textField.text = checklistToEdit.name
            doneBarButton.isEnabled = true

            iconName = checklistToEdit.iconName
        }

        iconImage.image = UIImage(named: iconName)
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
            checklistToEdit.iconName = iconName
            delegate?.allListsDetailViewController(
                self,
                didFinishEditing: checklistToEdit
            )
        } else {
            let checklist = Checklist(
                name: textField.text ?? "",
                iconName: iconName,
                items: []
            )

            delegate?.allListsDetailViewController(
                self,
                didFinishAdding: checklist
            )
        }
    }
}

// MARK: - Navigation

extension AllListsDetailViewController {
    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {
        if segue.identifier == "PickIcon" {
            let controller = segue.destination as! IconPickerViewController
            controller.delegate = self
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
        return indexPath.section == 1 ? indexPath : nil
    }
}

// MARK: - IconPickerViewControllerDelegate

extension AllListsDetailViewController: IconPickerViewControllerDelegate {
    func iconPicker(
        _ picker: IconPickerViewController,
        didPick iconName: String
    ) {
        self.iconName = iconName
        iconImage.image = UIImage(named: iconName)

        navigationController?.popViewController(animated: true)
    }
}
