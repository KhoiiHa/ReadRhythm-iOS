// MARK: - Netzwerk-Grundbaustein / Networking Foundation
// Liefert einen testbaren HTTP-Client samt Request-Builder / Provides a testable HTTP client plus request builder.

import Foundation

// MARK: - Protocol

/// Abstraktion für den HTTP-Client / HTTP client abstraction for easy mocking.
public protocol NetworkClientProtocol {
    /// Führt eine Request aus und liefert Rohdaten + HTTP-Antwort /
    /// Executes a request and returns raw data with the HTTP response.
    func request(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

// MARK: - Client

/// Standard-Implementation auf Basis von URLSession /
/// Standard implementation built on URLSession.
public final class NetworkClient: NetworkClientProtocol {

    private let session: URLSession

    /// Erstellt einen Client mit eigener URLSession / Builds a client with its own URLSession.
    /// - Parameter session: Für Tests injizierbar; default: ephemerale Session /
    ///   Injectable session for tests; default uses an ephemeral configuration.
    public init(session: URLSession? = nil) {
        // Ermöglicht Dependency Injection, fällt sonst auf Standardkonfiguration zurück /
        // Allows dependency injection, otherwise falls back to a default configuration
        if let session {
            self.session = session
        } else {
            // Schlanke Standardkonfiguration für API-Zugriffe / Lightweight default configuration for API calls
            let cfg = URLSessionConfiguration.ephemeral
            cfg.timeoutIntervalForRequest = 15
            cfg.timeoutIntervalForResource = 15
            cfg.waitsForConnectivity = true
            cfg.httpAdditionalHeaders = [
                "Accept": "application/json",
                "Accept-Charset": "utf-8",
                "User-Agent": "ReadRhythm/1.0 (iOS)"
            ]
            self.session = URLSession(configuration: cfg)
        }
    }

    /// Führt eine Request aus, prüft Statuscode und liefert Daten + Response /
    /// Executes a request, validates the status code, and returns data plus response.
    public func request(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        #if DEBUG
        let start = DispatchTime.now()
        let method = request.httpMethod ?? "GET"
        let urlString = request.url?.absoluteString ?? "<nil>"
        print("🌐 [HTTP] \(method) \(urlString)")
        #endif

        do {
            let (data, response) = try await session.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.noResponse
            }

            guard (200...299).contains(http.statusCode) else {
                #if DEBUG
                let ms = durationMillis(since: start)
                print("⛔️ [HTTP] \(http.statusCode) in \(ms) ms · \(data.count) bytes")
                #endif
                throw NetworkError.httpStatus(code: http.statusCode, data: data)
            }

            #if DEBUG
            let ms = durationMillis(since: start)
            print("✅ [HTTP] \(http.statusCode) in \(ms) ms · \(data.count) bytes")
            #endif

            return (data, http)
        } catch {
            if let urlErr = error as? URLError {
                #if DEBUG
                print("⚠️  [HTTP] URLError: \(urlErr.code.rawValue) (\(urlErr.code))")
                #endif
                switch urlErr.code {
                case .timedOut:   throw NetworkError.timeout
                case .cancelled:  throw NetworkError.cancelled
                default:          throw NetworkError.transport(urlErr)
                }
            }
            throw NetworkError.unknown(error)
        }
    }
}

// MARK: - URLRequestBuilder

/// Kleiner Helper für konsistente Requests / Small helper for consistent request creation.
public struct URLRequestBuilder {
    public enum HTTPMethod: String { case GET, POST, PUT, PATCH, DELETE }

    private let baseURL: URL
    private var path: String = ""
    private var method: HTTPMethod = .GET
    private var queryItems: [URLQueryItem] = []
    private var headers: [String: String] = [:]
    private var body: Data?

    public init(baseURL: URL) { self.baseURL = baseURL }

    public func setting(path: String) -> URLRequestBuilder {
        var c = self; c.path = path; return c
    }
    public func setting(method: HTTPMethod) -> URLRequestBuilder {
        var c = self; c.method = method; return c
    }
    public func adding(queryItems: [URLQueryItem]) -> URLRequestBuilder {
        var c = self; c.queryItems.append(contentsOf: queryItems); return c
    }
    public func adding(headers: [String: String]) -> URLRequestBuilder {
        var c = self; c.headers.merge(headers, uniquingKeysWith: { _, new in new }); return c
    }
    public func setting(jsonBody: Encodable) throws -> URLRequestBuilder {
        var c = self
        c.body = try JSONEncoder().encode(AnyEncodable(jsonBody))
        c.headers["Content-Type"] = "application/json"
        return c
    }

    public func build() throws -> URLRequest {
        // URLComponents niemals per optional chaining mutieren / Avoid mutating URLComponents via optional chaining
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }

        // Pfad sicher zusammensetzen / Compose the path safely
        if !path.isEmpty {
            let basePath = components.path
            if basePath.isEmpty {
                components.path = path.hasPrefix("/") ? path : "/" + path
            } else {
                if basePath.hasSuffix("/") || path.hasPrefix("/") {
                    components.path = basePath + path
                } else {
                    components.path = basePath + "/" + path
                }
            }
        }

        // Query-Items deduplizieren und deterministisch sortieren /
        // Deduplicate query items and keep deterministic ordering
        if !queryItems.isEmpty {
            var merged: [String: URLQueryItem] = [:]
            for item in queryItems { merged[item.name] = item }
            components.queryItems = merged.values.sorted { $0.name < $1.name }
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        if let body { req.httpBody = body }
        headers.forEach { req.addValue($1, forHTTPHeaderField: $0) }
        return req
    }
}

// MARK: - Helpers

/// Wrapper für beliebige Encodables / Wrapper enabling encoding of arbitrary `Encodable` values.
private struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    init<T: Encodable>(_ value: T) { _encode = value.encode }
    func encode(to encoder: Encoder) throws { try _encode(encoder) }
}
