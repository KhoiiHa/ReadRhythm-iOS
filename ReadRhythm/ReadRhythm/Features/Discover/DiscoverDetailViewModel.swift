//
//  DiscoverDetailViewModel.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 20.10.25.
//

import Foundation
import SwiftData

@MainActor
final class DiscoverDetailViewModel: ObservableObject {
    @Published var title: String
    @Published var author: String?
    @Published var summary: String?

    let book: BookEntity

    init(book: BookEntity, summary: String? = nil) {
        self.book = book
        self.title = book.title
        self.author = book.author
        self.summary = summary
    }
}
