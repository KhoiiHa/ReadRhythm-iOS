//
//  BookSearchRepository.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 22.10.25.
//

import Foundation

// API-Layer (BooksAPIClientProtocol), Domain aus dem Mapper (RemoteBook)
/// Abstraktion für die **Remote-Buchsuche** (Discover).
/// Liefert leichte Domain-Objekte (`RemoteBook`) für das UI/VM – ohne Persistenz.
/// Implementierung kapselt API-Aufrufe, Decoding & einfaches In-Memory-Caching.
public protocol BookSearchRepository {
    /// Sucht Bücher über die Remote-API.
    /// - Parameters:
    ///   - query: Suchstring (bereits getrimmt/debounced im VM).
    ///   - maxResults: Begrenzung (1…40, wird intern gesichert).
    ///   - forceRefresh: Ignoriert Cache, zieht frische Daten.
    /// - Returns: Liste leichter Domain-Objekte für die Discover-Ansicht.
    func search(query: String, maxResults: Int, forceRefresh: Bool) async throws -> [RemoteBook]
}

/// Einfache In-Memory-Cache-Struktur (Query-basiert).
private struct CachedEntry {
    let timestamp: Date
    let items: [RemoteBook]
}

/// Standard-Implementierung, die den API-Client nutzt.
public final class DefaultBookSearchRepository: BookSearchRepository {

    // Dependencies
    private let api: BooksAPIClientProtocol
    private let cacheTTL: TimeInterval

    // Very simple query → result cache (not thread-safe across actors; we stay on Main/VM queues)
    private var cache: [String: CachedEntry] = [:]

    /// - Parameters:
    ///   - api: injizierbarer API-Client (für Tests mockbar)
    ///   - cacheTTL: Sekunden, wie lange ein Suchergebnis gültig ist (default 120 s)
    public init(api: BooksAPIClientProtocol, cacheTTL: TimeInterval = 120) {
        self.api = api
        self.cacheTTL = cacheTTL
    }

    public func search(query: String, maxResults: Int, forceRefresh: Bool) async throws -> [RemoteBook] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        // Leere Suche: definierter Rückgabewert (kein API-Call)
        guard !trimmed.isEmpty else { return [] }

        // Cache-Hit?
        if !forceRefresh, let hit = cache[trimmed], Date().timeIntervalSince(hit.timestamp) < cacheTTL {
            #if DEBUG
            print("🗂️  [BookSearchRepo] cache hit for \"\(trimmed)\" → \(hit.items.count) items")
            #endif
            return hit.items
        }

        // API-Aufruf (Rohdaten)
        let raw = try await api.search(query: trimmed, maxResults: max(1, min(maxResults, 40)))

        // Decoding + Mapping → [RemoteBook]
        let items = try BooksDecoder.decodeSearchList(from: raw)

        // Cache aktualisieren
        cache[trimmed] = CachedEntry(timestamp: Date(), items: items)

        #if DEBUG
        print("🔄 [BookSearchRepo] fetched \"\(trimmed)\" → \(items.count) items (cached)")
        #endif

        return items
    }
}
