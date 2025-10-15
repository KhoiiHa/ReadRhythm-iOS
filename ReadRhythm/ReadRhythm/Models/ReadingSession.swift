import Foundation
import SwiftData

@Model
final class ReadingSession {
    @Attribute(.unique) var id: UUID
    var startedAt: Date
    var endedAt: Date?
    var durationSeconds: Int

    // Optional relationship to a Book (unowned to avoid cycles in minimal example)
    var book: Book?

    init(id: UUID = UUID(), startedAt: Date = Date(), endedAt: Date? = nil, durationSeconds: Int = 0, book: Book? = nil) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.durationSeconds = durationSeconds
        self.book = book
    }
}
