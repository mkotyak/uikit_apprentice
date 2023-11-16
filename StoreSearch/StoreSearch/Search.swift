import Foundation

class Search {
    var searchResult: [SearchResult] = []
    var hasSearched: Bool = false
    var isLoading: Bool = false

    private var dataTest: URLSessionDataTask?

    func performSearch(for text: String, category: Int) {
        print("Searching...")
    }
}
