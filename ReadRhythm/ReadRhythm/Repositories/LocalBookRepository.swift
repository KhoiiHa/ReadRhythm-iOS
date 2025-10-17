//
//  LocalBookRepository.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 17.10.25.
//


//
//  LocalBookRepository.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 17.10.25.
//

import Foundation
import SwiftData

/// SwiftData-basierte Implementierung des BookRepository.
/// Kapselt alle lokalen Persistenzoperationen für Bücher.
final class LocalBookRepository: BookRepository {
    private let context: ModelContext

    /// Injiziere den aktuellen SwiftData-ModelContext aus der View-Komposition.
    init(context: ModelContext) {
        self.context = context
    }

    /// Fügt ein Buch hinzu und speichert die Änderung.
    @discardableResult
    func add(title: String, author: String?) throws -> BookEntity {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        precondition(!trimmedTitle.isEmpty, "Book title must not be empty")

        let trimmedAuthor = (author ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let entity = BookEntity(title: trimmedTitle, author: trimmedAuthor)
        context.insert(entity)

        do {
            try context.save()
            #if DEBUG
            print("[LocalBookRepository] Added book: \(entity.title)")
            #endif
            return entity
        } catch {
            #if DEBUG
            print("[LocalBookRepository] Save after add failed: \(error.localizedDescription)")
            #endif
            throw error
        }
    }

    /// Löscht ein Buch und speichert die Änderung.
    func delete(_ book: BookEntity) throws {
        context.delete(book)
        do {
            try context.save()
            #if DEBUG
            print("[LocalBookRepository] Deleted book: \(book.title)")
            #endif
        } catch {
            #if DEBUG
            print("[LocalBookRepository] Save after delete failed: \(error.localizedDescription)")
            #endif
            throw error
        }
    }
}
