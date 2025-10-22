//
//  BooksAPIClient.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 22.10.25.
//

import Foundation

/// Abstraktion für Google Books API-Aufrufe (Search, Detail).
public protocol BooksAPIClientProtocol {
    /// Führt eine Buchsuche aus und liefert die Rohdaten der JSON-Response.
    /// Decoding erfolgt in Schritt 3 (DTOs & Mapper).
    func search(query: String, maxResults: Int) async throws -> Data

    /// Optional für später: Detailabruf zu einer Volume-ID.
    func detail(id: String) async throws -> Data
}

/// Konkreter Client für Google Books v1.
/// Nutzt den generischen NetworkClient + URLRequestBuilder.
public final class BooksAPIClient: BooksAPIClientProtocol {

    private let network: NetworkClientProtocol
    private let baseURL: URL

    /// - Parameters:
    ///   - network: injizierbarer NetworkClient (für Tests mockbar)
    ///   - baseURL: default = Google Books v1
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

        let (data, _) = try await network.request(request)

        #if DEBUG
        let ms = durationMillis(since: start)
        print("📘 [BooksAPI] detail(\(id)) in \(ms) ms · \(data.count) bytes")
        #endif

        return data
    }
}
