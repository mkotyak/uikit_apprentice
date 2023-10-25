import UIKit

class SearchViewController: UIViewController {
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!

    private var searchResult: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchResult = []

        for index in 0 ... 2 {
            searchResult.append(
                String(format: "Fake Result %d for '%@'", index, searchBar.text!)
            )
        }

        tableView.reloadData()
    }
}

// MARK: Table View Delegate

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        searchResult.count
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
                style: .default,
                reuseIdentifier: cellIdentifier
            )
        }

        cell.textLabel!.text = searchResult[indexPath.row]

        return cell
    }
}
