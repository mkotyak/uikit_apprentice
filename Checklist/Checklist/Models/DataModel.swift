import Foundation

final class DataModel {
    private enum Constants {
        static var checklistIndexKey: String { "ChecklistIndex" }
    }

    var lists: [Checklist] = []

    init() {
        loadChecklists()
        registerDefaults()
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
        } catch {
            debugPrint("Error decoding list array: \(error.localizedDescription)")
        }
    }

    private func registerDefaults() {
        UserDefaults.standard.register(defaults: [Constants.checklistIndexKey: -1])
    }
}
