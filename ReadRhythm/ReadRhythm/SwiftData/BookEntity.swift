// Kontext: Diese SwiftData-Entity modelliert ein Buch innerhalb unseres lokalen Katalogs.
// Warum: Features wie Discover, Focus Mode und History brauchen konsistente Buchdaten.
// Wie: Wir speichern IDs, Metadaten und Bilder als persistente Eigenschaften für Beziehungen.
import Foundation
import SwiftData

@Model
final class BookEntity {

    /// Eindeutige ID aus der Quelle (z.B. Google Books Volume ID)
    @Attribute(.unique)
    var sourceID: String

    /// Buchtitel (Pflicht)
    var title: String

    /// Autor oder Autoren (kommagetrennt)
    var author: String

    /// Thumbnail/Cover-URL als String (optional),
    /// wird für die Anzeige in der Bibliothek benutzt
    var thumbnailURL: String?

    /// Quelle der Daten, z.B. "Google Books"
    var source: String

    /// Wann hat der User das Buch gespeichert
    var dateAdded: Date

    /// Optionaler Untertitel des Buches
    var subtitle: String?

    /// Verlag / Publisher, sofern verfügbar
    var publisher: String?

    /// Veröffentlichungsdatum (ISO-String oder frei formatiert)
    var publishedDate: String?

    /// Anzahl der Seiten, falls bekannt
    var pageCount: Int?

    /// Sprachcode (BCP-47), z.B. "en", "de"
    var language: String?

    /// Kategorien / Genres als Schlagwortliste
    var categories: [String]

    /// Lange Beschreibungstexte (ggf. aus Remote-Quelle)
    @Attribute(.externalStorage)
    var descriptionText: String?

    /// Link zur Google-Books-Infoseite
    var infoLink: URL?

    /// Link zur Vorschau / Reader der Quelle
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
