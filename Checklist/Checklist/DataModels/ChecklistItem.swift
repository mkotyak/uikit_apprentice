import Foundation
import UserNotifications

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

    func scheduleNotification() {
        cancelNotification()

        guard shouldRemind,
              dueDate > Date.now
        else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Reminder:"
        content.body = text
        content.sound = .default

        let calendar: Calendar = .init(identifier: .gregorian)
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: dueDate
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: itemID.uuidString,
            content: content,
            trigger: trigger
        )

        let center = UNUserNotificationCenter.current()
        center.add(request)

        debugPrint("Scheduled: \(request) for itemID: \(itemID)")
    }

    func cancelNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [itemID.uuidString])
    }
}

extension ChecklistItem: Equatable {
    static func == (lhs: ChecklistItem, rhs: ChecklistItem) -> Bool {
        lhs.text == rhs.text && rhs.isChecked == lhs.isChecked
    }
}
