import UIKit

class SearchViewController: UIViewController {
    private enum Constants {
        static var searchResultCellIdentifier: String { "SearchResultCell" }
        static var nothingFoundCellIdentifier: String { "NothingFoundCell" }
    }

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!

    private var searchResults: [SearchResult] = []
    private var hasSearched: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(
            top: 51,
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
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        hasSearched = true
        searchBar.resignFirstResponder()
        searchResults = []

        if searchBar.text! != "justin bieber" {
            for index in 0 ... 2 {
                let searchResult: SearchResult = .init()
                searchResult.name = String(format: "Fake Result %d for", index)
                searchResult.artistName = searchBar.text!

                searchResults.append(searchResult)
            }
        }

        tableView.reloadData()
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
        if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        if searchResults.count == 0 {
            return tableView.dequeueReusableCell(
                withIdentifier: Constants.nothingFoundCellIdentifier,
                for: indexPath
            )
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: Constants.searchResultCellIdentifier,
                for: indexPath
            ) as! SearchResultCell

            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            cell.artistNameLabel.text = searchResult.artistName

            return cell
        }
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(
        _ tableView: UITableView,
        willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
        if searchResults.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
}
