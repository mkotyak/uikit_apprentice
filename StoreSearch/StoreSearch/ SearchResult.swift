import Foundation

class ResultArray: Codable {
    var resultCount: Int = 0
    var results: [SearchResult] = []
}

class SearchResult: Codable, CustomStringConvertible {
    private enum CodingKeys: String, CodingKey {
        case imageSmall = "artworkUrl60"
        case imageLarge = "artworkUrl100"
        case storeURL = "trackViewUrl"
        case genre = "primaryGenreName"
        case kind, artistName, trackName
        case trackPrice, currency
    }

    var kind: String? = ""
    var artistName: String? = ""
    var trackName: String? = ""
    var trackPrice: Double? = 0.0
    var storeURL: String? = ""
    var currency: String = ""
    var imageSmall: String = ""
    var imageLarge: String = ""
    var genre: String = ""

    var name: String {
        trackName ?? ""
    }

    var description: String {
        "\nResult - Kind: \(kind ?? "None"), Name: \(name), Artist Name: \(artistName ?? "None"), Genre: \(genre)"
    }
}
