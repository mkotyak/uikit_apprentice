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
    }
}

// MARK: - Actions

extension DetailViewController {
    @IBAction func close() {
        dismiss(animated: true)
    }
}
