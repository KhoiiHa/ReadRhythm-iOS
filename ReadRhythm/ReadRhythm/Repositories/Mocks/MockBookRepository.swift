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
        thumbnailURL: String?,
        sourceID: String?,
        source: String
    ) throws -> BookEntity {
        let entity = BookEntity(
            sourceID: sourceID ?? UUID().uuidString,
            title: title,
            author: author ?? "",
            thumbnailURL: thumbnailURL,
            source: source,
            dateAdded: .now
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
