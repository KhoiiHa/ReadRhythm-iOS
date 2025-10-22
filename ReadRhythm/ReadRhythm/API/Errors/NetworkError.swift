//
//  NetworkError.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 22.10.25.
//

import Foundation

/// Einheitlicher, typisierter Netzwerkfehler (API-Layer).
public enum NetworkError: Error, Equatable, LocalizedError {
    case invalidURL
    case timeout
    case cancelled
    case httpStatus(code: Int, data: Data?)
    case noResponse
    case transport(URLError)
    case unknown(Error)

    // Manuelles Equatable: vergleicht nur sinnvolle Eigenschaften.
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.timeout, .timeout),
             (.cancelled, .cancelled),
             (.noResponse, .noResponse):
            return true

        case let (.httpStatus(a, _), .httpStatus(b, _)):
            return a == b

        case let (.transport(a), .transport(b)):
            return a.code == b.code

        case let (.unknown(e1), .unknown(e2)):
            let n1 = e1 as NSError
            let n2 = e2 as NSError
            return n1.domain == n2.domain && n1.code == n2.code

        default:
            return false
        }
    }

    // Lesbare Beschreibung (für Logs/UI-Mapping im Core).
    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "Ungültige URL."
        case .timeout: return "Zeitüberschreitung (Timeout)."
        case .cancelled: return "Anfrage wurde abgebrochen."
        case let .httpStatus(code, _): return "HTTP-Statusfehler \(code)."
        case .noResponse: return "Keine gültige HTTP-Antwort."
        case let .transport(err): return "Transportfehler: \(err.code.rawValue) (\(err.code))."
        case let .unknown(err): return "Unbekannter Fehler: \(err.localizedDescription)"
        }
    }
}
