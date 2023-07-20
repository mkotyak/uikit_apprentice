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

extension ChecklistItem: Equatable {
    static func == (lhs: ChecklistItem, rhs: ChecklistItem) -> Bool {
        lhs.text == rhs.text && rhs.isChecked == lhs.isChecked
    }
}
