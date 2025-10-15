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
    var author: String
    var createdAt: Date

    init(id: UUID = UUID(),
         title: String,
         author: String,
         createdAt: Date = .init()) {
        self.id = id
        self.title = title
        self.author = author
        self.createdAt = createdAt
    }
}
