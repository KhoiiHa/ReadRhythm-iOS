import Foundation
import Combine
import SwiftData

@MainActor
final class DiscoverViewModel: ObservableObject {

    // MARK: - Published State für UI

    @Published var results: [RemoteBook] = []          // letzte API-Suchergebnisse
    @Published var isLoading: Bool = false             // Spinner in DiscoverAllView
    @Published var errorMessage: String? = nil         // lokalisierbarer Key für Fehler
    @Published var searchQuery: String = ""            // Textfeld in DiscoverAllView
    @Published var selectedCategory: DiscoverCategory? = nil

    @Published var allBooks: [BookEntity] = []         // ganze lokale Bibliothek
    @Published var filteredBooks: [BookEntity] = []    // ggf. gefiltert für UI

    @Published var toastText: String? = nil            // "Hinzugefügt", "Schon vorhanden", etc.

    // MARK: - Dependencies

    private let bookSearchRepository = BookSearchRepository()
    private var repository: any BookRepository

    init(repository: (any BookRepository) = LocalBookRepository(context: PersistenceController.shared.mainContext)) {
        self.repository = repository
    }

    func updateRepository(_ repository: any BookRepository) {
        self.repository = repository
    }

    private func showToast(_ key: String) {
        toastText = key
        #if DEBUG
        print("🍞 [DiscoverVM] toast =", key)
        #endif
    }

    // MARK: - SwiftData / Lokale Bibliothek laden

    /// Holt alle gespeicherten Bücher aus SwiftData.
    /// Sortierung: neueste zuerst.
    func loadBooks() {
        do {
            let fetched = try repository.fetchBooks()
            allBooks = fetched
            filteredBooks = fetched
            #if DEBUG
            print("📚 [DiscoverVM] loadBooks fetched \(fetched.count) items from SwiftData")
            #endif
        } catch {
            #if DEBUG
            print("💥 [DiscoverVM] loadBooks failed:", error)
            #endif
        }
    }

    // MARK: - Suche / Kategorien

    /// Wird aufgerufen, wenn der Nutzer einen Kategorie-Chip antippt.
    /// Setzt `selectedCategory` und startet direkt eine Suche.
    func applyFilter(category: DiscoverCategory?) {
        selectedCategory = category
        #if DEBUG
        print("🔎 [DiscoverVM] applyFilter -> \(category?.rawValue ?? "nil")")
        #endif
        applySearch()
    }

    /// Baut anhand von `searchQuery` oder der gesetzten `selectedCategory`
    /// den finalen Query-String und ruft dann die API.
    func applySearch() {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        let effectiveQuery: String
        if let cat = selectedCategory {
            // feste Kategorie --> eigener Query-String
            effectiveQuery = categoryQuery(for: cat)
        } else if !trimmed.isEmpty {
            // freier Text
            effectiveQuery = trimmed
        } else {
            // weder Kategorie noch Text -> keine Remote-Suche
            #if DEBUG
            print("🌐 [DiscoverVM] applySearch skipped (no query)")
            #endif
            results = []
            errorMessage = nil
            isLoading = false
            return
        }

        #if DEBUG
        print("🌐 [DiscoverVM] applySearch query='\(effectiveQuery)' category=\(selectedCategory?.rawValue ?? "nil")")
        #endif

        isLoading = true
        errorMessage = nil

        Task {
            let fetchResult = await repositoryFetch(query: effectiveQuery)

            await MainActor.run {
                self.isLoading = false
                switch fetchResult {
                case .success(let books):
                    self.results = books
                    self.errorMessage = nil
                case .failure(let err):
                    #if DEBUG
                    print("💥 [DiscoverVM] search failed:", err)
                    #endif
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
    private func repositoryFetch(query: String) async -> Result<[RemoteBook], Error> {
        do {
            let books = try await bookSearchRepository.search(
                query: query,
                category: selectedCategory,
                maxResults: 20
            )
            return .success(books)
        } catch {
            return .failure(error)
        }
    }

    // MARK: - In Bibliothek speichern

    /// Nimmt ein RemoteBook (API-Ergebnis), baut ein BookEntity,
    /// speichert es in SwiftData und aktualisiert lokale Arrays + Toast.
    func addToLibrary(from remote: RemoteBook) {

        // Autor normalisieren (API kann "—" schicken oder leere Strings liefern)
        let normalizedAuthor: String = {
            let trimmed = remote.authors.trimmingCharacters(in: .whitespacesAndNewlines)
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
            #if DEBUG
            print("🔁 [DiscoverVM] duplicate -> \(remote.title)")
            #endif
            showToast("toast.duplicate")
            return
        }

        do {
            let saved = try repository.add(
                title: remote.title,
                author: normalizedAuthor,
                thumbnailURL: remote.thumbnailURL?.absoluteString,
                sourceID: remote.id,
                source: "Google Books"
            )

            // Sofort UI updaten → wichtig für direkte UI-Reaktion + Toast
            allBooks.insert(saved, at: 0)
            filteredBooks = allBooks

            showToast("toast.added")

            #if DEBUG
            print("✅ [DiscoverVM] saved book -> \(saved.title) [sourceID=\(saved.sourceID)]")
            #endif
        } catch {
            #if DEBUG
            print("⛔️ [DiscoverVM] save failed:", error)
            if let nserr = error as NSError? {
                print("⛔️ [DiscoverVM] save failed domain=\(nserr.domain) code=\(nserr.code) userInfo=\(nserr.userInfo)")
            }
            #endif
            showToast("toast.error")
        }
    }
}
