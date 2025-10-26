//
//  LocalSessionRepository.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 17.10.25.
//

import SwiftData
import Foundation

/// SwiftData-Implementierung des SessionRepository.
@MainActor
final class LocalSessionRepository: SessionRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    /// Speichert eine Lese-Session über die neue Phase-9 API.
    /// Diese Methode erfüllt das `SessionRepository`-Protokoll,
    /// das vom FocusModeViewModel verwendet wird.
    ///
    /// Kontext:
    ///   FocusMode ruft `saveSession(book:minutes:date:medium:)` auf,
    ///   nicht mehr direkt SwiftData.
    ///
    /// Warum:
    ///   - MVVM + Repository Pattern
    ///   - Testbarkeit (Mock in Preview)
    ///   - Vorbereitung auf "medium" (reading / listening)
    ///
    /// Wie:
    ///   - Erstellt `ReadingSessionEntity`
    ///   - Fügt sie in den ModelContext ein
    ///   - Speichert Context
    @discardableResult
    func saveSession(
        book: BookEntity?,
        minutes: Int,
        date: Date,
        medium: String
    ) throws -> ReadingSessionEntity {
        precondition(minutes > 0, "Session minutes must be positive")

        // ReadingSessionEntity bekommt in Phase 9 / 10 ein optionales `book`
        // und ein `medium`-Feld. Falls `book` nil ist, speichern wir
        // trotzdem eine Session (freie Lesezeit).
        let session = ReadingSessionEntity(
            date: date,
            minutes: minutes,
            book: book,
            medium: medium
        )

        context.insert(session)

        do {
            try context.save()
            #if DEBUG
            DebugLogger.log("[LocalSessionRepository] saveSession → \(minutes)min | \(medium) | \(date.formatted()) | Book: \(book?.title ?? "nil")")
            #endif
            return session
        } catch {
            #if DEBUG
            DebugLogger.log("❌ [LocalSessionRepository] saveSession failed: \(error.localizedDescription)")
            #endif
            throw error
        }
    }

    @available(*, deprecated, message: "Benutze saveSession(book:minutes:date:medium:) statt addSession(for:minutes:date:)")
    /// SwiftData-Implementierung des SessionRepository.
    @available(*, deprecated, message: "Benutze saveSession(book:minutes:date:medium:), das auch 'medium' persisted.")
    @discardableResult
    func addSession(for book: BookEntity, minutes: Int, date: Date) throws -> ReadingSessionEntity {
        try saveSession(
            book: book,
            minutes: minutes,
            date: date,
            medium: "reading"
        )
    }
    /// Löscht eine ReadingSessionEntity aus SwiftData.
    /// Kontext → Warum → Wie:
    /// - Kontext: Diese Methode ergänzt die Repository-Schnittstelle um die Delete-Logik.
    /// - Warum: Sessions sollen über die UI (z. B. Swipe-to-Delete) entfernt werden können.
    /// - Wie: Die Session wird aus dem ModelContext gelöscht und gespeichert.
    func deleteSession(_ session: ReadingSessionEntity) throws {
        context.delete(session)
        do {
            try context.save()
            #if DEBUG
            DebugLogger.log("[LocalSessionRepository] Deleted session \(session.id)")
            #endif
        } catch {
            #if DEBUG
            DebugLogger.log("❌ [LocalSessionRepository] Delete failed: \(error.localizedDescription)")
            #endif
            throw error
        }
    }
}
