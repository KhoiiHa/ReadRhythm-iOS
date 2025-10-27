// Kontext: Dieses Repository speichert und lädt ReadingSessions lokal via SwiftData.
// Warum: Die App braucht eine robuste Persistence-Schicht jenseits der ViewModels.
// Wie: Wir nutzen ModelContext-Operationen, um Sessions zu persistieren, zu lesen und zu löschen.
import SwiftData
import Foundation

/// SwiftData-Implementierung des SessionRepository.
@MainActor
final class LocalSessionRepository: SessionRepository {
    let context: ModelContext

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

// MARK: - Debug helpers / seeding
#if DEBUG
extension LocalSessionRepository {
    /// Fügt eine künstliche Session für Debug/Testzwecke hinzu.
    /// Wichtig: Diese Funktion wird NUR von Debug-UI (z. B. StatsView) aufgerufen,
    /// damit die View nie direkt mit SwiftData spricht.
    /// - Parameters:
    ///   - minutes: Anzahl der Minuten, die zur Session gezählt werden sollen (>0)
    ///   - medium: "reading" oder "listening"
    ///   - date: Datum/Zeit der Session (Default: jetzt)
    ///   - book: Optionales BookEntity (Default: nil)
    @discardableResult
    func debugAddSession(
        minutes: Int,
        medium: String,
        date: Date = Date(),
        book: BookEntity? = nil
    ) throws -> ReadingSessionEntity {
        precondition(minutes > 0, "Session minutes must be positive")

        let debugSession = ReadingSessionEntity(
            date: date,
            minutes: minutes,
            book: book,
            medium: medium
        )

        context.insert(debugSession)

        do {
            try context.save()
            DebugLogger.log("[LocalSessionRepository] debugAddSession → \(minutes)min | \(medium) | \(date.formatted()) | Book: \(book?.title ?? "nil")")
            return debugSession
        } catch {
            DebugLogger.log("❌ [LocalSessionRepository] debugAddSession failed: \(error.localizedDescription)")
            throw error
        }
    }
}
#endif
