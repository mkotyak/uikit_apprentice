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

        searchBar.becomeFirstResponder()
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
        search.performSearch(
            for: searchBar.text!,
            category: segmentedControl.selectedSegmentIndex
        ) { [weak self] success in
            guard let self else {
                return
            }

            success ? tableView.reloadData() : showNetworkError()
        }

        tableView.reloadData()
        searchBar.resignFirstResponder()
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
        if search.isLoading {
            return 1
        } else if !search.hasSearched {
            return 0
        } else if search.searchResults.count == 0 {
            return 1
        } else {
            return search.searchResults.count
        }
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        if search.isLoading {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: Constants.loadingCellIdentifier,
                for: indexPath
            )
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()

            return cell
        } else if search.searchResults.count == 0 {
            return tableView.dequeueReusableCell(
                withIdentifier: Constants.nothingFoundCellIdentifier,
                for: indexPath
            )
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: Constants.searchResultCellIdentifier,
                for: indexPath
            ) as! SearchResultCell

            let searchResult = search.searchResults[indexPath.row]
            cell.configure(for: searchResult)

            return cell
        }
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }

    func tableView(
        _ tableView: UITableView,
        willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
        if search.searchResults.count == 0 || search.isLoading {
            return nil
        } else {
            return indexPath
        }
    }
}

// MARK: Networking

extension SearchViewController {
    private func showNetworkError() {
        let alert = UIAlertController(
            title: "Whoops...",
            message: "There was an error accessing the iTunes Store. Please try again.",
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
            let detailViewController = segue.destination as! DetailViewController
            let indexPath = sender as! IndexPath

            detailViewController.searchResult = search.searchResults[indexPath.row]
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
                alongsideTransition: { _ in
                    landscapeViewController.view.alpha = 0
                }, completion: { _ in
                    landscapeViewController.view.removeFromSuperview()
                    landscapeViewController.removeFromParent()
                    self.landscapeViewController = nil
                }
            )
        }
    }
}
