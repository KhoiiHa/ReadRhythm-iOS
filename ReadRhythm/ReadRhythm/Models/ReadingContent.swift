//
//  ReadingContent.swift
//  ReadRhythm
//
//  Lightweight model describing paged reading content for the demo reader.
//

import Foundation

struct ReadingContent: Identifiable, Hashable {
    let id: String
    let bookID: String
    let title: String?
    let pages: [String]

    init(id: String, bookID: String, title: String? = nil, pages: [String]) {
        self.id = id
        self.bookID = bookID
        self.title = title
        self.pages = pages
    }
}
