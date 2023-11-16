import Foundation

typealias SearchComplete = (Bool) -> Void

class Search {
    enum State {
        case notSearchedYet
        case loading
        case noResults
        case results([SearchResult])
    }

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

    private(set) var state: State = .notSearchedYet
    private var dataTask: URLSessionDataTask?

    func performSearch(
        for text: String,
        category: Categories,
        completion: @escaping SearchComplete
    ) {
        if !text.isEmpty {
            dataTask?.cancel()
            state = .loading

            let url = iTunesURL(searchText: text, category: category)
            let session = URLSession.shared

            dataTask = session.dataTask(with: url) { [weak self] data, response, error in
                guard let self else {
                    return
                }

                var newState = State.notSearchedYet
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
                    var searchResults = self.parse(data: data)

                    if searchResults.isEmpty {
                        newState = .noResults
                    } else {
                        searchResults.sort { $0.name < $1.name }
                        newState = .results(searchResults)
                    }

                    success = true
                }

                DispatchQueue.main.async { [weak self] in
                    guard let self else {
                        return
                    }

                    state = newState
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
