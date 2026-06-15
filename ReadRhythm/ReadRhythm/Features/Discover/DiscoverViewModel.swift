import Foundation
import Combine
import SwiftData
import SwiftUI

@MainActor
final class DiscoverViewModel: ObservableObject {

    enum AddToLibraryResult: Equatable {
        case added
        case alreadyExists
        case failure
    }

    // MARK: - Published State für UI

    @Published var results: [RemoteBook] = []          // letzte API-Suchergebnisse
    @Published var isLoading: Bool = false             // Spinner in DiscoverAllView
    @Published var errorMessage: String? = nil         // lokalisierbarer Key für Fehler
    @Published var searchQuery: String = ""            // Textfeld in DiscoverAllView
    @Published var selectedCategory: DiscoverCategory? = nil

    @Published var allBooks: [BookEntity] = []         // ganze lokale Bibliothek
    @Published var filteredBooks: [BookEntity] = []    // ggf. gefiltert für UI

    @Published var toastText: String? = nil            // "Hinzugefügt", "Schon vorhanden", etc.

    /// Gemerkte (favorisierte) RemoteBooks in der Entdecken-Ansicht – in-memory State
    @Published var favoriteResultIDs: Set<String> = []

    private var toastDismissTask: Task<Void, Never>? = nil
    private var searchTask: Task<Void, Never>? = nil

    // MARK: - Dependencies

    private let bookSearchRepository: BookSearchRepositoryProtocol
    private var repository: any BookRepository

    /// Initializer
    /// Kontext: Wir injizieren ein BookRepository (z. B. LocalBookRepository),
    /// statt hier direkt auf PersistenceController.shared.mainContext zuzugreifen.
    /// Warum: Der Zugriff auf den SwiftData-ModelContext ist @MainActor-isoliert.
    /// Wie: DiscoverView kümmert sich darum, beim Erzeugen oder in onAppear
    ///      ein korrekt angebundenes Repository zu übergeben.
    init(
        repository: any BookRepository,
        bookSearchRepository: BookSearchRepositoryProtocol? = nil
    ) {
        self.repository = repository
        self.bookSearchRepository = bookSearchRepository ?? BookSearchRepository()
    }

    func updateRepository(_ repository: any BookRepository) {
        self.repository = repository
    }

    private func showToast(_ key: String) {
        toastDismissTask?.cancel()
        toastDismissTask = nil

        withAnimation(.easeInOut(duration: 0.3)) {
            toastText = key
        }

        toastDismissTask = Task { [weak self] in
            // Sleep for 2.5s; catch CancellationError so this Task remains non-throwing
            do {
                try await Task.sleep(nanoseconds: 2_500_000_000)
            } catch {
                // Task was likely cancelled; just exit quietly
                return
            }
            guard !Task.isCancelled else { return }
            await MainActor.run {
                guard let self else { return }
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.toastText = nil
                }
                self.toastDismissTask = nil
            }
        }

        DebugLogger.log("[DiscoverVM] toast=\(key)")
    }

    func cancelToast() {
        toastDismissTask?.cancel()
        toastDismissTask = nil

        guard toastText != nil else { return }

        withAnimation(.easeInOut(duration: 0.3)) {
            toastText = nil
        }
    }

    // MARK: - SwiftData / Lokale Bibliothek laden

    /// Holt alle gespeicherten Bücher aus SwiftData.
    /// Sortierung: neueste zuerst.
    func loadBooks() {
        do {
            let fetched = try repository.fetchBooks()
            allBooks = fetched
            filteredBooks = fetched
            DebugLogger.log("[DiscoverVM] loadBooks fetched \(fetched.count) items from SwiftData")
        } catch {
            DebugLogger.log("[DiscoverVM] loadBooks failed: \(error)")
        }
    }

    // MARK: - Suche / Kategorien

    /// Wird aufgerufen, wenn der Nutzer einen Kategorie-Chip antippt.
    /// Setzt `selectedCategory` und startet direkt eine Suche.
    func applyFilter(category: DiscoverCategory?) {
        selectedCategory = category
        DebugLogger.log("[DiscoverVM] applyFilter -> \(category?.rawValue ?? "nil")")
        applySearch()
    }

    /// Baut anhand von `searchQuery` oder der gesetzten `selectedCategory`
    /// den finalen Query-String und ruft dann die API.
    func applySearch() {
        searchTask?.cancel()
        searchTask = nil

        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        let category = selectedCategory
        let effectiveQuery: String
        if let cat = category {
            // feste Kategorie --> eigener Query-String
            effectiveQuery = categoryQuery(for: cat)
        } else if !trimmed.isEmpty {
            // freier Text
            effectiveQuery = trimmed
        } else {
            // weder Kategorie noch Text -> keine Remote-Suche
            DebugLogger.log("[DiscoverVM] applySearch skipped (no query)")
            results = []
            errorMessage = nil
            isLoading = false
            return
        }

        DebugLogger.log("[DiscoverVM] applySearch query='\(effectiveQuery)' category=\(selectedCategory?.rawValue ?? "nil")")

        isLoading = true
        errorMessage = nil

        searchTask = Task { [weak self] in
            guard let self else { return }
            let fetchResult = await self.repositoryFetch(query: effectiveQuery, category: category)

            guard Task.isCancelled == false else { return }

            await MainActor.run {
                guard Task.isCancelled == false else { return }

                self.isLoading = false
                switch fetchResult {
                case .success(let books):
                    self.results = books
                    self.errorMessage = nil
                case .failure(let err):
                    DebugLogger.log("[DiscoverVM] search failed: \(err)")
                    self.results = []
                    self.errorMessage = "error.network.generic"
                }
            }
        }
    }

    /// Baut den Google-Books-Query-String für eine vorgegebene Kategorie.
    private func categoryQuery(for category: DiscoverCategory) -> String {
        switch category {
        case .mindfulness:
            return #"mindfulness OR meditation OR \"stress relief\" OR \"inner peace\""#
        case .philosophy:
            return #"philosophy OR stoicism OR \"meaning of life\""#
        case .selfHelp, .psychology:
            return #"self improvement OR habits OR motivation OR psychology"#
        case .creativity:
            return #"creativity OR design OR writing OR inspiration"#
        case .wellness:
            return #"health OR sleep OR burnout OR recovery OR nutrition"#
        case .fictionRomance:
            return #"romance novel OR love story OR relationship fiction"#
        }
    }

    /// Wrappt den eigentlichen Netzwerkaufruf ans Repository.
    private func repositoryFetch(query: String, category: DiscoverCategory?) async -> Result<[RemoteBook], Error> {
        do {
            let books = try await bookSearchRepository.search(
                query: query,
                category: category,
                maxResults: 20
            )
            return .success(books)
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Favoriten (Herz-Icon)

    /// Merkt sich, ob ein RemoteBook in der Discover-Liste "geliked" wurde.
    /// Aktuell nur in-memory; kein Persistenz-Backend nötig für die UI.
    func toggleFavorite(for remote: RemoteBook) {
        let id = remote.id
        if favoriteResultIDs.contains(id) {
            favoriteResultIDs.remove(id)
        } else {
            favoriteResultIDs.insert(id)
            // Beim Favorisieren automatisch in die Bibliothek speichern
            _ = addToLibrary(from: remote)
        }
    }

    /// Liefert zurück, ob das übergebene RemoteBook gerade als Favorit markiert ist.
    func isFavorite(_ remote: RemoteBook) -> Bool {
        favoriteResultIDs.contains(remote.id)
    }

    // MARK: - In Bibliothek speichern

    /// Nimmt ein RemoteBook (API-Ergebnis), baut ein BookEntity,
    /// speichert es in SwiftData und aktualisiert lokale Arrays + Toast.
    @discardableResult
    func addToLibrary(from remote: RemoteBook) -> AddToLibraryResult {

        // Autor normalisieren (API kann "—" schicken oder leere Strings liefern)
        let normalizedAuthor: String = {
            let trimmed = remote.authorsDisplay.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed == "—" || trimmed.isEmpty {
                return ""
            }
            return trimmed
        }()

        // Duplikate verhindern:
        // 1) gleiche sourceID (Google Books Volume ID)
        // 2) gleicher (title + author), case-insensitive/trimmed
        let newTitleLC = remote.title
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        let newAuthorLC = normalizedAuthor
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        let isDuplicate = allBooks.contains { existing in

            // Fall 1: gleiche sourceID
            if existing.sourceID == remote.id {
                return true
            }

            // Fall 2: gleicher Titel + gleicher Autor
            let existingTitleLC = existing.title
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()

            let existingAuthorLC = existing.author
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()

            return (existingTitleLC == newTitleLC && existingAuthorLC == newAuthorLC)
        }

        if isDuplicate {
            DebugLogger.log("[DiscoverVM] duplicate -> \(remote.title)")
            showToast("toast.duplicate")
            return .alreadyExists
        }

        DebugLogger.log("[DiscoverVM] addToLibrary -> id=\(remote.id) subtitle=\(remote.subtitle ?? "-") publisher=\(remote.publisher ?? "-") date=\(remote.publishedDate ?? "-") pages=\(remote.pageCount?.description ?? "-") language=\(remote.language ?? "-") cats=\(remote.categories) info=\((remote.infoLink ?? remote.previewLink)?.absoluteString ?? "-") preview=\(remote.previewLink?.absoluteString ?? "-")")

        do {
            let saved = try repository.add(
                title: remote.title,
                author: normalizedAuthor,
                subtitle: remote.subtitle,
                publisher: remote.publisher,
                publishedDate: remote.publishedDate,
                pageCount: remote.pageCount,
                language: remote.language,
                categories: remote.categories,
                descriptionText: remote.description,
                thumbnailURL: remote.thumbnailURL?.absoluteString,
                infoLink: (remote.infoLink ?? remote.previewLink),
                previewLink: remote.previewLink,
                sourceID: remote.id,
                source: "Google Books"
            )

            // Sofort UI updaten → wichtig für direkte UI-Reaktion + Toast
            allBooks.insert(saved, at: 0)
            filteredBooks = allBooks

            showToast("toast.added")

            #if os(iOS)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            #endif

            DebugLogger.log("[DiscoverVM] saved book -> \(saved.title) [sourceID=\(saved.sourceID)]")
            return .added
        } catch {
            DebugLogger.log("[DiscoverVM] save failed: \(error)")
            if let nserr = error as NSError? {
                DebugLogger.log("[DiscoverVM] save failed domain=\(nserr.domain) code=\(nserr.code) userInfo=\(nserr.userInfo)")
            }
            showToast("toast.error")
            return .failure
        }
    }
}
