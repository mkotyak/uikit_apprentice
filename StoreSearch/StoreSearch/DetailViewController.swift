import UIKit

class DetailViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - Actions

extension DetailViewController {
    @IBAction func close() {
        dismiss(animated: true)
    }
}
