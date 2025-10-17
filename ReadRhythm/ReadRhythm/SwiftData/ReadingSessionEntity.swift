//
//  ReadingSessionEntity.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 13.10.25.
//

import Foundation
import SwiftData

@Model
final class ReadingSessionEntity {
    @Attribute(.unique) var id: UUID
    var date: Date
    var minutes: Int

    // Beziehung zum Buch
    @Relationship var book: BookEntity

    init(id: UUID = UUID(),
         date: Date,
         minutes: Int,
         book: BookEntity) {
        self.id = id
        self.date = date
        self.minutes = minutes
        self.book = book
    }
}
