import Foundation

class ResultArray: Codable {
    var resultCount: Int = 0
    var results: [SearchResult] = []
}

class SearchResult: Codable, CustomStringConvertible {
    private enum CodingKeys: String, CodingKey {
        case imageSmall = "artworkUrl60"
        case imageLarge = "artworkUrl100"
        case itemGenre = "primaryGenreName"
        case bookGenre = "genres"
        case itemPrice = "price"
        case kind, artistName, currency
        case trackName, trackPrice, trackViewUrl
        case collectionName, collectionViewUrl, collectionPrice
    }

    var kind: String? = ""
    var artistName: String? = ""
    var trackName: String? = ""
    var trackPrice: Double? = 0.0
    var currency: String = ""
    var imageSmall: String = ""
    var imageLarge: String = ""
    var trackViewUrl: String?
    var collectionName: String?
    var collectionViewUrl: String?
    var collectionPrice: Double?
    var itemPrice: Double?
    var itemGenre: String?
    var bookGenre: [String]?

    var name: String {
        trackName ?? collectionName ?? " "
    }

    var description: String {
        "\nResult - Kind: \(kind ?? "None"), Name: \(name), Artist Name: \(artistName ?? "None")"
    }

    var storeURL: String {
        trackViewUrl ?? collectionViewUrl ?? ""
    }

    var price: Double {
        trackPrice ?? collectionPrice ?? itemPrice ?? 0.0
    }

    var genre: String {
        if let genre = itemGenre {
            return genre
        } else if let genres = bookGenre {
            return genres.joined(separator: ", ")
        }

        return ""
    }

    var type: String {
        let kind = kind ?? "audiobook"

        switch kind {
            case "album":
                return "Album"
            case "audiobook":
                return "Audio Book"
            case "book":
                return "Book"
            case "ebook":
                return "E-Book"
            case "feature-movie":
                return "Movie"
            case "music-video":
                return "Music Video"
            case "podcast":
                return "Podcast"
            case "software":
                return "App"
            case "song":
                return "Song"
            case "tv-episode":
                return "TV Episode"
            default:
                return "Unknown"
        }
    }

    var artist: String {
        artistName ?? ""
    }
}
