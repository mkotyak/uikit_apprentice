import UIKit

class ViewController: UIViewController {
    private var currentSliderValue: Int = 50

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func showAlert() {
        let message = "The value of the slider is: \(currentSliderValue)"

        let alert = UIAlertController(
            title: "Hello, World",
            message: message,
            preferredStyle: .alert
        )

        let action = UIAlertAction(
            title: "OK",
            style: .default
        )

        alert.addAction(action)

        present(
            alert,
            animated: true,
            completion: nil
        )
    }

    @IBAction func sliderMoved(_ slider: UISlider) {
        currentSliderValue = lroundf(slider.value)
    }
}
