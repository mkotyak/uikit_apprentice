import UIKit

class SearchViewController: UIViewController {
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

        if searchResults.count == 0 {
            cell.textLabel!.text = "(Nothing found)"
            cell.detailTextLabel!.text = ""
        } else {
            let searchResult = searchResults[indexPath.row]
            cell.textLabel!.text = searchResult.name
            cell.detailTextLabel!.text = searchResult.artistName
        }

        return cell
    }
}
