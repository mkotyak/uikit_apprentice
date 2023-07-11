import UIKit

class ViewController: UIViewController {
    @IBOutlet private var slider: UISlider!
    @IBOutlet private var targetLable: UILabel!

    private var currentValue: Int = 0
    private var targetValue: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        startNewRound()
    }

    @IBAction private func showAlert() {
        let message = "The value of the slider is: \(currentValue)" + "\nThe targer value is: \(targetValue)"

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

        startNewRound()
    }

    @IBAction private func sliderMoved(_ slider: UISlider) {
        currentValue = lroundf(slider.value)
    }

    private func startNewRound() {
        targetValue = Int.random(in: 0 ... 100)
        currentValue = 50
        slider.value = Float(currentValue)

        updateLabels()
    }

    private func updateLabels() {
        targetLable.text = String(targetValue)
    }
}
