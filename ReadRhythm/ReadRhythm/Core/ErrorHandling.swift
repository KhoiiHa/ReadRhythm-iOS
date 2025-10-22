//
//  ErrorHandling.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 15.10.25.
//

import Foundation

// MARK: - Kontext → Warum → Wie
// Kontext: Zentrale Sammlung von App-weiten Fehlertypen + Mapping auf i18n-Keys.
// Warum: Einheitliches, UI-taugliches Error-Handling über alle Schichten (API/Repository/Service/ViewModel).
// Wie: `AppError` beschreibt Domänenfehler (liefert i18n-Keys). Eine `Error`-Extension
//      liefert für *jeden* Error einen i18n-Key (`asUserMessage`), inkl. Mapping für `NetworkError`.

// MARK: - AppError (Domain)
enum AppError: Error, LocalizedError {
    case invalidInput
    case dataNotFound
    case saveFailed
    case deleteFailed
    case networkError
    case unknown

    /// Liefert i18n-Keys (werden im UI via Localized.string(key:) aufgelöst).
    var errorDescription: String? {
        switch self {
        case .invalidInput: return "error.invalid.input"
        case .dataNotFound: return "error.data.notfound"
        case .saveFailed: return "error.save.failed"
        case .deleteFailed: return "error.delete.failed"
        case .networkError: return "error.network"
        case .unknown: return "error.unknown"
        }
    }
}

// Optional: Lesbare Log-Ausgaben im Debug
extension AppError: CustomStringConvertible {
    var description: String {
        "[AppError] \(errorDescription ?? "error.unknown")"
    }
}

// MARK: - Globales Mapping für alle Errors
extension Error {
    /// UI-tauglicher i18n-Key (immer stabil, keine harten Klartext-Strings).
    /// ViewModels verwenden diesen Key für Alerts/Toasts/Labels.
    var asUserMessage: String {
        // 1) API/Transportfehler gezielt mappen (NetworkError lebt im API-Layer).
        if let net = self as? NetworkError {
            switch net {
            case .invalidURL:                  return "error.network.invalid_url"
            case .timeout:                     return "error.network.timeout"
            case .cancelled:                   return "error.network.cancelled"
            case .noResponse:                  return "error.network.no_response"
            case .httpStatus:                  return "error.network.http"         // generischer HTTP-Fehler
            case .transport:                   return "error.network.transport"
            case .unknown:                     return "error.network.unknown"
            }
        }

        // 2) Domänenfehler direkt durchreichen (liefert bereits i18n-Keys).
        if let app = self as? AppError {
            return app.errorDescription ?? "error.unknown"
        }

        // 3) Alles, was LocalizedError spricht, bevorzugen (kann bereits Keys liefern).
        if let loc = self as? LocalizedError, let desc = loc.errorDescription, !desc.isEmpty {
            return desc
        }

        // 4) Fallback (stets i18n-Key, keine Rohtexte im UI).
        return "error.unknown"
    }
}
