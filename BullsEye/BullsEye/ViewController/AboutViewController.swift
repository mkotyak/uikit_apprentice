import UIKit
import WebKit

class AboutViewController: UIViewController {
    @IBOutlet private var webview: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = Bundle.main.url(
            forResource: "BullsEye",
            withExtension: "html"
        ) {
            let request = URLRequest(url: url)
            webview.load(request)
        }
    }

    @IBAction private func close() {
        dismiss(animated: true)
    }
}
