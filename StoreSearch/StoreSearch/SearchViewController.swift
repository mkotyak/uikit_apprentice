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

    private var searchResults: [SearchResult] = []
    private var dataTask: URLSessionDataTask?

    private var hasSearched: Bool = false
    private var isLoading: Bool = false

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

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }

    private func performSearch() {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()

            dataTask?.cancel()

            isLoading = true
            tableView.reloadData()

            hasSearched = true
            searchResults = []

            let url = iTunesURL(
                searchText: searchBar.text!,
                categoryIndex: segmentedControl.selectedSegmentIndex
            )
            let session = URLSession.shared

            dataTask = session.dataTask(with: url) { [weak self] data, response, error in
                guard let self else {
                    return
                }

                if let error = error as NSError?,
                   error.code == -999
                {
                    return // Search was cancelled
                } else if let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200
                {
                    guard let data else {
                        debugPrint("Data is empty!")
                        return
                    }

                    searchResults = parse(data: data)
                    searchResults.sort { $0.name < $1.name }

                    DispatchQueue.main.async { [weak self] in
                        guard let self else {
                            return
                        }
                        isLoading = false
                        tableView.reloadData()
                    }

                    return
                } else {
                    debugPrint("Failure! \(response!)")
                }

                DispatchQueue.main.async { [weak self] in
                    guard let self else {
                        return
                    }
                    hasSearched = false
                    isLoading = false
                    tableView.reloadData()
                    showNetworkError()
                }
            }

            dataTask?.resume()
        }
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
        if isLoading {
            return 1
        } else if !hasSearched {
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
        if isLoading {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: Constants.loadingCellIdentifier,
                for: indexPath
            )
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()

            return cell
        } else if searchResults.count == 0 {
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
            cell.configure(for: searchResult)

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
        if searchResults.count == 0 || isLoading {
            return nil
        } else {
            return indexPath
        }
    }
}

// MARK: Networking

extension SearchViewController {
    private func iTunesURL(
        searchText: String,
        categoryIndex: Int
    ) -> URL {
        let category: String

        switch categoryIndex {
        case 1:
            category = "musicTrack"
        case 2:
            category = "software"
        case 3:
            category = "ebook"
        default:
            category = ""
        }

        let urlString = String(
            format: "https://itunes.apple.com/search?term=%@&limit=200&entity=%@",
            searchText, category
        )

        return URL(string: urlString)!
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
