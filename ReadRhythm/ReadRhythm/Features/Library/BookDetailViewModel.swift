//
//  BookDetailViewModel.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 17.10.25.
//


//
//  BookDetailViewModel.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 17.10.25.
//

import Foundation
import SwiftUI
import SwiftData

/// ViewModel für BookDetail (Refactor-/Portfolio-Niveau)
/// - Verantwortlich für: Sheet-State, Fehlerzustand, und Orchestrierung des Session-Adds.
/// - Persistenz erfolgt via SessionRepository (LocalSessionRepository).
@MainActor
final class BookDetailViewModel: ObservableObject {

    // MARK: - Dependencies
    private var sessionRepo: SessionRepository?

    // MARK: - UI State
    @Published var showAddSessionSheet = false
    @Published var errorMessageKey: LocalizedStringKey?

    // MARK: - Setup
    /// Bindet den SwiftData-ModelContext und initialisiert das Repository einmalig.
    func bind(context: ModelContext) {
        if sessionRepo == nil {
            sessionRepo = LocalSessionRepository(context: context)
            #if DEBUG
            print("[BookDetailVM] Repository bound to ModelContext")
            #endif
        }
    }

    // MARK: - Actions
    /// Fügt eine Session hinzu (validiert Minuten, delegiert an Repository).
    func addSession(for book: BookEntity, minutes: Int, date: Date) {
        guard let repo = sessionRepo else { return }
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
