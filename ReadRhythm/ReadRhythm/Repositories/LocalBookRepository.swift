// Kontext: Dieses Repository verwaltet Bücher im lokalen SwiftData-Store.
// Warum: Features wie Discover und Add Book brauchen eine zentrale Persistenzschicht.
// Wie: Wir kapseln CRUD-Operationen über ModelContext und exponieren sie via BookRepository-Protokoll.
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

    func fetchBooks(sortedBy descriptors: [SortDescriptor<BookEntity>]) throws -> [BookEntity] {
        let effectiveDescriptors = descriptors.isEmpty
            ? [SortDescriptor(\BookEntity.dateAdded, order: .reverse)]
            : descriptors

        let descriptor = FetchDescriptor<BookEntity>(sortBy: effectiveDescriptors)
        return try context.fetch(descriptor)
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
        subtitle: String?,
        publisher: String?,
        publishedDate: String?,
        pageCount: Int?,
        language: String?,
        categories: [String],
        descriptionText: String?,
        thumbnailURL: String?,
        infoLink: URL?,
        previewLink: URL?,
        sourceID: String?,
        source: String
    ) throws -> BookEntity {

        // 1. Aufräumen / Defaults
        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        precondition(!cleanedTitle.isEmpty, "Book title must not be empty")

        let cleanedAuthor = (author ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let cleanedSubtitle = trimmedOrNil(subtitle)
        let cleanedPublisher = trimmedOrNil(publisher)
        let cleanedPublishedDate = trimmedOrNil(publishedDate)
        let sanitizedPageCount = pageCount.flatMap { $0 > 0 ? $0 : nil }
        let cleanedLanguage = sanitizeLanguage(language)

        let cleanedCategories = sanitizeCategories(categories)

        let cleanedDescription = trimmedOrNil(descriptionText)

        let cleanedThumbnail = trimmedOrNil(thumbnailURL)

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
            thumbnailURL: cleanedThumbnail,
            source: source,          // z.B. "Google Books" / "User Added"
            dateAdded: .now,
            subtitle: cleanedSubtitle,
            publisher: cleanedPublisher,
            publishedDate: cleanedPublishedDate,
            pageCount: sanitizedPageCount,
            language: cleanedLanguage,
            categories: cleanedCategories,
            descriptionText: cleanedDescription,
            infoLink: infoLink,
            previewLink: previewLink
        )

        // 3. Persistieren
        context.insert(entity)

        do {
            try context.save()
            #if DEBUG
            do {
                let descriptor = FetchDescriptor<BookEntity>(
                    predicate: #Predicate { $0.id == entity.id }
                )
                let persisted = try context.fetch(descriptor).first ?? entity
                print("[Save][Book] '\(persisted.title)' pub=\(persisted.publisher ?? "-") year=\(persisted.publishedDate ?? "-") pages=\(persisted.pageCount?.description ?? "-") cats=\(persisted.categories) links=\(persisted.infoLink?.absoluteString ?? "-")")
            } catch {
                print("[LocalBookRepository] ✅ Saved book but refetch failed: \(error)")
            }
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
private func trimmedOrNil(_ value: String?) -> String? {
    guard let raw = value?.trimmingCharacters(in: .whitespacesAndNewlines), raw.isEmpty == false else {
        return nil
    }
    return raw
}

private func sanitizeLanguage(_ value: String?) -> String? {
    guard let trimmed = trimmedOrNil(value) else { return nil }
    let canonical = Locale.canonicalIdentifier(from: trimmed) ?? trimmed
    return canonical.replacingOccurrences(of: "_", with: "-").lowercased()
}

private func sanitizeCategories(_ values: [String]) -> [String] {
    var seen: Set<String> = []
    var result: [String] = []

    for value in values {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { continue }

        let normalized = trimmed.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        if seen.contains(normalized) { continue }
        seen.insert(normalized)
        result.append(trimmed)
    }

    return result
}
