import Foundation

class ChecklistItem: Codable {
    var itemID: UUID = .init()
    var text: String
    var dueDate: Date
    var isChecked: Bool = false
    var shouldRemind: Bool

    init(
        text: String,
        dueDate: Date,
        isChecked: Bool = false,
        shouldRemind: Bool
    ) {
        self.text = text
        self.dueDate = dueDate
        self.isChecked = isChecked
        self.shouldRemind = shouldRemind
    }
}

extension ChecklistItem: Equatable {
    static func == (lhs: ChecklistItem, rhs: ChecklistItem) -> Bool {
        lhs.text == rhs.text && rhs.isChecked == lhs.isChecked
    }
}
