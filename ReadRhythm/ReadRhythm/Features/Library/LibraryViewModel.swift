// MARK: - Library ViewModel / Bibliotheks-ViewModel
// Steuert CRUD-Flows für lokale Bücher und Toast-Feedback /
// Drives local book CRUD flows and toast feedback in the library feature.


import Foundation
import SwiftUI
import SwiftData

/// ViewModel für die Library-Ansicht / ViewModel powering the library screen.
/// Orchestriert Add/Delete, Toast-Feedback und Repository-Binding /
/// Orchestrates add/delete flows, toast feedback, and repository binding.
/// Die Liste der Bücher kommt reaktiv via @Query /
/// The book list itself is supplied reactively via `@Query`.
@MainActor
final class LibraryViewModel: ObservableObject {

    // MARK: - Persistence
    // Repository wird lazily gebunden / Repository is bound lazily
    private var repository: BookRepository?

    // MARK: - UI State
    @Published var showAddSheet = false
    @Published var errorMessageKey: LocalizedStringKey?
    /// Kurzlebige UI-Rückmeldung (i18n-Key) / Ephemeral UI feedback using i18n keys
    @Published var toastMessageKey: String? = nil

    // MARK: - Public Setup

    /// Muss aus der View (z. B. .onAppear) aufgerufen werden /
    /// Needs to be invoked from the view (e.g. `.onAppear`).
    /// Bindet den SwiftData-Kontext an das Repository /
    /// Binds the SwiftData context to the repository instance.
    func bind(context: ModelContext) {
        // Nur einmal binden / Bind only once
        if repository == nil {
            repository = LocalBookRepository(context: context)
            #if DEBUG
            print("[LibraryViewModel] Repository bound to ModelContext")
            #endif
        }
    }

    // MARK: - Toast Helper

    /// Zeigt eine kurze Rückmeldung an und blendet sie wieder aus /
    /// Shows a short feedback toast and hides it automatically.
    private func showToast(_ key: String, duration: UInt64 = 1_500_000_000) {
        toastMessageKey = key

        Task { [weak self] in
            try? await Task.sleep(nanoseconds: duration)
            await MainActor.run {
                if self?.toastMessageKey == key {
                    self?.toastMessageKey = nil
                }
            }
        }
    }

    // MARK: - Actions

    /// Fügt ein Buch lokal hinzu (Sheet-Flow) /
    /// Adds a book locally through the add-sheet flow.
    /// - title: Titel aus dem Sheet / Title provided by the sheet
    /// - author: Autor aus dem Sheet / Optional author provided by the sheet
    func addBook(title: String, author: String?) {
        guard let repository else { return }

        // Normalisiert Eingaben fürs Datenmodell / Normalizes inputs for the data model
        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedAuthor = (author ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard cleanedTitle.isEmpty == false else {
            // Keine leeren Titel speichern / Do not persist empty titles
            errorMessageKey = "library.add.error"
            showToast("toast.error")
            return
        }

        // Manuell hinzugefügte Bücher / Manually added books:
        // - Eigene sourceID / Own sourceID
        // - Kein Cover / No cover asset
        // - Quelle "User Added" / Source labeled "User Added"
        do {
            _ = try repository.add(
                title: cleanedTitle,
                author: cleanedAuthor,
                subtitle: nil,
                publisher: nil,
                publishedDate: nil,
                pageCount: nil,
                language: nil,
                categories: [],
                descriptionText: nil,
                thumbnailURL: nil,
                infoLink: nil,
                previewLink: nil,
                sourceID: UUID().uuidString,
                source: "User Added"
            )

            #if DEBUG
            print("[LibraryViewModel] Book added: \(cleanedTitle)")
            #endif

            showToast("toast.added")
        } catch {
            #if DEBUG
            print("[LibraryViewModel] Add failed: \(error.localizedDescription)")
            #endif
            errorMessageKey = "library.add.error"
            showToast("toast.error")
        }
    }

    /// Löscht ein Buch anhand des IndexSets aus der aktuell sichtbaren Liste /
    /// Deletes books based on the index set coming from the visible list.
    func delete(at offsets: IndexSet, from books: [BookEntity]) {
        guard let repository else { return }

        for index in offsets {
            let book = books[index]

            do {
                try repository.delete(book)

                #if DEBUG
                print("[LibraryViewModel] Deleted book: \(book.title)")
                #endif

                showToast("toast.deleted")
            } catch {
                #if DEBUG
                print("[LibraryViewModel] Delete failed: \(error.localizedDescription)")
                #endif

                errorMessageKey = "library.delete.error"
                showToast("toast.error")
            }
        }
    }
}
