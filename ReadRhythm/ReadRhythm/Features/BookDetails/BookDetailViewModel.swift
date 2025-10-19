//
//  BookDetailViewModel.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 19.10.25.
//

import SwiftUI
import SwiftData

/// ViewModel für BookDetail: orchestriert das Hinzufügen und Validieren von Sessions.
/// Warum → Wie
/// - Warum: Trennung von Logik & UI; hält State für AddSessionSheet und Fehler.
/// - Wie: Nutzt SessionRepository (lokal oder später API) und reagiert via @Published States.
@MainActor
final class BookDetailViewModel: ObservableObject {
    // MARK: - Dependencies
    private var sessionRepo: SessionRepository?

    // MARK: - UI State
    @Published var showAddSessionSheet: Bool = false
    @Published var errorMessageKey: LocalizedStringKey?

    // MARK: - Setup
    func bind(context: ModelContext) {
        if sessionRepo == nil {
            sessionRepo = LocalSessionRepository(context: context)
            #if DEBUG
            print("[BookDetailVM] Repository bound to ModelContext")
            #endif
        }
    }

    // MARK: - Actions
    func addSession(for book: BookEntity, minutes: Int, date: Date) {
        guard let repo = sessionRepo else {
            errorMessageKey = "session.add.error"
            return
        }
        guard minutes > 0 else {
            errorMessageKey = "session.add.validation.minutes"
            return
        }
        do {
            _ = try repo.addSession(for: book, minutes: minutes, date: date)
            #if DEBUG
            print("[BookDetailVM] +Session: \(minutes)m @\(date) for \(book.title)")
            #endif
        } catch {
            #if DEBUG
            print("[BookDetailVM] Add session failed: \(error.localizedDescription)")
            #endif
            errorMessageKey = "session.add.error"
        }
    }
}
