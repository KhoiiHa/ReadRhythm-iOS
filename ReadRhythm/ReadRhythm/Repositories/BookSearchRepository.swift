//
//  BookSearchRepository.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 23.10.25.
//

import Foundation
import SwiftData

/// Protokoll für die Suche nach Büchern über Remote-API (Google Books) mit optionalem Cache.
protocol BookSearchRepositoryProtocol {
    /// Führt eine Suche aus und nutzt Cache-Fallbacks (Memory → FeedCache → API).
    func search(
        query: String?,
        category: DiscoverCategory?,
        maxResults: Int
    ) async throws -> [RemoteBook]
}

/// Repository, das API, In-Memory-Cache und SwiftData-Feed-Cache koordiniert.
/// Implementiert eine Stale-While-Revalidate-Strategie (SWR).
///
/// Wichtig:
/// - Verwendet denselben SwiftData-Container wie der Rest der App
///   (PersistenceController.shared), damit Discover-Feed, gespeicherte Bücher
///   und Library-Ansicht alle gegen dieselbe `default.store` gehen.
/// - Dadurch vermeiden wir `no such table: ZBOOKENTITY`.
@MainActor
final class BookSearchRepository: BookSearchRepositoryProtocol {

    // MARK: - Dependencies
    private let apiClient: BooksAPIClientProtocol
    private let feedCache: DiscoverFeedCacheRepository
    private let memoryTTL: TimeInterval = 10 * 60
    private let feedTTL: TimeInterval = 24 * 60 * 60

    // MARK: - In-Memory Cache
    private struct CacheEntry {
        let timestamp: Date
        let items: [RemoteBook]
    }
    private var memoryCache: [CacheKey: CacheEntry] = [:]

    // MARK: - Init
    init(apiClient: BooksAPIClientProtocol, feedCache: DiscoverFeedCacheRepository) {
        self.apiClient = apiClient
        self.feedCache = feedCache
    }

    /// Bequemer Default-Initializer für die App-Laufzeit.
    ///
    /// WICHTIG:
    /// Wir geben hier explizit `PersistenceController.shared` an den FeedCache weiter,
    /// damit BookSearchRepository, DiscoverFeedCacheRepository und der Rest der App
    /// garantiert im GLEICHEN SwiftData-Container laufen.
    convenience init() {
        self.init(
            apiClient: BooksAPIClient(network: NetworkClient()),
            feedCache: DiscoverFeedCacheRepository(container: PersistenceController.shared)
        )
    }

    // MARK: - Search
    func search(
        query: String?,
        category: DiscoverCategory?,
        maxResults: Int = 20
    ) async throws -> [RemoteBook] {

        // Trim and validate query
        let trimmed = (query ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return [] }

        let key = CacheKey(query: trimmed, categoryID: category?.id ?? "none")

        // 1️⃣ Memory Cache
        if let entry = memoryCache[key], Date().timeIntervalSince(entry.timestamp) < memoryTTL {
            #if DEBUG
            print("💾 [BookSearchRepository] Memory-Hit for \(key)")
            #endif
            return entry.items
        }

        // 2️⃣ FeedCache (SwiftData)
        if let cachedItems = try? feedCache.fetch(categoryID: key.categoryID, query: key.query),
           let first = cachedItems.first,
           Date().timeIntervalSince(first.fetchedAt) < feedTTL {

            #if DEBUG
            print("📦 [BookSearchRepository] FeedCache-Hit for \(key)")
            #endif

            let books = cachedItems.map {
                RemoteBook(
                    id: $0.sourceID,
                    title: $0.title,
                    authorsDisplay: $0.author,
                    thumbnailURL: $0.thumbnailURL.flatMap(URL.init)
                )
            }

            memoryCache[key] = CacheEntry(timestamp: .now, items: books)
            return books
        }

        // 3️⃣ API Call (Network)
        #if DEBUG
        print("🌐 [BookSearchRepository] Fetching remote data for \(key)")
        #endif

        let data = try await apiClient.search(query: trimmed, maxResults: maxResults)

        #if DEBUG
        print("🔎 [BookSearchRepository] API call succeeded, received \(data.count) bytes. Decoding…")
        #endif

        let remote = try mapRemoteBooks(from: data)

        #if DEBUG
        if remote.isEmpty {
            print("⚠️ [BookSearchRepository] API returned data but no usable books after mapping for \(key)")
        }
        #endif

        // 4️⃣ Write-through Cache (Memory + FeedCache)
        memoryCache[key] = CacheEntry(timestamp: .now, items: remote)
        try? feedCache.replace(categoryID: key.categoryID, query: key.query, with: remote, category: category)

        return remote
    }

    // MARK: - Lightweight DTOs for decoding Google Books response (MVP-scope)

    /// Decodiert das rohe JSON der Google Books API und mappt es in RemoteBook-Modelle.
    /// Bricht NICHT ab, wenn einzelne Volumes unvollständig sind.
    private func mapRemoteBooks(from data: Data) throws -> [RemoteBook] {
        let books = try BooksDecoder.decodeSearchList(from: data)

        #if DEBUG
        print("🌐 [BookSearchRepository] decoded \(books.count) usable books from API response")
        #endif

        return books
    }
}

// MARK: - CacheKey

private struct CacheKey: Hashable, CustomStringConvertible {
    let query: String
    let categoryID: String

    var description: String { "query='\(query)', category='\(categoryID)'" }
}
