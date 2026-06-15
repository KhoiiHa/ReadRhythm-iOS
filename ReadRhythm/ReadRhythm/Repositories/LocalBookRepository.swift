// MARK: - Lokales Buch-Repository / Local Book Repository
// Kontext: Verwaltet Bücher im SwiftData-Store / Context: Manages books in the SwiftData store.
// Warum: Discover & Add-Book benötigen eine zentrale Persistenzschicht / Why: Discover and add-book flows need a central persistence layer.
// Wie: Kapselt CRUD-Operationen über ModelContext und exponiert BookRepository / How: Wraps ModelContext CRUD behind the BookRepository protocol.
import Foundation
import SwiftData

/// Kapselt lokale Persistenz (SwiftData) für Bücher /
/// Encapsulates local SwiftData persistence for books.
/// Wird vom Discover-Screen und Add-Book-Flow genutzt /
/// Used by the Discover screen and the add-book flow.
final class LocalBookRepository: BookRepository {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    /// Lädt Bücher mit Sortierkriterien / Loads books with custom sort descriptors
    func fetchBooks(sortedBy descriptors: [SortDescriptor<BookEntity>]) throws -> [BookEntity] {
        let effectiveDescriptors = descriptors.isEmpty
            ? [SortDescriptor(\BookEntity.dateAdded, order: .reverse)]
            : descriptors

        let descriptor = FetchDescriptor<BookEntity>(sortBy: effectiveDescriptors)
        return try context.fetch(descriptor)
    }

    /// Fügt ein Buch in die lokale Bibliothek ein und speichert /
    /// Inserts a book into the local library and persists it.
    /// - Parameters:
    ///   - title: Buchtitel (Pflicht) / Book title (required)
    ///   - author: Autor:innen (optional) / Author string (optional)
    ///   - thumbnailURL: Optionales Cover / Optional cover URL
    ///   - sourceID: Eindeutige Quellen-ID / Unique source identifier
    ///   - source: Quelle wie "Google Books" / Source label such as "Google Books"
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

        // 1. Aufräumen / Defaults / Sanitize inputs and derive defaults
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

        // Wir brauchen immer eine sourceID / Always require a sourceID
        // Fehlt sie, erzeugen wir eine UUID / Generate a UUID when missing
        let finalSourceID = (sourceID?.trimmingCharacters(in: .whitespacesAndNewlines))
            .flatMap { $0.isEmpty ? nil : $0 }
            ?? UUID().uuidString

        // 2. Neues Model bauen / Build the SwiftData model instance
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

        // 3. Persistieren / Persist into the model context
        context.insert(entity)

        do {
            try context.save()
            if let persisted = context.model(for: entity.persistentModelID) as? BookEntity {
                DebugLogger.log("[Save][Book] '\(persisted.title)' pub=\(persisted.publisher ?? "-") year=\(persisted.publishedDate ?? "-") pages=\(persisted.pageCount?.description ?? "-") cats=\(persisted.categories) links=\(persisted.infoLink?.absoluteString ?? "-")")
            } else {
                DebugLogger.log("[LocalBookRepository] Saved book but could not reload via modelID.")
            }
            return entity
        } catch {
            DebugLogger.log("[LocalBookRepository] Save failed: \(error)")
            throw error
        }
    }

    /// Buch löschen inkl. Save() /
    /// Deletes a book and persists the change.
    func delete(_ book: BookEntity) throws {
        let bookID = book.persistentModelID
        let sessionsDescriptor = FetchDescriptor<ReadingSessionEntity>(
            predicate: #Predicate { session in
                session.book?.persistentModelID == bookID
            }
        )
        let linkedSessions = try context.fetch(sessionsDescriptor)
        for session in linkedSessions {
            context.delete(session)
        }

        context.delete(book)
        do {
            try context.save()
            DebugLogger.log("[LocalBookRepository] Deleted book '\(book.title)'")
        } catch {
            DebugLogger.log("[LocalBookRepository] Delete save failed: \(error)")
            context.rollback()
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
    let canonical: String
    if #available(iOS 16.0, *) {
        // iOS 16+: canonicalIdentifier(from:) renamed; keep behavior-equivalent normalization
        canonical = Locale.identifier(fromComponents: [NSLocale.Key.languageCode.rawValue: trimmed])
    } else {
        canonical = Locale.canonicalIdentifier(from: trimmed)
    }
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
