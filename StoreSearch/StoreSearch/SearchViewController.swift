import UIKit

class SearchViewController: UIViewController {
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!

    private var searchResults: [SearchResult] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(
            top: 51,
            left: 0,
            bottom: 0,
            right: 0
        )
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchResults = []

        for index in 0 ... 2 {
            let searchResult: SearchResult = .init()
            searchResult.name = String(format: "Fake Result %d for", index)
            searchResult.artistName = searchBar.text!

            searchResults.append(searchResult)
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
        searchResults.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        var cell: UITableViewCell
        let cellIdentifier = "SearchResultCell"

        if let reusableCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            cell = reusableCell
        } else {
            cell = UITableViewCell(
                style: .subtitle,
                reuseIdentifier: cellIdentifier
            )
        }

        let searchResult = searchResults[indexPath.row]
        cell.textLabel!.text = searchResult.name
        cell.detailTextLabel!.text = searchResult.artistName

        return cell
    }
}
