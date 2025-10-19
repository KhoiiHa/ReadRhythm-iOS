//
//  Book.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 13.10.25.
//

import Foundation
import SwiftData

@Model
final class BookEntity {
    @Attribute(.unique) var id: UUID
    var title: String
    var author: String?        // ⬅️ Optional, um Dummy-Daten zuzulassen
    var createdAt: Date
    var normalizedTitle: String // ⬅️ Für saubere Sortierung & Suche (optional)

    // Beziehung zu Sessions
    @Relationship(deleteRule: .cascade, inverse: \ReadingSessionEntity.book)
    var sessions: [ReadingSessionEntity] = []

    init(
        id: UUID = UUID(),
        title: String,
        author: String? = nil,
        createdAt: Date = .init()
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.createdAt = createdAt
        self.normalizedTitle = title.lowercased()
    }
}
