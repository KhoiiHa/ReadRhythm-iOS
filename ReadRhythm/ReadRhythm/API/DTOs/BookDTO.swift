// MARK: - Google Books DTOs / Google Books DTOs
// Definieren schlanke Codable-Container für API-Responses / Provide lightweight Codable containers for API responses.

import Foundation

/// Root-Response für die Suche / Root response for search results.
struct BooksSearchResponseDTO: Codable {
    let items: [VolumeDTO]?

    // Weitere Metadaten werden bewusst ausgelassen / Additional metadata omitted intentionally
}

/// Einzelnes Volume (Buch) in der Suche / Individual volume in the search response.
struct VolumeDTO: Codable {
    let id: String
    let volumeInfo: VolumeInfoDTO?
}

/// Metadaten eines Buchs, reduziert aufs MVP /
/// Book metadata reduced to MVP scope.
struct VolumeInfoDTO: Codable {
    let title: String?
    let subtitle: String?
    let authors: [String]?
    let publisher: String?
    let publishedDate: String?
    let pageCount: Int?
    let categories: [String]?
    let description: String?
    let previewLink: String?
    let imageLinks: ImageLinksDTO?
    // Raum für spätere Felder / Space for future fields
    // let industryIdentifiers: [IndustryIdentifierDTO]?
}

/// Bild-Links, optional laut API /
/// Image links, optional according to the API.
struct ImageLinksDTO: Codable {
    let smallThumbnail: String?
    let thumbnail: String?
}

// Optional für spätere Erweiterungen wie ISBN / Optional placeholder for ISBN support
// struct IndustryIdentifierDTO: Codable {
//     let type: String?
//     let identifier: String?
// }
