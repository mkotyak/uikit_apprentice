import Foundation

class ResultArray: Codable {
    var resultCount: Int = 0
    var results: [SearchResult] = []
}

class SearchResult: Codable, CustomStringConvertible {
    var artistName: String? = ""
    var trackName: String? = ""

    var name: String {
        trackName ?? ""
    }

    var description: String {
        "\nResult - Name: \(name), Artist Name: \(artistName ?? "None")"
    }
}
