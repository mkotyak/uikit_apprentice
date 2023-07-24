import Foundation

class Checklist: Codable {
    var name: String
    var items: [ChecklistItem]

    init(
        name: String,
        items: [ChecklistItem]
    ) {
        self.name = name
        self.items = items
    }
}

extension Checklist: Equatable {
    static func == (lhs: Checklist, rhs: Checklist) -> Bool {
        lhs.name == rhs.name && lhs.items == rhs.items
    }
}
