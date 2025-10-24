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
    /// Mappt ein einzelnes VolumeDTO in ein `RemoteBook`,
    /// oder `nil`, wenn die Daten unbrauchbar sind.
    func toRemoteBook() -> RemoteBook? {
        // volumeInfo ist laut API optional – wenn's fehlt, können wir das Buch nicht darstellen
        guard let info = volumeInfo else {
            return nil
        }

        // Titel ist Pflicht. Ohne echten Titel zeigen wir das Buch gar nicht.
        let rawTitle = info.title?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nilIfEmpty

        guard let safeTitle = rawTitle else {
            return nil
        }

        // Autorenliste ist optional → wir erlauben "—" als Fallback
        let authorsJoined = (info.authors ?? [])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
            .nilIfEmpty ?? "—"

        // Thumbnail kann an mehreren Stellen stehen; wir upgraden http → https
        let thumb = info.imageLinks?.thumbnail
                 ?? info.imageLinks?.smallThumbnail
        let normalizedURL = thumb.flatMap { URL(string: $0) }?.forcingHTTPS()

        return RemoteBook(
            id: id,
            title: safeTitle,
            authors: authorsJoined,
            thumbnailURL: normalizedURL
        )
    }
}

extension BooksSearchResponseDTO {
    /// Extrahiert eine Liste von `RemoteBook` aus der Suchantwort (defensiv, stabil).
    /// Ungültige / unvollständige Volumes werden dabei übersprungen.
    func toRemoteBooks() -> [RemoteBook] {
        (items ?? []).compactMap { $0.toRemoteBook() }
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
