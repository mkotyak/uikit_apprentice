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

        searchBar.becomeFirstResponder()
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()

            hasSearched = true
            searchResults = []

            let url = iTunesURL(searchText: searchBar.text!)
            debugPrint("URL: '\(url)'")

            if let data = performStoreRequest(with: url) {
                let results = parse(data: data)
                print("Got results: \(results)")
            }

            tableView.reloadData()
        }
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

// MARK: Networking

extension SearchViewController {
    private func iTunesURL(searchText: String) -> URL {
        let urlString = String(
            format: "https://itunes.apple.com/search?term=%@",
            searchText
        )

        return URL(string: urlString)!
    }

    private func performStoreRequest(with url: URL) -> Data? {
        do {
            return try Data(contentsOf: url)
        } catch {
            debugPrint("Download Error: \(error.localizedDescription)")
            showNetworkError()

            return nil
        }
    }

    private func parse(data: Data) -> [SearchResult] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)

            return result.results
        } catch {
            debugPrint("JSON Error: \(error.localizedDescription)")
            return []
        }
    }

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
