import MessageUI
import UIKit

class DetailViewController: UIViewController {
    private enum AnimationStyle {
        case slide
        case fade
    }

    @IBOutlet var popupView: UIView!
    @IBOutlet var artworkImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var kindLabel: UILabel!
    @IBOutlet var genreLabel: UILabel!
    @IBOutlet var priceButton: UIButton!

    private var dismissStyle = AnimationStyle.fade

    var isPopUp: Bool = false
    var searchResult: SearchResult! {
        didSet {
            if isViewLoaded {
                updateUI()
            }
        }
    }

    var downloadTask: URLSessionDownloadTask?

    override func viewDidLoad() {
        super.viewDidLoad()
        if isPopUp {
            popupView.layer.cornerRadius = 10
            let gestureRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(close)
            )
            gestureRecognizer.cancelsTouchesInView = false
            gestureRecognizer.delegate = self
            view.addGestureRecognizer(gestureRecognizer)

            // Gradient view
            view.backgroundColor = UIColor.clear
            let dimmingView = GradientView(frame: CGRect.zero)
            dimmingView.frame = view.bounds
            view.insertSubview(dimmingView, at: 0)
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(
                named: "LandscapeBackground")!
            )
            popupView.isHidden = true

            // Popover action button
            navigationItem.rightBarButtonItem = .init(
                barButtonSystemItem: .action,
                target: self,
                action: #selector(showPopover(_:))
            )
        }

        if searchResult != nil {
            updateUI()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        transitioningDelegate = self
    }

    deinit {
        downloadTask?.cancel()
    }

    @objc private func showPopover(_ sender: UIBarButtonItem) {
        guard let popover = storyboard?.instantiateViewController(withIdentifier: "PopoverView") as? MenuViewController else {
            return
        }

        popover.modalPresentationStyle = .popover

        if let presentationController = popover.popoverPresentationController {
            presentationController.barButtonItem = sender
        }

        popover.delegate = self

        present(popover, animated: true)
    }
}

// MARK: - Actions

extension DetailViewController {
    @IBAction func close() {
        dismissStyle = .slide
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
            artistNameLabel.text = NSLocalizedString(
                "Unknown",
                comment: "Unknown artist name label"
            )
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
            priceText = NSLocalizedString(
                "Free",
                comment: "Free search result price"
            )
        } else if let text = formatter.string(from: searchResult.price as NSNumber) {
            priceText = text
        } else {
            priceText = ""
        }

        priceButton.setTitle(priceText, for: .normal)

        // Get image
        if let largeURL = URL(string: searchResult.imageLarge) {
            downloadTask = artworkImageView.loadImage(url: largeURL)
        }

        popupView.isHidden = false
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

// MARK: - UIViewControllerTransitioningDelegate

extension DetailViewController: UIViewControllerTransitioningDelegate {
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        BounceAnimationController()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch dismissStyle {
        case .fade:
            FadeOutAnimationController()
        case .slide:
            SlideOutAnimationController()
        }
    }
}

// MARK: - MenuViewControllerDelegate

extension DetailViewController: MenuViewControllerDelegate {
    func menuViewControllerSendEmail(_ controller: MenuViewController) {
        dismiss(animated: true) { [weak self] in
            guard MFMailComposeViewController.canSendMail() else {
                return
            }

            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = self
            controller.setSubject(NSLocalizedString(
                "Support Request",
                comment: "Email subject"
            ))

            controller.setToRecipients(["testemail@gmail.com"])
            self?.present(controller, animated: true)
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension DetailViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        dismiss(animated: true)
    }
}
