import UIKit

class LandscapeViewController: UIViewController {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!

    private var wasPrevioslyDisplayed: Bool = false
    var searchResults: [SearchResult] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true

        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true

        pageControl.removeConstraints(pageControl.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true

        view.backgroundColor = UIColor(patternImage:
            UIImage(named: "LandscapeBackground")!
        )
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        scrollView.frame = safeFrame
        pageControl.frame = .init(
            x: safeFrame.origin.x,
            y: safeFrame.size.height - pageControl.frame.size.height,
            width: safeFrame.size.width,
            height: pageControl.frame.size.height
        )

        if !wasPrevioslyDisplayed {
            wasPrevioslyDisplayed = true
            tileButtons(searchResults)
        }
    }

    private func tileButtons(_ searchResults: [SearchResult]) {
        let itemWidth: CGFloat = 94
        let itemHeight: CGFloat = 88
        var columnsPerPage = 0
        var rowsPerPage = 0
        var marginX: CGFloat = 0
        var marginY: CGFloat = 0
        let viewWidth = scrollView.bounds.size.width
        let viewHeight = scrollView.bounds.size.height

        columnsPerPage = Int(viewWidth / itemWidth)
        rowsPerPage = Int(viewHeight / itemHeight)

        marginX = (viewWidth - (CGFloat(columnsPerPage) * itemWidth)) * 0.5
        marginY = (viewHeight - (CGFloat(rowsPerPage) * itemHeight)) * 0.5

        // Button size
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorizontally = (itemWidth - buttonWidth) / 2
        let paddingVertically = (itemHeight - buttonHeight) / 2

        // Add the buttons
        var row = 0
        var column = 0
        var x = marginX

        for (index, result) in searchResults.enumerated() {
            let button = UIButton(type: .system)
            button.backgroundColor = .white
            button.setTitle("\(index)", for: .normal)
            button.frame = .init(
                x: x + paddingHorizontally,
                y: marginY + CGFloat(row) * itemHeight + paddingVertically,
                width: buttonWidth,
                height: buttonHeight
            )

            scrollView.addSubview(button)

            row += 1

            if row == rowsPerPage {
                row = 0
                x += itemWidth
                column += 1

                if column == columnsPerPage {
                    column = 0
                    x += marginX * 2
                }
            }
        }

        // Set scroll view content size
        let buttonsPerPage = columnsPerPage * rowsPerPage
        let numPages = 1 + (searchResults.count - 1) / buttonsPerPage

        scrollView.contentSize = .init(
            width: CGFloat(numPages) * viewWidth,
            height: scrollView.bounds.size.height
        )
    }
}
