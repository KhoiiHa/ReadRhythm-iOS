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

    /// Kurzlebige UI-Rückmeldung (i18n-Key), z. B. "toast.added" / "toast.duplicate"
    @Published var toastMessageKey: String? = nil

    // MARK: - Local Library (kept for future cross-reference / "Add to Library" flow)
    private var allBooks: [BookEntity] = []
    private(set) var filteredBooks: [BookEntity] = []

    // Debounce-Task für Tippen in der Suche (verhindert Request-Spam)
    private var searchTask: Task<Void, Never>? = nil

    // MARK: - Dependencies
    // Local data service stays for Library preview/Lookups
    private let dataService = DataService.shared
    // Remote search repository (injectable for tests)
    private let searchRepository: BookSearchRepositoryProtocol
    // Network status (injectable; default = NetworkStatusMonitor.shared)
    private let networkStatus: NetworkStatusProviding

    // MARK: - Init
    init(
        searchRepository: BookSearchRepositoryProtocol? = nil,
        networkStatus: NetworkStatusProviding = NetworkStatusMonitor.shared
    ) {
        // DiscoverViewModel is @MainActor; Erzeugung des Default-Repos hier ist actor-sicher.
        self.searchRepository = searchRepository ?? BookSearchRepository()
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
        // Offene Debounce-Suche abbrechen, Filter hat Vorrang
        searchTask?.cancel()
        searchTask = nil
        Task { await fetch(query: searchQuery, category: selectedCategory) }
    }

    /// Führt eine Suche aus. Leerer String zeigt lokale Library (Fallback) an.
    func applySearch() {
        let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty {
            // Leere Eingabe: keine Remote-Suche, lokale Liste zeigen (UI-Entscheidung)
            results = []
            filteredBooks = allBooks
            errorMessage = nil
            // Laufende Suche abbrechen
            searchTask?.cancel()
            searchTask = nil
            return
        }
        // Debounce: alte Suche abbrechen, neue in 300ms starten
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            // 300ms Ruhezeit, damit nicht jede Tastenfolge feuert
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard let self else { return }
            await self.fetch(query: q, category: self.selectedCategory)
        }
    }

    // MARK: - Centralized fetch via Repository (SWR)
    @MainActor
    private func fetch(query: String?, category: DiscoverCategory?) async {
        // 1) Manuelle Eingabe trimmen
        let manual = (query ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        // 2) Effektive Query bestimmen: manuell > Kategorie > leer
        let effectiveQuery: String = {
            if !manual.isEmpty { return manual }
            if let cat = category { return cat.query }   // Kategorie als Fallback für Autoload
            return ""
        }()

        guard !effectiveQuery.isEmpty else {
            results = []
            errorMessage = nil
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            #if DEBUG
            print("🔎 [DiscoverVM] fetch query='\(effectiveQuery)' category=\(category?.id ?? "nil")")
            #endif
            let items = try await searchRepository.search(
                query: effectiveQuery,
                category: category,
                maxResults: 20
            )
            self.results = items
            #if DEBUG
            print("✅ [DiscoverVM] results=\(items.count)")
            #endif
        } catch {
            #if DEBUG
            print("⛔️ [DiscoverVM] fetch failed:", error)
            #endif
            // Wenn bereits Cache-Ergebnisse sichtbar sind, leise bleiben; sonst Meldung zeigen
            if results.isEmpty {
                self.errorMessage = error.asUserMessage
            }
        }
    }

    /// Remote-Suche über das BookSearchRepository.
    /// Regel: Wenn eine manuelle Suche (searchQuery) vorhanden ist, hat sie Vorrang vor der Kategorie.
    func searchBooks(forceRefresh: Bool = false) async {
        let manual = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        let effectiveQuery: String = {
            if !manual.isEmpty { return manual }
            if let cat = selectedCategory { return cat.query }
            return ""
        }()

        guard !effectiveQuery.isEmpty else {
            #if DEBUG
            print("🔎 [DiscoverVM] search skipped (no query / no category)")
            #endif
            results = []
            errorMessage = nil
            return
        }

        await fetch(query: effectiveQuery, category: selectedCategory)
    }

    // MARK: - Toast Helper

    /// Zeigt eine kurze Rückmeldung an und blendet sie automatisch wieder aus.
    private func showToast(_ key: String, duration: UInt64 = 1_500_000_000) {
        toastMessageKey = key
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: duration)
            await MainActor.run {
                // Nur ausblenden, wenn der Toast noch derselbe ist (Race-Condition vermeiden)
                if self?.toastMessageKey == key {
                    self?.toastMessageKey = nil
                }
            }
        }
    }

    // MARK: - Add to Library (MVP happy path)

    /// Legt ein `RemoteBook` lokal als `BookEntity` in SwiftData an.
    /// - Parameters:
    ///   - remote: Ergebnis aus der Discover-Suche (Google Books).
    ///   - context: `ModelContext` aus der View (per `@Environment(\.modelContext)`).
    /// - Throws: Reicht Fehler als `AppError.saveFailed` nach oben.
    /// - Hinweis: MVP-Variante – **mit einfacher Duplikatsprüfung**, kein Cover-Download.
    func addToLibrary(from remote: RemoteBook, in context: ModelContext) throws {
        // Autorenplatzhalter „—“ nicht persistieren
        let author: String? = {
            let trimmed = remote.authors.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed == "—" ? nil : trimmed
        }()

        // 🔎 Duplikat-Check (Titel + Autor, case-insensitive, getrimmt)
        let newTitle = remote.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let newAuthor = (author ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if allBooks.contains(where: { existing in
            existing.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == newTitle &&
            (existing.author ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == newAuthor
        }) {
            #if DEBUG
            print("🔁 [DiscoverVM] duplicate ignored: \"\(remote.title)\" by \(author ?? "n/a")")
            #endif
            showToast("toast.duplicate")
            return
        }

        // Passe bei Bedarf an dein BookEntity-Init an
        let entity = BookEntity(
            title: remote.title,
            author: author
            // , createdAt: Date()
            // , source: "googleBooks"
        )

        context.insert(entity)
        do {
            try context.save()
            #if DEBUG
            print("📥 [DiscoverVM] added to library: \"\(remote.title)\" by \(author ?? "n/a")")
            #endif
            showToast("toast.added")

            // Lokale VM-Spiegelung aktualisieren (für Fallback/Sektionen)
            // SwiftData-Modelle besitzen standardmäßig kein `objectID`; wir haben oben bereits
            // einen Duplikat-Check (Titel+Autor). Daher können wir direkt einfügen.
            allBooks.insert(entity, at: 0)
            filteredBooks = allBooks
        } catch {
            #if DEBUG
            print("⛔️ [DiscoverVM] save failed:", error)
            #endif
            throw AppError.saveFailed
        }
    }
}
