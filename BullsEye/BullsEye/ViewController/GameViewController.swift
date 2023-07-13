import UIKit

class GameViewController: UIViewController {
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

    private var roundPoints: Int {
        (100 - difference) + bonusRoundPoints
    }

    private var bonusRoundPoints: Int {
        switch difference {
        case 0:
            return 100
        case 1:
            return 50
        default:
            return 0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSlider()
        startNewGame()
    }

    @IBAction private func showAlert() {
        let title: String
        if difference == 0 {
            title = "Perfect!"
        } else if difference < 5 {
            title = "You almost had it!"
        } else if difference < 10 {
            title = "Pretty good!"
        } else {
            title = "Not even close..."
        }

        let message = "You scored \(roundPoints) points"

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        let action = UIAlertAction(
            title: "OK",
            style: .default
        ) { [weak self] _ in
            guard let self else {
                return
            }

            self.incrementTotalScore(by: self.roundPoints)
            self.startNewRound()
        }

        alert.addAction(action)
        present(alert, animated: true)
    }

    @IBAction private func sliderMoved(_ slider: UISlider) {
        currentValue = lroundf(slider.value)
    }

    @IBAction private func startNewGame() {
        totalScore = 0
        round = 0
        startNewRound()

        let transition = CATransition()
        transition.type = CATransitionType.fade
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        view.layer.add(transition, forKey: nil)
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

    private func setupSlider() {
        let thumbImageNormal = UIImage(named: "SliderThumb-Normal")!
        slider.setThumbImage(thumbImageNormal, for: .normal)

        let thumbImageHighlighted = UIImage(named: "SliderThumb-Highlighted")!
        slider.setThumbImage(thumbImageHighlighted, for: .highlighted)

        let insets = UIEdgeInsets(
            top: 0,
            left: 14,
            bottom: 0,
            right: 14
        )

        let trackLeftImage = UIImage(named: "SliderTrackLeft")!
        let trackLeftResizable = trackLeftImage.resizableImage(withCapInsets: insets)
        slider.setMinimumTrackImage(trackLeftResizable, for: .normal)

        let trackRightImage = UIImage(named: "SliderTrackRight")!
        let trackRightResizable = trackRightImage.resizableImage(withCapInsets: insets)
        slider.setMaximumTrackImage(trackRightResizable, for: .normal)
    }
}
