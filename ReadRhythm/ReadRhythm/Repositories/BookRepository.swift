// MARK: - Buch-Repository-Protokoll / Book Repository Protocol
// Kontext: Schnittstelle für den lokalen SwiftData-Store / Context: Interface for the local SwiftData store.
// Warum: Discover & Library programmieren gegen das Protokoll / Why: Discover and Library code against this protocol.
// Wie: Unterstützt manuell hinzugefügte & API-Bücher mit optionalen Metadaten /
// How: Supports manual and API-imported books with optional metadata.

import Foundation
import SwiftData

/// Abstraktion für lokale Buch-Operationen (SwiftData) /
/// Abstraction for local book operations backed by SwiftData.
protocol BookRepository {
    /// Persistiert ein Buch in SwiftData und gibt die Entität zurück /
    /// Persists a book in SwiftData and returns the stored entity.
    /// - Parameters:
    ///   - title: Anzeigename des Buches (Pflicht) / Display title (required)
    ///   - author: Autor:innen-Liste (optional) / Author list (optional)
    ///   - subtitle/publisher/...: Optionale Metadaten / Optional rich metadata
    ///   - thumbnailURL: Optionales Remote-Cover / Optional remote cover URL
    ///   - infoLink/previewLink: Optionale externe Links / Optional external links
    ///   - sourceID: Externe ID (optional) / External identifier (optional)
    ///   - source: Kennzeichnung der Quelle / Source label
    @discardableResult
    func add(
        title: String,
        author: String?,
        subtitle: String?,
        publisher: String?,
        publishedDate: String?,
        pageCount: Int?,
        language: String?,
        categories: [String],
        descriptionText: String?,
        thumbnailURL: String?,
        infoLink: URL?,
        previewLink: URL?,
        sourceID: String?,
        source: String
    ) throws -> BookEntity

    /// Löscht ein Buch aus der Persistenz /
    /// Deletes a book from persistence.
    func delete(_ book: BookEntity) throws

    /// Lädt Bücher aus der Persistenzschicht, optional sortiert /
    /// Loads books from persistence with optional sorting.
    func fetchBooks(sortedBy descriptors: [SortDescriptor<BookEntity>]) throws -> [BookEntity]
}

// MARK: - Default Convenience / Komfort-Helfer
// Convenience für UI/Previews ohne Metadaten / Convenience for UI and previews without metadata.
extension BookRepository {
    @discardableResult
    func add(
        title: String,
        author: String?
    ) throws -> BookEntity {
        try add(
            title: title,
            author: author,
            subtitle: nil,
            publisher: nil,
            publishedDate: nil,
            pageCount: nil,
            language: nil,
            categories: [],
            descriptionText: nil,
            thumbnailURL: nil,
            infoLink: nil,
            previewLink: nil,
            sourceID: nil,
            source: "User" // Fallback-Quelle für manuell hinzugefügte Bücher / Fallback source label
        )
    }

    /// Bequemer Aufruf ohne Sort-Descriptor / Convenience call defaulting to `dateAdded` descending
    func fetchBooks() throws -> [BookEntity] {
        try fetchBooks(sortedBy: [SortDescriptor(\BookEntity.dateAdded, order: .reverse)])
    }
}
