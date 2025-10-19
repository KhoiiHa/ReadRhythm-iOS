//
//  DataService.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 15.10.25.
//

import Foundation
import SwiftData

@MainActor
final class DataService {
    static let shared = DataService()
    private init() {}

    // MARK: - Books

    /// Schneller Existenz-Check (performant durch fetchLimit=1)
    func hasAnyBooks(in context: ModelContext) -> Bool {
        var descriptor = FetchDescriptor<BookEntity>()
        descriptor.fetchLimit = 1
        return ((try? context.fetch(descriptor)) ?? []).isEmpty == false
    }

    /// Kontext → Warum → Wie
    /// - Kontext: Zentrale SwiftData-Schnittstelle für Books.
    /// - Warum: Sauberes Repository-Verhalten für Fetch/Insert; robust bei optionalem Autor.
    /// - Wie: Einheitliche Sortierung, Title-Trim, Save mit fehler-tolerantem Verhalten.
    func fetchBooks(from context: ModelContext) -> [BookEntity] {
        let desc = FetchDescriptor<BookEntity>(sortBy: [
            .init(\.createdAt, order: .reverse)
        ])
        return (try? context.fetch(desc)) ?? []
    }

    /// Optionales Such-API (MVP: sucht substring im Titel)
    func fetchBooks(from context: ModelContext, search: String?) -> [BookEntity] {
        let trimmed = (search ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return fetchBooks(from: context)
        }
        // SwiftData-Predicate für Case-insensitive Suche im Titel
        let predicate = #Predicate<BookEntity> { book in
            book.title.localizedStandardContains(trimmed)
        }
        let desc = FetchDescriptor<BookEntity>(predicate: predicate, sortBy: [ .init(\.createdAt, order: .reverse) ])
        return (try? context.fetch(desc)) ?? []
    }

    /// Fügt ein Buch hinzu. Autor kann optional sein (MVP/Discover-Seed).
    func addBook(_ title: String, author: String? = nil, context: ModelContext) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return }

        let book = BookEntity(
            id: UUID(),
            title: trimmed,
            author: author?.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: Date()
        )
        context.insert(book)
        do {
            try context.save()
            #if DEBUG
            print("[DataService] +Book: \(book.title) by \(book.author ?? "-")")
            #endif
        } catch {
            #if DEBUG
            print("[DataService] Save failed: \(error.localizedDescription)")
            #endif
        }
    }
}

// MARK: - Seed (nur Debug)
#if DEBUG
extension DataService {
    /// Legt Demo-Daten an, wenn die DB leer ist (nur im DEBUG-Build).
    func seedDemoDataIfNeeded(_ context: ModelContext) {
        // Schon Daten vorhanden?
        if hasAnyBooks(in: context) { return }

        // Beispiel-Datensätze (Autor teils optional)
        let samples: [(String, String?)] = [
            ("The Pragmatic Programmer", "Andrew Hunt"),
            ("Atomic Habits", "James Clear"),
            ("Clean Architecture", "Robert C. Martin"),
            ("Deep Work", "Cal Newport"),
            ("ReadRhythm – Demo", nil)
        ]

        var createdBooks: [BookEntity] = []
        for (title, author) in samples {
            let book = BookEntity(
                id: UUID(),
                title: title,
                author: author,
                createdAt: Date().addingTimeInterval(Double.random(in: -5*24*3600 ... 0))
            )
            context.insert(book)
            createdBooks.append(book)
        }

        // Beispiel-Sessions (verteilt auf 3 Bücher)
        let sessionMinutes = [15, 20, 25, 30]
        for book in createdBooks.prefix(3) {
            let count = Int.random(in: 1...3)
            for i in 0..<count {
                let session = ReadingSessionEntity(
                    date: Calendar.current.date(byAdding: .day, value: -i, to: Date()) ?? Date(),
                    minutes: sessionMinutes.randomElement() ?? 20,
                    book: book
                )
                context.insert(session)
            }
        }

        do {
            try context.save()
            print("[DataService] Seeded demo data: \(createdBooks.count) books")
        } catch {
            print("⚠️ Seed-Save-Fehler: \(error)")
        }
    }
    /// Löscht alle Daten (nur DEBUG) – nützlich für UI-Tests / manuelles Resetten
    func wipeAllData(_ context: ModelContext) {
        do {
            try context.delete(model: BookEntity.self)
            try context.delete(model: ReadingSessionEntity.self)
            try context.save()
            print("[DataService] Wiped all data")
        } catch {
            print("⚠️ Wipe failed: \(error)")
        }
    }
    /// Reset: löscht alle Daten und legt anschließend die Seed-Daten neu an (nur DEBUG).
    @MainActor
    func resetDemoData(_ context: ModelContext) {
        wipeAllData(context)
        seedDemoDataIfNeeded(context)
    }

    /// Fallback ohne Context: existiert nur, damit Aufrufe ohne Parameter kompilieren.
    /// Hinweis: Bitte in Views immer `resetDemoData(context:)` mit `@Environment(\.modelContext)` verwenden.
    @MainActor
    func resetDemoData() {
        print("[DataService] resetDemoData() benötigt einen ModelContext. Verwende resetDemoData(context:) mit @Environment(\\.modelContext).")
    }
}
#endif
