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

    @discardableResult
    func addSession(for book: BookEntity, minutes: Int, date: Date) throws -> ReadingSessionEntity {
        precondition(minutes > 0, "Session minutes must be positive")

        let session = ReadingSessionEntity(date: date, minutes: minutes, book: book)
        context.insert(session)

        // Relationship pflegen, falls BookEntity.sessions existiert
        book.sessions.append(session)

        do {
            try context.save()
            #if DEBUG
            print("[LocalSessionRepository] Added Session → \(minutes) min | \(date.formatted()) | Book: \(book.title)")
            #endif
            return session
        } catch {
            #if DEBUG
            print("[LocalSessionRepository] Save failed: \(error.localizedDescription)")
            #endif
            throw error
        }
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
            print("[LocalSessionRepository] Deleted session \(session.id)")
            #endif
        } catch {
            #if DEBUG
            print("[LocalSessionRepository] Delete failed: \(error.localizedDescription)")
            #endif
            throw error
        }
    }
}
