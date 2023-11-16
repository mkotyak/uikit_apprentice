import Foundation

typealias SearchComplete = (Bool) -> Void

class Search {
    var searchResults: [SearchResult] = []
    var hasSearched: Bool = false
    var isLoading: Bool = false

    private var dataTask: URLSessionDataTask?

    func performSearch(
        for text: String,
        category: Int,
        completion: @escaping SearchComplete
    ) {
        if !text.isEmpty {
            dataTask?.cancel()

            isLoading = true
            hasSearched = true
            searchResults = []

            let url = iTunesURL(searchText: text, categoryIndex: category)

            let session = URLSession.shared
            dataTask = session.dataTask(with: url) { data, response, error in
                var success = false

                if let error = error as NSError?, error.code == -999 {
                    return
                }

                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200, let data = data
                {
                    self.searchResults = self.parse(data: data)
                    self.searchResults.sort { $0.name < $1.name }

                    print("Success!")
                    self.isLoading = false
                    success = true
                }

                if !success {
                    self.hasSearched = false
                    self.isLoading = false
                }

                DispatchQueue.main.async {
                    completion(success)
                }
            }
            dataTask?.resume()
        }
    }

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
}
