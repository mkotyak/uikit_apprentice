import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var popupView: UIView!
    @IBOutlet var artworkImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var kindLabel: UILabel!
    @IBOutlet var genreLabel: UILabel!
    @IBOutlet var priceButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.layer.cornerRadius = 10

        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(close)
        )

        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self

        view.addGestureRecognizer(gestureRecognizer)
    }
}

// MARK: - Actions

extension DetailViewController {
    @IBAction func close() {
        dismiss(animated: true)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        touch.view === view
    }
}
