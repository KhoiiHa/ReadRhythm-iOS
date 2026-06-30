// MARK: - Buchsuche-Repository / Book Search Repository
// Koordiniert API-Aufrufe, Caches und SwiftData für Discover /
// Coordinates API calls, caches, and SwiftData for the Discover feature.

import Foundation
import SwiftData

/// Protokoll für die Suche nach Büchern (Remote + Cache) /
/// Protocol for book searches combining remote calls and caching.
@MainActor
protocol BookSearchRepositoryProtocol {
    /// Führt eine Suche aus mit Cache-Fallbacks / Performs a search with cache fallbacks (memory → feed cache → API).
    func search(
        query: String?,
        category: DiscoverCategory?,
        maxResults: Int
    ) async throws -> [RemoteBook]
}

/// Koordiniert API, In-Memory-Cache und SwiftData-Feed-Cache /
/// Coordinates the API, in-memory cache, and SwiftData feed cache.
/// Implementiert Stale-While-Revalidate für Discover /
/// Implements a stale-while-revalidate strategy for Discover.
/// Nutzt denselben SwiftData-Container wie der Rest der App /
/// Uses the same SwiftData container as the rest of the app to avoid schema drift.
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

    /// Bequemer Default-Initializer für die App-Laufzeit /
    /// Convenience initializer for the app runtime.
    /// Nutzt explizit `PersistenceController.shared`, um Container zu teilen /
    /// Explicitly uses `PersistenceController.shared` to keep containers aligned.
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

        // Trim and validate query / Anfrage bereinigen und validieren
        let trimmed = (query ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return [] }

        let key = CacheKey(query: trimmed, categoryID: category?.id ?? "none")

        // 1️⃣ Memory Cache / In-Memory-Cache zuerst prüfen
        if let entry = memoryCache[key], Date().timeIntervalSince(entry.timestamp) < memoryTTL {
            #if DEBUG
            DebugLogger.log("💾 [BookSearchRepository] Memory-Hit for \(key)")
            #endif
            return entry.items
        }

        // 2️⃣ FeedCache (SwiftData) / Persistenter Discover-Cache – aktuell deaktiviert,
        // um vollständige Metadaten aus der API in Discover-Details zu erhalten.
        /*
        if let cachedItems = try? feedCache.fetch(categoryID: key.categoryID, query: key.query),
           let first = cachedItems.first,
           Date().timeIntervalSince(first.fetchedAt) < feedTTL {

            #if DEBUG
            DebugLogger.log("📦 [BookSearchRepository] FeedCache-Hit for \(key)")
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
        */

        // 3️⃣ API Call (Network) / Netzwerkanfrage
        #if DEBUG
        DebugLogger.log("🌐 [BookSearchRepository] Fetching remote data for \(key)")
        #endif

        let data: Data
        do {
            data = try await apiClient.search(query: trimmed, maxResults: maxResults)
        } catch {
            #if DEBUG
            let fallback = DiscoverSampleBooks.results(for: trimmed, category: category, limit: maxResults)
            if fallback.isEmpty == false {
                DebugLogger.log("🧪 [BookSearchRepository] API failed, using \(fallback.count) debug sample books for \(key)")
                memoryCache[key] = CacheEntry(timestamp: .now, items: fallback)
                return fallback
            }
            #endif

            throw error
        }

        #if DEBUG
        DebugLogger.log("🔎 [BookSearchRepository] API call succeeded, received \(data.count) bytes. Decoding…")
        #endif

        let remote = try mapRemoteBooks(from: data)

        #if DEBUG
        if remote.isEmpty {
            let fallback = DiscoverSampleBooks.results(for: trimmed, category: category, limit: maxResults)
            if fallback.isEmpty == false {
                DebugLogger.log("🧪 [BookSearchRepository] API returned no usable books, using \(fallback.count) debug sample books for \(key)")
                memoryCache[key] = CacheEntry(timestamp: .now, items: fallback)
                return fallback
            }
        }
        #endif

        #if DEBUG
        if remote.isEmpty {
            DebugLogger.log("⚠️ [BookSearchRepository] API returned data but no usable books after mapping for \(key)")
        }
        #endif

        // 4️⃣ Write-through Cache (Memory + FeedCache) / Ergebnisse zurückschreiben
        memoryCache[key] = CacheEntry(timestamp: .now, items: remote)
        try? feedCache.replace(categoryID: key.categoryID, query: key.query, with: remote, category: category)

        return remote
    }

    // MARK: - Lightweight DTOs / Leichte DTOs

    /// Decodiert das rohe JSON der Google Books API /
    /// Decodes raw JSON from the Google Books API.
    /// Überspringt unvollständige Volumes, statt zu scheitern /
    /// Skips incomplete volumes instead of failing hard.
    private func mapRemoteBooks(from data: Data) throws -> [RemoteBook] {
        let books = try BooksDecoder.decodeSearchList(from: data)

        #if DEBUG
        DebugLogger.log("🌐 [BookSearchRepository] decoded \(books.count) usable books from API response")
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
