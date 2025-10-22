//
//  BookMapper.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 22.10.25.
//

import Foundation

// MARK: - Domain (leichtgewichtig für Discover)

/// Leichtes Domain-Modell für API-Suchergebnisse (ohne Persistenz).
public struct RemoteBook: Equatable, Sendable {
    public let id: String
    public let title: String
    public let authors: String        // Kommagetrennter String für einfache Anzeige
    public let thumbnailURL: URL?     // Optional – nicht jedes Buch hat ein Bild
}

// MARK: - Mapping

extension VolumeDTO {
    /// Mappt ein einzelnes VolumeDTO in ein `RemoteBook`.
    func toRemoteBook() -> RemoteBook {
        let title = volumeInfo.title?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
                    ?? "—"
        let authorsJoined = (volumeInfo.authors ?? [])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
            .nilIfEmpty ?? "—"

        let thumb = volumeInfo.imageLinks?.thumbnail
                    ?? volumeInfo.imageLinks?.smallThumbnail
        let normalizedURL = thumb.flatMap { URL(string: $0) }?.forcingHTTPS()

        return RemoteBook(id: id, title: title, authors: authorsJoined, thumbnailURL: normalizedURL)
    }
}

extension BooksSearchResponseDTO {
    /// Extrahiert eine Liste von `RemoteBook` aus der Suchantwort (defensiv, stabil).
    func toRemoteBooks() -> [RemoteBook] {
        (items ?? []).map { $0.toRemoteBook() }
    }
}

// MARK: - Decoding Convenience

/// Kleiner Decoder, der Roh-`Data` in `[RemoteBook]` überführt.
/// (Repository kann das direkt nutzen, UI bleibt Domain-pur.)
public enum BooksDecoder {
    public static func decodeSearchList(from data: Data) throws -> [RemoteBook] {
        let decoder = JSONDecoder()
        let dto = try decoder.decode(BooksSearchResponseDTO.self, from: data)
        let books = dto.toRemoteBooks()

        #if DEBUG
        print("🧩 [BooksDecoder] decoded \(books.count) items")
        #endif

        return books
    }
}

// MARK: - Helpers

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}

private extension URL {
    /// Erzwingt HTTPS, falls Google-Links mal `http` liefern.
    func forcingHTTPS() -> URL {
        guard scheme?.lowercased() == "http" else { return self }
        var comps = URLComponents(url: self, resolvingAgainstBaseURL: false)
        comps?.scheme = "https"
        return comps?.url ?? self
    }
}
