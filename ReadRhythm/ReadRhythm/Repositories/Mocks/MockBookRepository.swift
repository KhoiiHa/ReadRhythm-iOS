import Foundation
import SwiftData

#if DEBUG
/// Einfache In-Memory-Mock-Implementierung für Tests & Previews.
final class MockBookRepository: BookRepository {

    private(set) var storedBooks: [BookEntity]

    init(initialBooks: [BookEntity] = []) {
        self.storedBooks = initialBooks
    }

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
        let cleanedCategories = categories
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let cleanedLanguage = language
            .flatMap { trimmed -> String? in
                let value = trimmed.trimmingCharacters(in: .whitespacesAndNewlines)
                guard value.isEmpty == false else { return nil }
                let canonical: String
                if #available(iOS 16.0, *) {
                    canonical = Locale.identifier(fromComponents: [NSLocale.Key.languageCode.rawValue: value])
                } else {
                    canonical = Locale.canonicalIdentifier(from: value)
                }
                return canonical.replacingOccurrences(of: "_", with: "-").lowercased()
            }

        let cleanedDescription = descriptionText?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let sanitizedDescription = cleanedDescription?.isEmpty == true ? nil : cleanedDescription

        let cleanedSubtitle = subtitle?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let sanitizedSubtitle = cleanedSubtitle?.isEmpty == true ? nil : cleanedSubtitle

        let cleanedPublisher = publisher?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let sanitizedPublisher = cleanedPublisher?.isEmpty == true ? nil : cleanedPublisher

        let cleanedPublishedDate = publishedDate?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let sanitizedPublishedDate = cleanedPublishedDate?.isEmpty == true ? nil : cleanedPublishedDate

        let cleanedThumbnail = thumbnailURL?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let sanitizedThumbnail = cleanedThumbnail?.isEmpty == true ? nil : cleanedThumbnail

        let sanitizedPageCount = pageCount.flatMap { $0 > 0 ? $0 : nil }

        let entity = BookEntity(
            sourceID: sourceID ?? UUID().uuidString,
            title: title,
            author: author ?? "",
            thumbnailURL: sanitizedThumbnail,
            source: source,
            dateAdded: .now,
            subtitle: sanitizedSubtitle,
            publisher: sanitizedPublisher,
            publishedDate: sanitizedPublishedDate,
            pageCount: sanitizedPageCount,
            language: cleanedLanguage,
            categories: cleanedCategories,
            descriptionText: sanitizedDescription,
            infoLink: infoLink,
            previewLink: previewLink
        )
        storedBooks.insert(entity, at: 0)
        return entity
    }

    func delete(_ book: BookEntity) throws {
        storedBooks.removeAll { $0.id == book.id }
    }

    func fetchBooks(sortedBy descriptors: [SortDescriptor<BookEntity>]) throws -> [BookEntity] {
        // Für Previews/Tests reicht die gespeicherte Reihenfolge.
        storedBooks
    }
}
#endif
