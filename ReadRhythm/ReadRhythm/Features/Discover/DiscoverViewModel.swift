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

/// ViewModel für den Discover-Screen.
/// Zuständigkeiten:
///  - Lädt Bücher aus der Google Books API (über BookSearchRepository)
///  - Steuert Suchfeld, Kategorien und Ladezustände im UI
///  - Trennt Nutzer-Suchtext (`searchQuery`) von der tatsächlichen Request-Query (`activeRequestQuery`)
///
/// Warum diese Trennung?
///  - `searchQuery` ist, was die Nutzerin eintippt (Autor, Titel, Keyword).
///  - `activeRequestQuery` ist, was wir wirklich an die API schicken.
///    Das kann z. B. die kuratierte Kategorie-Query aus `DiscoverCategory` sein.
///
/// Ergebnis:
///  - Das Suchfeld zeigt keinen kryptischen Debug-String wie `subject:"mindfulness" OR ...`.
///  - Kategorien liefern sofort kuratierte Treffer.
///  - Eigene Eingaben der Nutzerin (z. B. "Colleen Hoover") überschreiben die Kategorie.
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

    /// Interne Query, die zuletzt wirklich zur API geschickt wurde.
    /// Wichtig: `searchQuery` ist nur der sichtbare Text im Suchfeld.
    /// `activeRequestQuery` kann eine kuratierte Kategorie-Query sein.
    private var activeRequestQuery: String = ""

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

        // laufende, getimte Suche abbrechen – Kategorie hat Vorrang
        searchTask?.cancel()
        searchTask = nil

        // Wenn eine Kategorie gewählt wurde:
        if let cat = category {
            // Wir überschreiben NICHT das Suchfeld (`searchQuery` bleibt lesbar für die Userin).
            // Stattdessen setzen wir nur die aktive Request-Query und holen Daten.
            activeRequestQuery = cat.query

            Task {
                await fetch(query: activeRequestQuery, category: cat)
            }
            return
        }

        // Wenn Kategorie entfernt wurde:
        activeRequestQuery = ""

        // Falls User gerade nichts sucht -> wieder lokale Library zeigen
        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            results = []
            filteredBooks = allBooks
            errorMessage = nil
        } else {
            // User hat was eingegeben -> suche nach diesem Text
            Task {
                await fetch(query: trimmed, category: nil)
            }
        }
    }

    /// Führt eine Suche aus. Leerer String zeigt lokale Library (Fallback) an.
    func applySearch() {
        let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        // Wenn das Feld leer ist:
        if q.isEmpty {
            // Kein Remote-Call, einfach lokale Daten/Fallback zeigen
            results = []
            filteredBooks = allBooks
            errorMessage = nil

            // Laufende Debounce-Suche abbrechen
            searchTask?.cancel()
            searchTask = nil
            return
        }

        // Wir haben Nutzereingabe -> sie dominiert jetzt die Kategorie-Query.
        activeRequestQuery = q

        // Debounce: alte Suche abbrechen, neue verzögert starten (300ms)
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
            guard let self else { return }
            await self.fetch(query: q, category: self.selectedCategory)
        }
    }

    // MARK: - Centralized fetch via Repository (SWR)
    @MainActor
    private func fetch(query: String?, category: DiscoverCategory?) async {
        // 1) Manuell übergebene Query trimmen
        let manual = (query ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        // 2) Effektive Query bestimmen:
        //    - falls Nutzereingabe vorhanden, nimm diese
        //    - sonst nimm die kuratierte Kategorie-Query
        let effectiveQuery: String = {
            if !manual.isEmpty { return manual }
            if let cat = category { return cat.query }
            return ""
        }()

        guard !effectiveQuery.isEmpty else {
            // Nichts zu suchen -> zurück in lokalen Fallback-Zustand
            results = []
            errorMessage = nil
            return
        }

        isLoading = true
        errorMessage = nil

        #if DEBUG
        print("🔎 [DiscoverVM] fetch query='\(effectiveQuery)' category=\(category?.id ?? "nil")")
        #endif

        // Wenn wir offline sind, kein Netzwerk-Call.
        // Stattdessen sofort lesbare Fehlermeldung anzeigen.
        if networkStatus.isOnline == false {
            #if DEBUG
            print("📵 [DiscoverVM] offline -> skip remote call")
            #endif

            // Nur anzeigen, wenn wir nicht ohnehin schon Ergebnisse haben.
            if results.isEmpty {
                self.errorMessage = "error.network.offline"
            }

            isLoading = false
            return
        }

        do {
            let items = try await searchRepository.search(
                query: effectiveQuery,
                category: category,
                maxResults: 20
            )

            // Deduplizieren nach Buch-ID, weil Google Books bei OR-Queries
            // manchmal identische Volumes mehrfach liefert.
            let unique: [RemoteBook] = Array(
                Dictionary(grouping: items, by: { $0.id })
                    .values
                    .compactMap { $0.first }
            )

            self.results = unique

            #if DEBUG
            print("✅ [DiscoverVM] results(unique)=\(unique.count)")
            #endif
        } catch let netErr as NetworkError {
            #if DEBUG
            print("⛔️ [DiscoverVM] network error:", netErr)
            #endif

            if results.isEmpty {
                // Zeig lokalisierbaren String aus Localizable.strings
                self.errorMessage = netErr.asUserMessage
            }
        } catch {
            #if DEBUG
            print("⛔️ [DiscoverVM] unexpected error:", error)
            #endif

            if results.isEmpty {
                // Fallback: generische Discover-Fehlermeldung
                self.errorMessage = "discover.error.generic"
            }
        }

        isLoading = false
    }

    /// Remote-Suche über das BookSearchRepository.
    /// Regel: Wenn eine manuelle Suche (searchQuery) vorhanden ist, hat sie Vorrang vor der Kategorie.
    func searchBooks(forceRefresh: Bool = false) async {
        // Diese Methode delegiert jetzt an `fetch` mit entweder User-Query oder Kategorie.
        let manual = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        // Priorität: Nutzereingabe > Kategorie
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

        activeRequestQuery = effectiveQuery
        await fetch(query: effectiveQuery, category: selectedCategory)
    }

    // MARK: - Toast Helper

    /// Zeigt eine kurze Rückmeldung im UI (Toast) und blendet sie wieder aus.
    /// Erwartet i18n-Keys wie "toast.added" / "toast.duplicate" / "toast.error".
    /// Läuft vollständig auf dem MainActor.
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
    /// Hinweis:
    /// Wenn beim allerersten App-Start SwiftData den Store noch initialisiert
    /// (Migration/Seeding) und wir hier gleichzeitig speichern wollen,
    /// kann der Simulator laute CoreData-/SQLite-Warnungen loggen.
    /// Das fixen wir später separat durch einen kleinen "Store ready"-Check
    /// bevor wir speichern. API / Suche müssen zuerst sauber laufen.
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
            showToast("toast.error")
            throw AppError.saveFailed
        }
    }
}
