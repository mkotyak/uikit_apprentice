import Foundation

final class DataModel {
    private enum Constants {
        static var checklistIndexKey: String { "ChecklistIndex" }
        static var firstAppSessionKey: String { "FirstAppSession" }
    }

    var lists: [Checklist] = []

    init() {
        loadChecklists()
        registerDefaults()
        handleFirstAppSession()
    }

    private var documentsDirectoryURL: URL? {
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first
    }

    private var dataURL: URL? {
        guard let documentsDirectoryURL else {
            return nil
        }

        return documentsDirectoryURL.appendingPathComponent("Checklists.plist")
    }

    var indexOfSelectedChecklist: Int {
        get {
            return UserDefaults.standard.integer(
                forKey: Constants.checklistIndexKey)
        }
        set {
            UserDefaults.standard.set(
                newValue,
                forKey: Constants.checklistIndexKey
            )
        }
    }

    func saveChecklists() {
        guard let dataURL else {
            return
        }

        let encoder: PropertyListEncoder = .init()

        do {
            let data = try encoder.encode(lists)

            try data.write(
                to: dataURL,
                options: Data.WritingOptions.atomic
            )
        } catch {
            debugPrint("Error encoding list array: \(error.localizedDescription)")
        }
    }

    func sortChecklist() {
        lists.sort { list1, list2 in
            list1.name.localizedStandardCompare(list2.name) == .orderedAscending
        }
    }

    private func loadChecklists() {
        guard let dataURL else {
            return
        }

        let decoder: PropertyListDecoder = .init()

        do {
            lists = try decoder.decode(
                [Checklist].self,
                from: Data(contentsOf: dataURL)
            )

            sortChecklist()
        } catch {
            debugPrint("Error decoding list array: \(error.localizedDescription)")
        }
    }

    private func registerDefaults() {
        let defaults: [String: Any] = [
            Constants.checklistIndexKey: -1,
            Constants.firstAppSessionKey: true
        ]

        UserDefaults.standard.register(defaults: defaults)
    }

    private func handleFirstAppSession() {
        let userDefaults = UserDefaults.standard
        let isFirstAppSession: Bool = userDefaults.bool(forKey: Constants.firstAppSessionKey)

        guard isFirstAppSession else {
            return
        }

        lists.append(.init(
            name: "List",
            items: []
        ))
        indexOfSelectedChecklist = 0
        userDefaults.set(false, forKey: Constants.firstAppSessionKey)
    }
}
