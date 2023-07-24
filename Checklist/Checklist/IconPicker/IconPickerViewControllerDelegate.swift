import Foundation

protocol IconPickerViewControllerDelegate: AnyObject {
    func iconPicker(
        _ picker: IconPickerViewController,
        didPick iconName: String
    )
}
