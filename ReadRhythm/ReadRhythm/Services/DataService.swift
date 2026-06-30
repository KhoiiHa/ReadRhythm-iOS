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
        source: String,
        subtitle: String? = nil,
        publisher: String? = nil,
        publishedDate: String? = nil,
        pageCount: Int? = nil,
        language: String? = nil,
        categories: [String] = [],
        descriptionText: String? = nil,
        infoLink: URL? = nil,
        previewLink: URL? = nil
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
            dateAdded: .now,
            subtitle: subtitle,
            publisher: publisher,
            publishedDate: publishedDate,
            pageCount: pageCount,
            language: language,
            categories: categories,
            descriptionText: descriptionText,
            infoLink: infoLink,
            previewLink: previewLink
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
}
