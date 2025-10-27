// Legacy SwiftData model retained for historical reference.
// This type existed in the early SwiftData prototype and is kept to aid future migrations.
import Foundation
import SwiftData

@available(*, deprecated, message: "Legacy SwiftData model kept only for historical context. Schedule removal after migrations are complete.")
@Model
final class LegacyBook {
    @Attribute(.unique) var id: UUID
    var title: String
    var author: String
    var createdAt: Date

    init(id: UUID = UUID(), title: String, author: String, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.author = author
        self.createdAt = createdAt
    }
}
