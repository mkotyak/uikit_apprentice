import Foundation

protocol ChecklistItemDetailDelegate: AnyObject {
    func checklistItemDetailViewControllerDidCancel(_ controller: ChecklistItemDetailViewController)

    func checklistItemDetailViewController(
        _ controller: ChecklistItemDetailViewController,
        didFinishCreation item: ChecklistItem
    )

    func checklistItemDetailViewController(
        _ controller: ChecklistItemDetailViewController,
        didFinishEditing item: ChecklistItem
    )
}
