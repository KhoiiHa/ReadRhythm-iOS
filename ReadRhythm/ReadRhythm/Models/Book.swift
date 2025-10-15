import Foundation
import SwiftData

@Model
final class Book {
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
