import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func showAlert() {
        let alert = UIAlertController(
            title: "Hello, World",
            message: "This is my first app!",
            preferredStyle: .alert
        )

        let action = UIAlertAction(
            title: "Awesom",
            style: .default
        )

        alert.addAction(action)
        present(
            alert,
            animated: true,
            completion: nil
        )
    }
}
