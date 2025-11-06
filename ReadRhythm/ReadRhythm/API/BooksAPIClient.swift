// MARK: - Google Books API-Client / Google Books API Client
// Stellt typisierte Aufrufe für Suche & Details bereit / Provides typed calls for search & detail endpoints.

import Foundation

/// Abstraktion für Google Books API-Aufrufe / Abstraction around Google Books API calls.
public protocol BooksAPIClientProtocol {
    /// Führt eine Buchsuche aus und liefert Rohdaten / Performs a book search and returns raw data.
    /// Decoding erfolgt später über DTOs / Decoding happens later through DTOs.
    func search(query: String, maxResults: Int) async throws -> Data

    /// Detailabruf zu einer Volume-ID / Fetches detail data for a volume id.
    func detail(id: String) async throws -> Data
}

/// Konkreter Client auf Basis des generischen NetworkClient /
/// Concrete client powered by the generic network layer.
public final class BooksAPIClient: BooksAPIClientProtocol {

    private let network: NetworkClientProtocol
    private let baseURL: URL

    /// - Parameters:
    ///   - network: injizierbarer NetworkClient / injectable network client
    ///   - baseURL: Standard-Endpunkt / default API endpoint
    public init(network: NetworkClientProtocol,
                baseURL: URL = URL(string: "https://www.googleapis.com/books/v1")!) {
        self.network = network
        self.baseURL = baseURL
    }

    // MARK: - Public API

    /// Google Books Search:
    /// GET /volumes?q=<query>&maxResults=<n>
    public func search(query: String, maxResults: Int) async throws -> Data {
        let request = try URLRequestBuilder(baseURL: baseURL)
            .setting(path: "/volumes")
            .adding(queryItems: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "maxResults", value: String(max(1, min(maxResults, 40)))) // API-Limit ≤ 40
            ])
            .build()

        #if DEBUG
        let start = DispatchTime.now()
        #endif

        // Reicht Request an die schlanke Netzwerkabstraktion weiter /
        // Delegates the request to the lightweight network abstraction
        let (data, _) = try await network.request(request)

        #if DEBUG
        let ms = durationMillis(since: start)
        print("🔎 [BooksAPI] search(\"\(query)\") in \(ms) ms · \(data.count) bytes")
        #endif

        return data
    }

    /// Google Books Detail:
    /// GET /volumes/{id}
    public func detail(id: String) async throws -> Data {
        let request = try URLRequestBuilder(baseURL: baseURL)
            .setting(path: "/volumes/\(id)")
            .build()

        #if DEBUG
        let start = DispatchTime.now()
        #endif

        // Wiederverwendung desselben Netzwerklayers / Reuses the same network layer
        let (data, _) = try await network.request(request)

        #if DEBUG
        let ms = durationMillis(since: start)
        print("📘 [BooksAPI] detail(\(id)) in \(ms) ms · \(data.count) bytes")
        #endif

        return data
    }
}
