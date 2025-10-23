//
//  DiscoverFeedItem.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 23.10.25.
//


//
//  DiscoverFeedItem.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 23.10.25.
//

import Foundation
import SwiftData

/// Persistenter Cache-Eintrag für Discover-Feeds.
/// Getrennt von `BookEntity`, damit die Nutzer-Library nicht mit API-Previews vermischt wird.
@Model
final class DiscoverFeedItem {
    /// Stabile ID aus der API (Google Books volume id)
    @Attribute(.unique) var sourceID: String

    /// Titel & Autor (flüchtige Preview-Daten)
    var title: String
    var author: String?

    /// Thumbnail-URL (als String gespeichert, da `@Model` keine URL direkt speichert)
    var thumbnailURL: String?

    /// Zugehörige Discover-Kategorie (als RawValue gespeichert)
    var categoryRaw: String

    /// Zeitstempel, wann dieses Item aktualisiert wurde (für Cache-Invalidation)
    var fetchedAt: Date

    init(
        sourceID: String,
        title: String,
        author: String?,
        thumbnailURL: String?,
        categoryRaw: String,
        fetchedAt: Date = .now
    ) {
        self.sourceID = sourceID
        self.title = title
        self.author = author
        self.thumbnailURL = thumbnailURL
        self.categoryRaw = categoryRaw
        self.fetchedAt = fetchedAt
    }
}

// MARK: - Convenience

extension DiscoverFeedItem {
    /// Erzeugt ein Cache-Item aus einem Remote-API-Buch.
    static func from(remote: RemoteBook, category: DiscoverCategory?) -> DiscoverFeedItem {
        DiscoverFeedItem(
            sourceID: remote.id,
            title: remote.title,
            author: remote.authors.trimmingCharacters(in: .whitespacesAndNewlines) == "—" ? nil : remote.authors,
            thumbnailURL: remote.thumbnailURL?.absoluteString,
            categoryRaw: category?.id ?? "uncategorized",
            fetchedAt: .now
        )
    }

    /// Zugriff auf Kategorie, falls bekannt
    var category: DiscoverCategory? {
        DiscoverCategory.ordered.first { $0.id == categoryRaw }
    }
}
