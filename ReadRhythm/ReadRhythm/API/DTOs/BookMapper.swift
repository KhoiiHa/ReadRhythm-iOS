// MARK: - Mapping von Google Books / Mapping Google Books Data
// Übersetzt API-DTOs in Domain-Objekte für Discover / Converts API DTOs into domain objects for Discover.

import Foundation

// MARK: - Domain (Discover) / Domain (Discover)

/// Leichtes Domain-Modell für API-Suchergebnisse / Lightweight domain model for API search results.
public struct RemoteBook: Equatable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let authors: [String]
    public let publisher: String?
    public let publishedDate: String?
    public let pageCount: Int?
    public let language: String?
    public let infoLink: URL?
    public let categories: [String]
    public let description: String?
    public let thumbnailURL: URL?
    public let previewLink: URL?
}

public extension RemoteBook {
    /// Vereinheitlichte Anzeige für Autor:innen / Unified author display formatting.
    var authorsDisplay: String {
        let trimmed = authors
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return trimmed.isEmpty ? "—" : trimmed.joined(separator: ", ")
    }

    /// Convenience-Initializer für Caches mit Autor:innen-String /
    /// Convenience initializer for caches storing a single author string.
    init(id: String, title: String, authorsDisplay: String?, thumbnailURL: URL?) {
        let authorList = authorsDisplay?
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty } ?? []

        self.init(
            id: id,
            title: title,
            subtitle: nil,
            authors: authorList,
            publisher: nil,
            publishedDate: nil,
            pageCount: nil,
            language: nil,
            infoLink: nil,
            categories: [],
            description: nil,
            thumbnailURL: thumbnailURL,
            previewLink: nil
        )
    }
}

// MARK: - Mapping / Mapping

extension VolumeDTO {
    /// Mappt ein einzelnes VolumeDTO in ein `RemoteBook` /
    /// Maps a single `VolumeDTO` into a `RemoteBook`.
    /// Gibt `nil` zurück, wenn Daten unbrauchbar sind /
    /// Returns `nil` when the payload is unusable.
    func toRemoteBook() -> RemoteBook? {
        // volumeInfo ist optional – ohne Info kein darstellbares Buch /
        // volumeInfo is optional; without it the book cannot be rendered
        guard let info = volumeInfo else {
            return nil
        }

        // Titel muss vorhanden sein / Title is mandatory
        let rawTitle = info.title?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nilIfEmpty

        guard let safeTitle = rawTitle else {
            return nil
        }

        // Autorenliste ist optional → Fallback erlaubt /
        // Authors list is optional; fallback is allowed
        let authorsList = (info.authors ?? [])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        // Thumbnail an mehreren Stellen → http → https upgraden /
        // Thumbnail may appear in different fields; upgrade http to https
        let thumb = info.imageLinks?.thumbnail
                 ?? info.imageLinks?.smallThumbnail
        let normalizedURL = thumb.flatMap { URL(string: $0) }?.forcingHTTPS()

        let previewURL = info.previewLink
            .flatMap { URL(string: $0) }?
            .forcingHTTPS()

        // Defensive Fallback: previewLink als infoLink nutzen / Use previewLink as fallback info link
        let infoURL = previewURL
        let language: String? = nil

        let categories = (info.categories ?? [])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return RemoteBook(
            id: id,
            title: safeTitle,
            subtitle: info.subtitle?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            authors: authorsList,
            publisher: info.publisher?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            publishedDate: info.publishedDate?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            pageCount: info.pageCount,
            language: language,
            infoLink: infoURL,
            categories: categories,
            description: info.description?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            thumbnailURL: normalizedURL,
            previewLink: previewURL
        )
    }
}

private extension VolumeDTO {
    static func extractPublishedYear(from rawValue: String) -> String? {
        guard !rawValue.isEmpty else { return nil }

        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // Google Books liefert unterschiedliche Datumsformate / Google Books returns varying date formats
        // Wir extrahieren defensiv die ersten vier Ziffern / We defensively extract the first four digits
        let digits = trimmed.prefix(4)
        if digits.count == 4, digits.allSatisfy({ $0.isNumber }) {
            return String(digits)
        }

        // Fallback: Rohwert zurückgeben / Fallback: return the raw value
        return trimmed
    }
}

extension BooksSearchResponseDTO {
    /// Extrahiert eine Liste von `RemoteBook` aus der Suche /
    /// Extracts a list of `RemoteBook` from the search response.
    /// Ungültige Volumes werden übersprungen / Invalid volumes are skipped.
    func toRemoteBooks() -> [RemoteBook] {
        (items ?? []).compactMap { $0.toRemoteBook() }
    }
}

// MARK: - Decoding Convenience / Dekodierhilfe

/// Kleiner Decoder für die Repository-Schicht /
/// Lightweight decoder turning raw `Data` into `[RemoteBook]`.
/// Repository nutzt ihn direkt, UI bleibt Domain-pur /
/// Repository consumes it directly so the UI stays domain pure.
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

// MARK: - Helpers / Hilfsfunktionen

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}

private extension URL {
    /// Erzwingt HTTPS für Google-Links / Forces HTTPS for Google links.
    func forcingHTTPS() -> URL {
        guard scheme?.lowercased() == "http" else { return self }
        var comps = URLComponents(url: self, resolvingAgainstBaseURL: false)
        comps?.scheme = "https"
        return comps?.url ?? self
    }
}

private extension Array where Element == String {
    func uniquedPreservingCase() -> [String] {
        var seen: Set<String> = []
        var result: [String] = []

        for value in self {
            let lowered = value.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            if seen.contains(lowered) { continue }
            seen.insert(lowered)
            result.append(value)
        }

        return result
    }
}
