//
//  DiscoverViewModel.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 15.10.25.
//

import Foundation
import SwiftData

@MainActor
final class DiscoverViewModel: ObservableObject {
    @Published var selectedCategory: String? = nil
    @Published var searchQuery: String = ""

    private var allBooks: [BookEntity] = []
    private(set) var filteredBooks: [BookEntity] = []

    // Später wird hier der Repo/Service injiziert
    private let dataService = DataService.shared

    func loadBooks(from context: ModelContext) {
        allBooks = dataService.fetchBooks(from: context)
        filteredBooks = allBooks
    }

    func applyFilter(category: String?) {
        selectedCategory = category
        // TODO: Kategorie-basiertes Filtern (später nach Genre / Tag)
        filteredBooks = allBooks
    }

    func applySearch() {
        guard searchQuery.isEmpty == false else {
            filteredBooks = allBooks
            return
        }
        filteredBooks = allBooks.filter {
            $0.title.localizedCaseInsensitiveContains(searchQuery)
            || ($0.author?.localizedCaseInsensitiveContains(searchQuery) ?? false)
        }
    }
}
