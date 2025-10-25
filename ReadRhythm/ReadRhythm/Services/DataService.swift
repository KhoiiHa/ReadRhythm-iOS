//
//  DataService.swift
//  ReadRhythm
//
//  Central place for accessing and mutating SwiftData models
//  (Books, Sessions, Goals, …)
//

//
//  DataService.swift
//  ReadRhythm
//
//  Central place for accessing and mutating SwiftData models
//  (Books, Sessions, Goals, …)
//

import Foundation
import SwiftData
import OSLog

@MainActor
final class DataService {

    // MARK: - Logger (debug only)
    private let logger = Logger(subsystem: "ReadRhythm", category: "DataService")

    // MARK: - SwiftData
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - BOOKS
    // Fetch all saved books, newest first
    func fetchAllBooks() -> [BookEntity] {
        let descriptor = FetchDescriptor<BookEntity>(
            sortBy: [
                // sort by dateAdded descending
                SortDescriptor(\.dateAdded, order: .reverse),
                // tie-breaker: title ascending
                SortDescriptor(\.title, order: .forward)
            ]
        )

        do {
            let results = try context.fetch(descriptor)
            return results
        } catch {
            logger.error("❌ fetchAllBooks failed: \(error.localizedDescription)")
            return []
        }
    }

    /// Add a new book (typically from Google Books)
    /// - Parameters:
    ///   - sourceID: z.B. Google Books Volume ID
    ///   - title: Buchtitel (Pflicht)
    ///   - author: Autoren-String
    ///   - thumbnailURL: Optionales Cover (String-URL)
    ///   - source: z.B. "Google Books"
    /// - Returns: das neu erzeugte BookEntity (oder nil bei Fehler)
    func addBook(
        sourceID: String,
        title: String,
        author: String,
        thumbnailURL: String?,
        source: String
    ) -> BookEntity? {

        // Duplikate vermeiden:
        // Prüfen ob es bereits ein Buch mit gleicher sourceID gibt.
        if let existing = fetchBookBySourceID(sourceID) {
            logger.debug("ℹ️ Book with sourceID \(sourceID, privacy: .public) already exists, skipping insert.")
            return existing
        }

        let newBook = BookEntity(
            sourceID: sourceID,
            title: title,
            author: author,
            thumbnailURL: thumbnailURL,
            source: source,
            dateAdded: .now
        )

        context.insert(newBook)

        do {
            try context.save()
            logger.debug("✅ addBook saved successfully (\(title, privacy: .public))")
            return newBook
        } catch {
            logger.error("❌ addBook save failed: \(error.localizedDescription)")
            // Rollback (best effort)
            context.rollback()
            return nil
        }
    }

    /// Fetch single book by its external sourceID (Google Books ID, etc.)
    func fetchBookBySourceID(_ sourceID: String) -> BookEntity? {
        // We filter via a FetchDescriptor with a #Predicate
        let descriptor = FetchDescriptor<BookEntity>(
            predicate: #Predicate { $0.sourceID == sourceID },
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )

        do {
            let results = try context.fetch(descriptor)
            return results.first
        } catch {
            logger.error("❌ fetchBookBySourceID(\(sourceID, privacy: .public)) failed: \(error.localizedDescription)")
            return nil
        }
    }

    /// Delete a book
    func deleteBook(_ book: BookEntity) {
        context.delete(book)

        do {
            try context.save()
            logger.debug("🗑️ Book deleted")
        } catch {
            logger.error("❌ deleteBook save failed: \(error.localizedDescription)")
            context.rollback()
        }
    }

    // MARK: - Demo seeding / initial data
    /// Seeds demo data ONLY if library is empty, for onboarding / previews.
    /// We keep this optional for portfolio/showcase but you can call this from App launch.
    func seedDemoDataIfNeeded() {
        // Falls du Demo-Seeding inzwischen deaktivieren willst:
        // einfach früh returnen.
        // return

        // Library schon befüllt? -> nichts tun.
        if fetchAllBooks().isEmpty == false {
            logger.debug("🌱 seedDemoDataIfNeeded skipped (library not empty)")
            return
        }

        // Kleine statische Beispiele
        let demoBooks: [(id: String, title: String, author: String, cover: String?, source: String)] = [
            (
                id: "demo-atomic-habits",
                title: "Atomic Habits",
                author: "James Clear",
                cover: nil,
                source: "Demo"
            ),
            (
                id: "demo-deep-work",
                title: "Deep Work",
                author: "Cal Newport",
                cover: nil,
                source: "Demo"
            )
        ]

        for demo in demoBooks {
            _ = addBook(
                sourceID: demo.id,
                title: demo.title,
                author: demo.author,
                thumbnailURL: demo.cover,
                source: demo.source
            )
        }

        logger.debug("🌱 seedDemoDataIfNeeded inserted \(demoBooks.count) demo books")
    }

    // MARK: - Debug / Reset (for SettingsView)
    /// Komplettes Zurücksetzen der aktuellen Library im gegebenen ModelContext.
    /// - Löscht alle gespeicherten Bücher.
    /// - Optional: fügt die Demo-Bücher wieder ein.
    ///
    /// Das ist *static*, damit SettingsView (und andere Screens)
    /// einfach `DataService.resetDemoData(context)` aufrufen können,
    /// ohne zuerst manuell DataService zu bauen.
    static func resetDemoData(_ context: ModelContext) {
        let service = DataService(context: context)

        // 1. Alles löschen
        let all = service.fetchAllBooks()
        for book in all {
            context.delete(book)
        }

        do {
            try context.save()
        } catch {
            // Wenn Speichern nach dem Löschen fehlschlägt, rollen wir zurück
            context.rollback()
        }

        // 2. Demo neu anlegen (wenn du das möchtest)
        // Falls du stattdessen leere Library willst: diese zwei Zeilen auskommentieren.
        service.seedDemoDataIfNeeded()

        // 3. final sichern
        do {
            try context.save()
            service.logger.debug("🔄 resetDemoData finished successfully")
        } catch {
            service.logger.error("❌ resetDemoData final save failed: \(error.localizedDescription)")
            context.rollback()
        }
    }
}
