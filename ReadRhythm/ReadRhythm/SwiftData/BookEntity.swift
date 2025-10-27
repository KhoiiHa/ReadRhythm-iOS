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

    init(
        sourceID: String,
        title: String,
        author: String,
        thumbnailURL: String?,
        source: String,
        dateAdded: Date = .now
    ) {
        self.sourceID = sourceID
        self.title = title
        self.author = author
        self.thumbnailURL = thumbnailURL
        self.source = source
        self.dateAdded = dateAdded
    }
}
