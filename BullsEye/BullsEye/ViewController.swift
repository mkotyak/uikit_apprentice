import UIKit

class ViewController: UIViewController {
    @IBOutlet private var slider: UISlider!
    @IBOutlet private var targetLable: UILabel!
    @IBOutlet private var scoreLable: UILabel!
    @IBOutlet private var roundLable: UILabel!

    private var currentValue: Int = 0
    private var targetValue: Int = 0
    private var totalScore: Int = 0
    private var round: Int = 0

    private var difference: Int {
        abs(targetValue - currentValue)
    }

    private var points: Int {
        100 - difference
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        startNewRound()
    }

    @IBAction private func showAlert() {
        let message = "You scored \(points) points"
        incrementTotalScore(by: points)

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
        incrementRound()

        targetValue = Int.random(in: 0 ... 100)
        currentValue = 50
        slider.value = Float(currentValue)

        updateLabels()
    }

    private func updateLabels() {
        targetLable.text = String(targetValue)
        scoreLable.text = String(totalScore)
        roundLable.text = String(round)
    }

    private func incrementTotalScore(by score: Int) {
        totalScore += score
    }

    private func incrementRound() {
        round += 1
    }
}
