import UIKit

class LandscapeViewController: UIViewController {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!

    private var wasPrevioslyDisplayed: Bool = false
    private var downloads: [URLSessionDownloadTask] = []

    var search: Search!

    deinit {
        for task in downloads {
            task.cancel()
        }
    }

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

        pageControl.currentPage = 0
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

            switch search.state {
            case .noResults:
                showNothingFoundLabel()
            case .loading:
                showSpinner()
            case .results(let results):
                tileButtons(results)
            case .notSearchedYet:
                break
            }
        }
    }

    private func tileButtons(_ searchResults: [SearchResult]) {
        let itemWidth: CGFloat = 94
        let itemHeight: CGFloat = 88
        var columnsPerPage = 0
        var rowsPerPage = 0
        var marginX: CGFloat = 0
        var marginY: CGFloat = 0
        let viewWidth = UIScreen.main.bounds.size.width
        let viewHeight = UIScreen.main.bounds.size.height

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
            let button = UIButton(type: .custom)
            button.setBackgroundImage(
                UIImage(named: "LandscapeButton"),
                for: .normal
            )
            downloadImage(
                for: result,
                andPlaceOn: button
            )
            button.frame = CGRect(
                x: x + paddingHorizontally,
                y: marginY + CGFloat(row) * itemHeight + paddingVertically,
                width: buttonWidth,
                height: buttonHeight
            )

            button.tag = 2000 + index
            button.addTarget(
                self,
                action: #selector(buttonPressed),
                for: .touchUpInside
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

        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
    }

    private func downloadImage(
        for searchResult: SearchResult,
        andPlaceOn button: UIButton
    ) {
        if let url = URL(string: searchResult.imageSmall) {
            let task = URLSession.shared.downloadTask(with: url) { [weak button] url, _, error in
                if error == nil,
                   let url = url,
                   let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data)
                {
                    DispatchQueue.main.async {
                        if let button = button {
                            button.setImage(image, for: .normal)
                        }
                    }
                }
            }
            task.resume()
            downloads.append(task)
        }
    }

    private func showSpinner() {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.center = CGPoint(
            x: scrollView.bounds.midX + 0.5,
            y: scrollView.bounds.midY + 0.5
        )
        spinner.tag = 1000
        view.addSubview(spinner)
        spinner.startAnimating()
    }

    private func showNothingFoundLabel() {
        let label = UILabel(frame: CGRect.zero)
        label.text = NSLocalizedString(
            "Nothing Found",
            comment: "No results in landscape view"
        )
        label.textColor = UIColor.label
        label.backgroundColor = UIColor.clear

        label.sizeToFit()

        var rect = label.frame
        rect.size.width = ceil(rect.size.width / 2) * 2
        rect.size.height = ceil(rect.size.height / 2) * 2
        label.frame = rect

        label.center = CGPoint(
            x: scrollView.bounds.midX,
            y: scrollView.bounds.midY
        )

        view.addSubview(label)
    }

    @objc private func buttonPressed(_ sender: UIButton) {
        performSegue(
            withIdentifier: "ShowDetail",
            sender: sender
        )
    }
}

// MARK: Actions

extension LandscapeViewController {
    @IBAction func pageChanged(_ sender: UIPageControl) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseInOut
        ) { [weak self] in
            guard let self else {
                return
            }

            scrollView.contentOffset = CGPoint(
                x: scrollView.bounds.size.width * CGFloat(sender.currentPage),
                y: 0
            )
        }
    }
}

// MARK: - Helper Methods

extension LandscapeViewController {
    func searchResultsReceived() {
        hideSpinner()

        switch search.state {
        case .noResults:
            showNothingFoundLabel()
        case .results(let list):
            tileButtons(list)
        case .notSearchedYet, .loading:
            break
        }
    }

    private func hideSpinner() {
        view.viewWithTag(1000)?.removeFromSuperview()
    }
}

// MARK: - Navigation

extension LandscapeViewController {
    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {
        if segue.identifier == "ShowDetail" {
            if case .results(let list) = search.state {
                let detailViewController = segue.destination as! DetailViewController
                let searchResult = list[(sender as! UIButton).tag - 2000]
                detailViewController.searchResult = searchResult
                detailViewController.isPopUp = true
            }
        }
    }
}

// MARK: - UIScrollViewDelegate

extension LandscapeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let page = Int((scrollView.contentOffset.x + width / 2) / width)
        pageControl.currentPage = page
    }
}
