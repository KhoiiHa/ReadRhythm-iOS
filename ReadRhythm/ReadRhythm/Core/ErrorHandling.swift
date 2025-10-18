//
//  ErrorHandling.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 15.10.25.
//

//
//  ErrorHandling.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 15.10.25.
//

import Foundation

/// Kontext → Warum → Wie
/// - Kontext: Zentrale Sammlung von App-weiten Fehlertypen.
/// - Warum: Einheitliches Error-Handling über alle Schichten (Repository, Service, ViewModel).
/// - Wie: Enum `AppError` beschreibt bekannte Fehlerfälle; erweiterbar mit `localizedDescription`.
enum AppError: Error, LocalizedError {
    case invalidInput
    case dataNotFound
    case saveFailed
    case deleteFailed
    case networkError
    case unknown

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

/// Optional: Erweiterung für lesbare Log-Ausgaben im Debug
extension AppError: CustomStringConvertible {
    var description: String {
        "[AppError] \(errorDescription ?? "error.unknown")"
    }
}
