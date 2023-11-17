import UIKit

class SearchViewController: UIViewController {
    private enum Constants {
        static var searchResultCellIdentifier: String { "SearchResultCell" }
        static var nothingFoundCellIdentifier: String { "NothingFoundCell" }
        static var loadingCellIdentifier: String { "LoadingCell" }
    }

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!

    private let search: Search = .init()
    private var landscapeViewController: LandscapeViewController?

    weak var splitViewDetail: DetailViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(
            top: 91,
            left: 0,
            bottom: 0,
            right: 0
        )

        var cellNib = UINib(
            nibName: Constants.searchResultCellIdentifier,
            bundle: nil
        )
        tableView.register(
            cellNib,
            forCellReuseIdentifier: Constants.searchResultCellIdentifier
        )

        cellNib = UINib(
            nibName: Constants.nothingFoundCellIdentifier,
            bundle: nil
        )
        tableView.register(
            cellNib,
            forCellReuseIdentifier: Constants.nothingFoundCellIdentifier
        )

        cellNib = UINib(
            nibName: Constants.loadingCellIdentifier,
            bundle: nil
        )
        tableView.register(
            cellNib,
            forCellReuseIdentifier: Constants.loadingCellIdentifier
        )

        if UIDevice.current.userInterfaceIdiom != .pad {
            searchBar.becomeFirstResponder()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if UIDevice.current.userInterfaceIdiom == .phone {
            navigationController?.navigationBar.isHidden = true
        }
    }

    override func willTransition(
        to newCollection: UITraitCollection,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.willTransition(to: newCollection, with: coordinator)

        switch newCollection.verticalSizeClass {
        case .compact:
            showLandscape(with: coordinator)
        case .regular, .unspecified:
            hideLandscape(with: coordinator)
        @unknown default:
            break
        }
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }

    func performSearch() {
        if let category = Search.Categories(rawValue: segmentedControl.selectedSegmentIndex) {
            search.performSearch(
                for: searchBar.text!,
                category: category
            ) { [weak self] success in
                guard let self else {
                    return
                }

                if !success {
                    showNetworkError()
                }

                tableView.reloadData()
                landscapeViewController?.searchResultsReceived()
            }

            tableView.reloadData()
            searchBar.resignFirstResponder()
        }
    }

    private func hidePrimaryPane() {
        UIView.animate(
            withDuration: 0.25,
            animations: {
                self.splitViewController!.preferredDisplayMode = .secondaryOnly
            }, completion: { _ in
                self.splitViewController!.preferredDisplayMode = .automatic
            }
        )
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        .topAttached
    }
}

// MARK: Table View Delegate

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        switch search.state {
        case .notSearchedYet:
            return 0
        case .loading:
            return 1
        case .noResults:
            return 1
        case .results(let results):
            return results.count
        }
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        switch search.state {
        case .notSearchedYet:
            fatalError("Should never get here")
        case .loading:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: Constants.loadingCellIdentifier,
                for: indexPath
            )

            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()

            return cell
        case .noResults:
            return tableView.dequeueReusableCell(
                withIdentifier: Constants.nothingFoundCellIdentifier,
                for: indexPath
            )
        case .results(let results):
            let cell = tableView.dequeueReusableCell(
                withIdentifier: Constants.searchResultCellIdentifier,
                for: indexPath
            ) as! SearchResultCell

            let searchResult = results[indexPath.row]
            cell.configure(for: searchResult)

            return cell
        }
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        if view.window!.rootViewController!.traitCollection.horizontalSizeClass == .compact {
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "ShowDetail", sender: indexPath)
        } else {
            if case .results(let list) = search.state {
                splitViewDetail?.searchResult = list[indexPath.row]
            }

            if splitViewController!.displayMode != .oneBesideSecondary {
                hidePrimaryPane()
            }
        }
    }

    func tableView(
        _ tableView: UITableView,
        willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
        switch search.state {
        case .notSearchedYet, .loading, .noResults:
            return nil
        case .results:
            return indexPath
        }
    }
}

// MARK: Networking

extension SearchViewController {
    private func showNetworkError() {
        let alert = UIAlertController(
            title: NSLocalizedString(
                "Whoops...",
                comment: "Error alert: title"
            ),
            message: NSLocalizedString(
                "There was an error reading from the iTunes Store. Please try again.",
                comment: "Error alert: message"
            ),
            preferredStyle: .alert
        )

        let action = UIAlertAction(
            title: "OK",
            style: .default
        )

        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Navigation

extension SearchViewController {
    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {
        if segue.identifier == "ShowDetail" {
            if case .results(let results) = search.state {
                let detailViewController = segue.destination as! DetailViewController
                let indexPath = sender as! IndexPath
                let searchResult = results[indexPath.row]
                detailViewController.searchResult = searchResult
                detailViewController.isPopUp = true
            }
        }
    }
}

// MARK: - Helper Methods

extension SearchViewController {
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        guard landscapeViewController == nil else {
            return
        }

        landscapeViewController = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController

        if let landscapeViewController {
            landscapeViewController.search = search

            landscapeViewController.view.frame = view.bounds
            landscapeViewController.view.alpha = 0

            view.addSubview(landscapeViewController.view)
            addChild(landscapeViewController)

            coordinator.animate(
                alongsideTransition: { [weak self] _ in
                    landscapeViewController.view.alpha = 1
                    self?.searchBar.resignFirstResponder()

                    if self?.presentedViewController != nil {
                        self?.dismiss(animated: true)
                    }
                }, completion: { _ in
                    landscapeViewController.didMove(toParent: self)
                }
            )
        }
    }

    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let landscapeViewController {
            landscapeViewController.willMove(toParent: nil)

            coordinator.animate(
                alongsideTransition: { [weak self] _ in
                    landscapeViewController.view.alpha = 0
                    if self?.presentedViewController != nil {
                        self?.dismiss(animated: true)
                    }
                }, completion: { _ in
                    landscapeViewController.view.removeFromSuperview()
                    landscapeViewController.removeFromParent()
                    self.landscapeViewController = nil
                }
            )
        }
    }
}
