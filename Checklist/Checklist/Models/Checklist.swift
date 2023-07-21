import Foundation

class Checklist {
    var name: String

    init(name: String) {
        self.name = name
    }
}

extension Checklist: Equatable {
    static func == (lhs: Checklist, rhs: Checklist) -> Bool {
        lhs.name == rhs.name
    }
}
