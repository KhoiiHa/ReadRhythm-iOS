//
//  DiscoverFeedCacheRepository .swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 23.10.25.
//


//
//  DiscoverFeedCacheRepository.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 23.10.25.
//

import Foundation
import SwiftData

/// Verwaltet den persistenten Discover-Feed-Cache in SwiftData.
/// Ab jetzt läuft dieser Cache IM SELBEN SwiftData-Container wie die Nutzer-Library.
/// Das bedeutet: Discover (API-Ergebnisse), gespeicherte Bücher (BookEntity)
/// und Ziele/Sessions teilen sich eine einzige `default.store`.
/// Dadurch vermeiden wir "no such table"-Fehler und machen Offline-Fallback möglich.
@MainActor
final class DiscoverFeedCacheRepository {

    // MARK: - Storage
    private let container: ModelContainer
    private let context: ModelContext

    /// Erzeugt ein Repository für den Discover-Feed-Cache.
    /// Verwendet IMMER den gemeinsamen App-Container (`PersistenceController.shared`),
    /// damit Discover-Cache und Nutzer-Library (BookEntity etc.) im selben Store leben.
    init(container: ModelContainer? = nil) {
        let resolvedContainer = container ?? PersistenceController.shared
        self.container = resolvedContainer

        self.context = ModelContext(resolvedContainer)
        self.context.autosaveEnabled = true
    }

    // MARK: - API

    /// Liefert die letzten gecachten Items für eine Kategorie.
    /// - Parameters:
    ///   - categoryID: `DiscoverCategory.id` (z. B. "mindfulness"). Nutze "none"/"uncategorized" wenn nil.
    ///   - query: Optionaler Suchbegriff (derzeit ignoriert – wir cachen primär pro Kategorie).
    /// - Returns: Sortiert nach `fetchedAt` (neueste zuerst).
    func fetch(categoryID: String, query: String?) throws -> [DiscoverFeedItem] {
        var descriptor = FetchDescriptor<DiscoverFeedItem>(
            predicate: #Predicate { $0.categoryRaw == categoryID },
            sortBy: [SortDescriptor(\.fetchedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 40 // MVP: genug für UI
        return try context.fetch(descriptor)
    }

    /// Ersetzt den Cache einer Kategorie durch neue Items (Write-Through aus der API).
    /// - Parameters:
    ///   - categoryID: `DiscoverCategory.id`
    ///   - query: Optionaler Suchbegriff (derzeit ignoriert – Kategorie dominiert)
    ///   - books: Remote-Ergebnisse
    ///   - category: Genutzte Kategorie (für Mapping; darf nil sein)
    func replace(categoryID: String, query: String?, with books: [RemoteBook], category: DiscoverCategory?) throws {
        // 1) Alte Items der Kategorie entfernen
        let old = try fetch(categoryID: categoryID, query: query)
        for item in old {
            context.delete(item)
        }

        // 2) Neu einfügen
        for book in books {
            let item = DiscoverFeedItem.from(remote: book, category: category)
            item.categoryRaw = categoryID
            context.insert(item)
        }

        // 3) Speichern
        try context.save()

        #if DEBUG
        DebugLogger.log("🧺 [FeedCache] replaced category=\(categoryID) count=\(books.count)")
        #endif
    }

    /// Entfernt alte Cache-Einträge.
    func prune(olderThan date: Date) throws {
        let descriptor = FetchDescriptor<DiscoverFeedItem>(
            predicate: #Predicate { $0.fetchedAt < date }
        )
        let stale = try context.fetch(descriptor)
        for item in stale {
            context.delete(item)
        }
        try context.save()
        #if DEBUG
        DebugLogger.log("🧹 [FeedCache] pruned \(stale.count) items older than \(date)")
        #endif
    }
}
