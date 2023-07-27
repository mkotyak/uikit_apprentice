import Foundation

class Checklist: Codable {
    var name: String
    var iconName: String
    var items: [ChecklistItem]

    var uncheckedItems: Int {
        items.filter { !$0.isChecked }.count
    }

    init(
        name: String,
        iconName: String = "No Icon",
        items: [ChecklistItem]
    ) {
        self.name = name
        self.iconName = iconName
        self.items = items
    }

    func sortItems() {
        items.sort { item1, item2 in
            item1.dueDate < item2.dueDate
        }
    }
}

extension Checklist: Equatable {
    static func == (lhs: Checklist, rhs: Checklist) -> Bool {
        lhs.name == rhs.name && lhs.items == rhs.items
    }
}
