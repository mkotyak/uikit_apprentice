import Foundation

protocol ChecklistItemCreatorDelegate: AnyObject {
    func checklistItemCreatorViewControllerDidCancel(_ controller: ChecklistItemCreatorViewController)

    func checklistItemCreatorViewController(
        _ controller: ChecklistItemCreatorViewController,
        didFinishCreation item: ChecklistItem
    )
}
