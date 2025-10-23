//
//  LibraryViewModel.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 15.10.25.
//


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
/// Verantwortlich für das Orchestrieren von BookRepository-Operationen (Add/Delete) und UI-Status.
/// SwiftData-`@Query` in der View liefert die aktuelle Buchliste automatisch.
@MainActor
final class LibraryViewModel: ObservableObject {
    // MARK: - Properties
    private var repository: BookRepository?
    @Published var showAddSheet = false
    @Published var errorMessageKey: LocalizedStringKey?
    /// Kurzlebige UI-Rückmeldung (i18n-Key), z. B. "toast.added" / "toast.deleted" / "toast.error"
    @Published var toastMessageKey: String? = nil

    // MARK: - Setup
    /// Bindet den SwiftData-Kontext und initialisiert das Repository, falls nicht vorhanden.
    func bind(context: ModelContext) {
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
    /// Fügt ein Buch hinzu, nutzt Repository und behandelt Fehler.
    func addBook(title: String, author: String?) {
        guard let repository else { return }
        do {
            _ = try repository.add(title: title, author: author)
            #if DEBUG
            print("[LibraryViewModel] Book added: \(title)")
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

    /// Löscht ein Buch anhand des IndexSets aus der Query-Liste.
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
