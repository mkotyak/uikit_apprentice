import UIKit

class AddItemViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
    }
}

// MARK: - Actions

extension AddItemViewController {
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func done() {
        navigationController?.popViewController(animated: true)
    }
}
