import Foundation

typealias SearchComplete = (Bool) -> Void

class Search {
    enum Categories: Int {
        case all
        case music
        case software
        case ebook

        var type: String {
            switch self {
            case .all:
                return ""
            case .music:
                return "musicTrack"
            case .software:
                return "software"
            case .ebook:
                return "ebook"
            }
        }
    }

    var searchResults: [SearchResult] = []
    var hasSearched: Bool = false
    var isLoading: Bool = false

    private var dataTask: URLSessionDataTask?

    func performSearch(
        for text: String,
        category: Categories,
        completion: @escaping SearchComplete
    ) {
        if !text.isEmpty {
            dataTask?.cancel()

            isLoading = true
            hasSearched = true
            searchResults = []

            let url = iTunesURL(searchText: text, category: category)
            let session = URLSession.shared

            dataTask = session.dataTask(with: url) { [weak self] data, response, error in
                guard let self else {
                    return
                }

                var success = false

                if let error = error as NSError?,
                   error.code == -999
                {
                    return
                }

                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200,
                   let data = data
                {
                    self.searchResults = self.parse(data: data)
                    self.searchResults.sort { $0.name < $1.name }

                    debugPrint("Success!")
                    self.isLoading = false
                    success = true
                }

                if !success {
                    self.hasSearched = false
                    self.isLoading = false
                }

                DispatchQueue.main.async { [weak self] in
                    guard let self else {
                        return
                    }

                    completion(success)
                }
            }

            dataTask?.resume()
        }
    }

    private func iTunesURL(
        searchText: String,
        category: Categories
    ) -> URL {
        let urlString = String(
            format: "https://itunes.apple.com/search?term=%@&limit=200&entity=%@",
            searchText, category.type
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
