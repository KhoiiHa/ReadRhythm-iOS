//
//  LocalBookRepository.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 17.10.25.
//

import Foundation
import SwiftData

/// Kapselt lokale Persistenz (SwiftData) für Bücher.
/// Wird z.B. vom Discover-Screen (Speichern aus API)
/// und vom Add-Book-Flow (manuell hinzufügen) verwendet.
final class LocalBookRepository: BookRepository {
    
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    /// Fügt ein Buch in die lokale Bibliothek ein und speichert.
    /// - Parameters:
    ///   - title: Buchtitel (Pflicht)
    ///   - author: Autor / Autor:innen (kann leer sein)
    ///   - thumbnailURL: optionales Cover (z.B. vom Google Books API Thumbnail)
    ///   - sourceID: eindeutige ID der Quelle.
    ///              - Bei Google Books: volumeID
    ///              - Bei manuell hinzugefügt: generierte UUID
    ///   - source: z.B. "Google Books" oder "User Added"
    @discardableResult
    func add(
        title: String,
        author: String?,
        thumbnailURL: String?,
        sourceID: String?,
        source: String
    ) throws -> BookEntity {

        // 1. Aufräumen / Defaults
        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        precondition(!cleanedTitle.isEmpty, "Book title must not be empty")

        let cleanedAuthor = (author ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Wir brauchen IMMER eine sourceID, laut BookEntity.
        // Falls keine kam (z.B. User hat manuell ein Buch angelegt),
        // erzeugen wir eine stabile UUID.
        let finalSourceID = (sourceID?.trimmingCharacters(in: .whitespacesAndNewlines))
            .flatMap { $0.isEmpty ? nil : $0 }
            ?? UUID().uuidString

        // 2. Neues Model bauen
        let entity = BookEntity(
            sourceID: finalSourceID,
            title: cleanedTitle,
            author: cleanedAuthor,
            thumbnailURL: thumbnailURL,
            source: source,          // z.B. "Google Books" / "User Added"
            dateAdded: .now
        )

        // 3. Persistieren
        context.insert(entity)

        do {
            try context.save()
            #if DEBUG
            print("[LocalBookRepository] ✅ Saved book '\(entity.title)' (\(entity.source))")
            #endif
            return entity
        } catch {
            #if DEBUG
            print("[LocalBookRepository] ❌ Save failed:", error)
            #endif
            throw error
        }
    }

    /// Buch löschen inkl. Save()
    func delete(_ book: BookEntity) throws {
        context.delete(book)
        do {
            try context.save()
            #if DEBUG
            print("[LocalBookRepository] 🗑 Deleted book '\(book.title)'")
            #endif
        } catch {
            #if DEBUG
            print("[LocalBookRepository] ❌ Delete save failed:", error)
            #endif
            throw error
        }
    }
}
