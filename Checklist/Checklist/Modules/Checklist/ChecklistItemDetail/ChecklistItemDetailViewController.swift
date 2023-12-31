import UIKit

class ChecklistItemDetailViewController: UITableViewController {
    @IBOutlet private var doneBarButton: UIBarButtonItem!
    @IBOutlet private var textField: UITextField!
    @IBOutlet var shouldRemindSwitch: UISwitch!
    @IBOutlet var datePicker: UIDatePicker!

    var itemToEdit: ChecklistItem?
    weak var delegate: ChecklistItemDetailDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never

        if let itemToEdit {
            title = "Edit Item"
            textField.text = itemToEdit.text
            doneBarButton.isEnabled = true
            shouldRemindSwitch.isOn = itemToEdit.shouldRemind
            datePicker.date = itemToEdit.dueDate
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
}

// MARK: - Actions

extension ChecklistItemDetailViewController {
    @IBAction private func cancel() {
        delegate?.checklistItemDetailViewControllerDidCancel(self)
    }

    @IBAction private func done() {
        if let itemToEdit {
            itemToEdit.text = textField.text ?? ""
            itemToEdit.dueDate = datePicker.date
            itemToEdit.shouldRemind = shouldRemindSwitch.isOn

            itemToEdit.scheduleNotification()

            delegate?.checklistItemDetailViewController(
                self,
                didFinishEditing: itemToEdit
            )
        } else {
            let item: ChecklistItem = .init(
                text: textField.text ?? "",
                dueDate: datePicker.date,
                shouldRemind: shouldRemindSwitch.isOn
            )

            item.scheduleNotification()

            delegate?.checklistItemDetailViewController(
                self,
                didFinishCreation: item
            )
        }
    }

    @IBAction func shouldRemindToggled(_ switchControl: UISwitch) {
        textField.resignFirstResponder()

        guard switchControl.isOn else {
            return
        }

        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in
        }
    }
}

// MARK: - Table view Delegate

extension ChecklistItemDetailViewController {
    override func tableView(
        _ tableView: UITableView,
        willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
        return nil
    }
}

// MARK: - Text field delegate

extension ChecklistItemDetailViewController: UITextFieldDelegate {
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
