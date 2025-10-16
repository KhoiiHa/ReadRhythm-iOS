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

    func fetchBooks(from context: ModelContext) -> [BookEntity] {
        let desc = FetchDescriptor<BookEntity>(sortBy: [
            .init(\.createdAt, order: .reverse)
        ])
        return (try? context.fetch(desc)) ?? []
    }

    func addBook(_ title: String, author: String, context: ModelContext) {
        let book = BookEntity(
            id: UUID(),
            title: title,
            author: author,
            createdAt: Date()
        )
        context.insert(book)
        try? context.save()
    }
}

// MARK: - Seed (nur Debug)
#if DEBUG
extension DataService {
    /// Legt Demo-Daten an, wenn die DB leer ist (nur im DEBUG-Build).
    func seedDemoDataIfNeeded(_ context: ModelContext) {
        // Schon Daten vorhanden?
        var descriptor = FetchDescriptor<BookEntity>()
        descriptor.fetchLimit = 1
        if let anyBook = try? context.fetch(descriptor), anyBook.isEmpty == false {
            return
        }

        // Beispiel-Buch
        let book = BookEntity(
            id: UUID(),
            title: "ReadRhythm – Demo",
            author: "System",
            createdAt: Date()
        )
        context.insert(book)

        // Beispiel-Session (30 Minuten)
        let session = ReadingSessionEntity(
            startedAt: Date().addingTimeInterval(-30 * 60),
            endedAt: Date(),
            durationSeconds: 30 * 60
        )
        context.insert(session)

        do { try context.save() } catch {
            #if DEBUG
            print("⚠️ Seed-Save-Fehler: \(error)")
            #endif
        }
    }
}
#endif
