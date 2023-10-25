import UIKit

class SearchViewController: UIViewController {
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        debugPrint("The search text is: '\(searchBar.text!)'")
    }
}
