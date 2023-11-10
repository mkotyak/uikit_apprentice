import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var popupView: UIView!
    @IBOutlet var artworkImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var kindLabel: UILabel!
    @IBOutlet var genreLabel: UILabel!
    @IBOutlet var priceButton: UIButton!

    var searchResult: SearchResult!

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

        if searchResult != nil {
            updateUI()
        }
    }
}

// MARK: - Actions

extension DetailViewController {
    @IBAction func close() {
        dismiss(animated: true)
    }

    @IBAction func openInStore() {
        guard let url = URL(string: searchResult.storeURL) else {
            return
        }

        UIApplication.shared.open(url)
    }
}

// MARK: - Helper Method

extension DetailViewController {
    private func updateUI() {
        nameLabel.text = searchResult.name

        if searchResult.artist.isEmpty {
            artistNameLabel.text = "Unknown"
        } else {
            artistNameLabel.text = searchResult.artist
        }

        kindLabel.text = searchResult.type
        genreLabel.text = searchResult.genre

        // Show price
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = searchResult.currency

        let priceText: String
        if searchResult.price == 0 {
            priceText = "Free"
        } else if let text = formatter.string(from: searchResult.price as NSNumber) {
            priceText = text
        } else {
            priceText = ""
        }

        priceButton.setTitle(priceText, for: .normal)
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
