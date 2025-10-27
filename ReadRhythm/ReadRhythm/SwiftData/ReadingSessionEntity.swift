// Kontext: Diese SwiftData-Entity repräsentiert einzelne Lese- oder Hörsessions.
// Warum: Persistente Sitzungen sind die Basis für History, Ziele und Statistiken.
// Wie: Wir modellieren Attribute inklusive Medium, Dauer und zugeordnetem Buch.
import Foundation
import SwiftData

@Model
final class ReadingSessionEntity {
    @Attribute(.unique) var id: UUID
    var date: Date
    var minutes: Int

    /// Medium der Session: "reading" (Lesen) oder "listening" (Audio)
    var medium: String

    /// Zugehöriges Buch (optional)
    /// Cascade Delete: Wenn ein Buch gelöscht wird, verschwinden seine Sessions.
    @Relationship(deleteRule: .cascade) var book: BookEntity?

    init(
        id: UUID = UUID(),
        date: Date,
        minutes: Int,
        book: BookEntity?,
        medium: String = "reading"
    ) {
        self.id = id
        self.date = date
        self.minutes = minutes
        self.book = book
        self.medium = medium
    }
}
