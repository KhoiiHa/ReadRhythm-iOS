//
//  LibraryViewModel.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 15.10.25.
//


import Foundation
import SwiftUI
import SwiftData

/// ViewModel für die Library-Ansicht.
/// Orchestriert Add/Delete, Toast-Feedback und Repository-Binding.
/// Die eigentliche Liste der Bücher kommt reaktiv aus der View via @Query.
@MainActor
final class LibraryViewModel: ObservableObject {

    // MARK: - Persistence
    private var repository: BookRepository?

    // MARK: - UI State
    @Published var showAddSheet = false
    @Published var errorMessageKey: LocalizedStringKey?
    /// Kurzlebige UI-Rückmeldung (i18n-Key), z. B. "toast.added" / "toast.deleted" / "toast.error"
    @Published var toastMessageKey: String? = nil

    // MARK: - Public Setup

    /// Muss aus der View aufgerufen werden (z. B. in .onAppear),
    /// damit das ViewModel Zugriff auf SwiftData bekommt.
    func bind(context: ModelContext) {
        // Nur einmal binden
        if repository == nil {
            repository = LocalBookRepository(context: context)
            #if DEBUG
            print("[LibraryViewModel] Repository bound to ModelContext")
            #endif
        }
    }

    // MARK: - Toast Helper

    /// Zeigt eine kurze Rückmeldung an und blendet sie automatisch wieder aus.
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

    /// Fügt ein Buch lokal hinzu. Das ist der Flow aus dem "Buch hinzufügen"-Sheet.
    /// - title: Titel aus dem Sheet (Pflichtfeld in der UI)
    /// - author: Autor aus dem Sheet (optional in der UI, aber wir speichern am Ende immer einen String)
    func addBook(title: String, author: String?) {
        guard let repository else { return }

        // Normalize Felder für unser Datenmodell:
        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedAuthor = (author ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard cleanedTitle.isEmpty == false else {
            // keine leeren Titel speichern
            errorMessageKey = "library.add.error"
            showToast("toast.error")
            return
        }

        // Manuell hinzugefügte Bücher haben:
        // - eigene generierte sourceID
        // - kein Cover
        // - Quelle "User Added"
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

    /// Löscht ein Buch anhand des IndexSets aus der aktuell sichtbaren Liste (`books` aus der View).
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
