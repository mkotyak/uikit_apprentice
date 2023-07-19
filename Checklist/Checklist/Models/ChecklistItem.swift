import Foundation

class ChecklistItem {
    var text: String
    var isChecked: Bool = false

    init(
        text: String,
        isChecked: Bool = false
    ) {
        self.text = text
        self.isChecked = isChecked
    }
}
