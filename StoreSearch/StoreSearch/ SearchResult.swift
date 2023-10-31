import Foundation

class ResultArray: Codable {
    var resultCount: Int = 0
    var results: [SearchResult] = []
}

class SearchResult: Codable {
    var artistName: String? = ""
    var trackName: String? = ""

    var name: String {
        trackName ?? ""
    }
}
