import Foundation

protocol AllListsDetailViewControllerDelegate: AnyObject {
    func allListsDetailViewControllerDidCancel(_ controller: AllListsDetailViewController)

    func allListsDetailViewController(
        _ controller: AllListsDetailViewController,
        didFinishAdding checklist: Checklist
    )

    func allListsDetailViewController(
        _ controller: AllListsDetailViewController,
        didFinishEditing checklist: Checklist
    )
}
