import Foundation

extension String {
    mutating func add(
        text: String?,
        separatedBy separator: String = ""
    ) {
        guard let text else {
            return
        }

        if !isEmpty {
            self += separator
        }

        self += text
    }
}
