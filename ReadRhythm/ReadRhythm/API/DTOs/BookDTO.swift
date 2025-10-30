//
//  BookDTO.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 22.10.25.
//

import Foundation

/// Root-Response für: GET /volumes?q=...
struct BooksSearchResponseDTO: Codable {
    let items: [VolumeDTO]?

    // Google Books liefert u. U. auch Felder wie totalItems etc.
    // Für MVP nicht nötig; wir lassen sie weg, um das DTO schlank zu halten.
}

/// Einzelnes Volume (Buch) in der Suche.
struct VolumeDTO: Codable {
    let id: String
    let volumeInfo: VolumeInfoDTO?
}

/// Metadaten eines Buchs (Teilmenge für MVP).
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
    let infoLink: String?
    let language: String?
    let averageRating: Double?
    let ratingsCount: Int?
    let imageLinks: ImageLinksDTO?
    // Raum für spätere Felder:
    // let industryIdentifiers: [IndustryIdentifierDTO]?
}

/// Bild-Links (nicht immer vorhanden).
struct ImageLinksDTO: Codable {
    let smallThumbnail: String?
    let thumbnail: String?
}

// Optional für später, falls du ISBN brauchst:
// struct IndustryIdentifierDTO: Codable {
//     let type: String?
//     let identifier: String?
// }
