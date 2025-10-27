// Legacy SwiftData model retained for historical reference.
// This snapshot describes the early ReadingSession schema and is archived for migration guidance only.
import Foundation
import SwiftData

@available(*, deprecated, message: "Legacy SwiftData model kept only for historical context. Schedule removal after migrations are complete.")
@Model
final class LegacyReadingSessionSnapshot {
    @Attribute(.unique) var id: UUID
    var startedAt: Date
    var endedAt: Date?
    var durationSeconds: Int

    // Optional relationship to a LegacyBook (unowned to avoid cycles in minimal example)
    var book: LegacyBook?

    init(
        id: UUID = UUID(),
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        durationSeconds: Int = 0,
        book: LegacyBook? = nil
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.durationSeconds = durationSeconds
        self.book = book
    }
}
