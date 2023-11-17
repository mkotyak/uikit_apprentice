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
        let kind = self.kind ?? "audiobook"
        
        switch kind {
        case "album":
            return NSLocalizedString(
                "Album",
                comment: "Localized kind: Album")
        case "audiobook":
            return NSLocalizedString(
                "Audio Book",
                comment: "Localized kind: Audio Book")
        case "book":
            return NSLocalizedString(
                "Book",
                comment: "Localized kind: Book")
        case "ebook":
            return NSLocalizedString(
                "E-Book",
                comment: "Localized kind: E-Book")
        case "feature-movie":
            return NSLocalizedString(
                "Movie",
                comment: "Localized kind: Feature Movie")
        case "music-video":
            return NSLocalizedString(
                "Music Video",
                comment: "Localized kind: Music Video")
        case "podcast":
            return NSLocalizedString(
                "Podcast",
                comment: "Localized kind: Podcast")
        case "software":
            return NSLocalizedString(
                "App",
                comment: "Localized kind: Software")
        case "song":
            return NSLocalizedString(
                "Song",
                comment: "Localized kind: Song")
        case "tv-episode":
            return NSLocalizedString(
                "TV Episode",
                comment: "Localized kind: TV Episode")
        default:
            return kind
        }
    }

    var artist: String {
        artistName ?? ""
    }
}
