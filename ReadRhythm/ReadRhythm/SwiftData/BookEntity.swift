// MARK: - BookEntity / Buch-Entity
// Kontext: Modelliert ein Buch im lokalen Katalog / Context: Models a book in the local catalog.
// Warum: Discover, Focus Mode & History benötigen konsistente Daten / Why: Discover, focus mode, and history need consistent data.
// Wie: Persistiert IDs, Metadaten und Assets für Beziehungen / How: Persists IDs, metadata, and assets for relationships.
import Foundation
import SwiftData

@Model
final class BookEntity {

    /// Eindeutige ID aus der Quelle / Unique source identifier
    @Attribute(.unique)
    var sourceID: String

    /// Buchtitel (Pflicht) / Book title (required)
    var title: String

    /// Autor oder Autoren (kommagetrennt) / Author string (comma separated)
    var author: String

    /// Thumbnail/Cover-URL (optional) / Thumbnail or cover URL (optional)
    var thumbnailURL: String?

    /// Quelle der Daten, z. B. "Google Books" / Data source label such as "Google Books"
    var source: String

    /// Zeitpunkt des Speicherns / Timestamp when the user saved the book
    var dateAdded: Date

    /// Optionaler Untertitel / Optional subtitle
    var subtitle: String?

    /// Verlag / Publisher, sofern verfügbar / Publisher when available
    var publisher: String?

    /// Veröffentlichungsdatum (ISO-String oder frei formatiert) / Publication date string
    var publishedDate: String?

    /// Anzahl der Seiten, falls bekannt / Page count when known
    var pageCount: Int?

    /// Sprachcode (BCP-47), z. B. "en", "de" / Language code (BCP-47)
    var language: String?

    /// Kategorien / Genres als Schlagwortliste / Categories or genres as keyword list
    var categories: [String]

    /// Lange Beschreibungstexte (optional) / Long description text stored externally
    @Attribute(.externalStorage)
    var descriptionText: String?

    /// Link zur Info-Seite / Link to info page
    var infoLink: URL?

    /// Link zur Vorschau / Preview link from the source
    var previewLink: URL?

    init(
        sourceID: String,
        title: String,
        author: String,
        thumbnailURL: String?,
        source: String,
        dateAdded: Date = .now,
        subtitle: String? = nil,
        publisher: String? = nil,
        publishedDate: String? = nil,
        pageCount: Int? = nil,
        language: String? = nil,
        categories: [String] = [],
        descriptionText: String? = nil,
        infoLink: URL? = nil,
        previewLink: URL? = nil
    ) {
        self.sourceID = sourceID
        self.title = title
        self.author = author
        self.thumbnailURL = thumbnailURL
        self.source = source
        self.dateAdded = dateAdded
        self.subtitle = subtitle
        self.publisher = publisher
        self.publishedDate = publishedDate
        self.pageCount = pageCount
        self.language = language
        self.categories = categories
        self.descriptionText = descriptionText
        self.infoLink = infoLink
        self.previewLink = previewLink
    }
}
