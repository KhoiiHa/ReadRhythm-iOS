//
//  DiscoverViewModel.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 15.10.25.
//

import Foundation
import SwiftData
// Remote search domain model & repo live in API/ and Repositories/
// (Make sure these targets are included in the same build)

@MainActor
final class DiscoverViewModel: ObservableObject {
    // MARK: - UI State (Discover)
    @Published var selectedCategory: DiscoverCategory? = nil
    @Published var searchQuery: String = ""
    @Published private(set) var results: [RemoteBook] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil

    // MARK: - Local Library (kept for future cross-reference / "Add to Library" flow)
    private var allBooks: [BookEntity] = []
    private(set) var filteredBooks: [BookEntity] = []

    // MARK: - Dependencies
    // Local data service stays for Library preview/Lookups
    private let dataService = DataService.shared
    // Remote search repository (injectable for tests)
    private let searchRepository: BookSearchRepository
    // Network status (injectable; default = NetworkStatusMonitor.shared)
    private let networkStatus: NetworkStatusProviding

    // MARK: - Init
    init(
        searchRepository: BookSearchRepository = DefaultBookSearchRepository(api: BooksAPIClient(network: NetworkClient())),
        networkStatus: NetworkStatusProviding = NetworkStatusMonitor.shared
    ) {
        self.searchRepository = searchRepository
        self.networkStatus = networkStatus
    }

    func loadBooks(from context: ModelContext) {
        allBooks = dataService.fetchBooks(from: context)
        filteredBooks = allBooks
        #if DEBUG
        print("📚 [DiscoverVM] loaded local library: \(allBooks.count) books")
        #endif
    }

    /// Setzt die Discover-Kategorie (für vordefinierte Bundles) und triggert eine Suche.
    func applyFilter(category: DiscoverCategory?) {
        selectedCategory = category
        Task { await searchBooks(forceRefresh: true) }
    }

    /// Führt eine Suche aus. Leerer String zeigt lokale Library (Fallback) an.
    func applySearch() {
        let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty {
            // Leere Eingabe: keine Remote-Suche, lokale Liste zeigen (UI-Entscheidung)
            results = []
            filteredBooks = allBooks
            errorMessage = nil
            return
        }
        Task { await searchBooks(forceRefresh: true) }
    }

    /// Remote-Suche über das BookSearchRepository.
    /// Regel: Wenn eine manuelle Suche (searchQuery) vorhanden ist, hat sie Vorrang vor der Kategorie.
    func searchBooks(forceRefresh: Bool = false) async {
        let manual = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        let effectiveQuery: String = {
            if !manual.isEmpty { return manual }
            if let cat = selectedCategory { return cat.query }
            return "" // kein Trigger
        }()

        guard !effectiveQuery.isEmpty else {
            #if DEBUG
            print("🔎 [DiscoverVM] search skipped (no query / no category)")
            #endif
            results = []
            errorMessage = nil
            return
        }

        // Offline-Fallback: keine Remote-Suche, lokale Library zeigen
        if networkStatus.isOnline == false {
            #if DEBUG
            print("📴 [DiscoverVM] offline → fallback to local library (\(allBooks.count) items)")
            #endif
            results = []
            filteredBooks = allBooks
            // i18n-Key, wird im UI lokalisiert (siehe Core/ErrorHandling)
            errorMessage = "error.network.offline"
            return
        }

        isLoading = true
        errorMessage = nil
        do {
            let items = try await searchRepository.search(
                query: effectiveQuery,
                maxResults: 20,
                forceRefresh: forceRefresh
            )
            #if DEBUG
            print("✅ [DiscoverVM] \(items.count) results for \"\(effectiveQuery)\"")
            #endif
            await MainActor.run {
                self.results = items
                self.isLoading = false
            }
        } catch {
            #if DEBUG
            print("⛔️ [DiscoverVM] search error:", error)
            #endif
            await MainActor.run {
                self.results = []
                self.isLoading = false
                self.errorMessage = error.asUserMessage
            }
        }
    }
}
