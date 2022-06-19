//
//  SearchResult.swift
//  StoreSearch
//
//  Created by  Максим Мартынов on 16.04.2021.
//
import Foundation
class ResultArray: Codable {
    var resultCount = 0
    var results = [SearchResult]()
}

class SearchResult: Codable, CustomStringConvertible {
    private let typeForKind = [
        "album": NSLocalizedString("Album", comment: "Localized kind: Album"),
        "audiobook": NSLocalizedString("Audio Book", comment: "Localized kind: Audio Book"),
        "book": NSLocalizedString("Book", comment: "Localized kind: Book"),
        "ebook": NSLocalizedString("E-Book", comment: "Localized kind: E-Book"),
        "feature-movie": NSLocalizedString("Movie", comment: "Localized kind: Movie"),
        "music-video": NSLocalizedString("Music Video", comment: "Localized kind: Music Video"),
        "podcast": NSLocalizedString("Podcast", comment: "Localized kind: Podcast"),
        "software": NSLocalizedString("App", comment: "Localized kind: App"),
        "song": NSLocalizedString("Song", comment: "Localized kind: Song"),
        "tv-episode": NSLocalizedString("TV Episode", comment: "Localized kind: TV Episode")
    ]
    
    var description: String {
        return "Kind: \(kind ?? "None"), Name: \(name), Artist Name: \(artistName ?? "None")"
    }
    var kind: String? = ""
    var artistName: String? = ""
    var currency = ""
    var trackName: String? = ""
    var collectionName: String?
    var name: String {
        return trackName ?? collectionName ?? ""
    }
    
    var trackPrice: Double? = 0.0
    var imageSmall = ""
    var imageLarge = ""
    var trackViewUrl: String?
    var collectionViewUrl: String?
    var collectionPrice: Double?
    var itemPrice: Double?
    var itemGenre: String?
    var bookGenre: [String]?
    
    var price: Double {
        return trackPrice ?? itemPrice ?? collectionPrice ?? 0.0
    }
    
    var storeURL: String {
        return trackViewUrl ?? collectionViewUrl ?? ""
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
        return typeForKind[kind] ?? kind
      }
    
    var artist: String {
        return artistName ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case imageSmall = "artworkUrl60"
        case imageLarge = "artworkUrl100"
        case itemGenre = "priparyGenreName"
        case bookGenre = "genres"
        case itemPrice = "price"
        case trackName, trackPrice, trackViewUrl
        case collectionName, collectionPrice, collectionViewUrl
        case kind, artistName, currency
    }
    
}

func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
}

func > (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedDescending
}
