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
    @Published var toastMessageKey: String?

    // MARK: - Setup
    func bind(context: ModelContext) {
        if sessionRepo == nil {
            sessionRepo = LocalSessionRepository(context: context)
            DebugLogger.log("[BookDetailVM] Repository bound to ModelContext")
        }
    }

    // MARK: - Toast Helper

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
    @discardableResult
    func addSession(for book: BookEntity, minutes: Int, date: Date) -> Bool {
        guard let repo = sessionRepo else {
            errorMessageKey = "session.add.error"
            return false
        }
        guard minutes > 0 else {
            errorMessageKey = "session.add.validation.minutes"
            return false
        }
        do {
            _ = try repo.saveSession(
                book: book,
                minutes: minutes,
                date: date,
                medium: "reading"
            )
            DebugLogger.log("[BookDetailVM] +Session: \(minutes)m @\(date) for \(book.title)")
            showToast("toast.sessionSaved")
            return true
        } catch {
            DebugLogger.log("[BookDetailVM] Add session failed: \(error.localizedDescription)")
            errorMessageKey = "session.add.error"
            return false
        }
    }
}
