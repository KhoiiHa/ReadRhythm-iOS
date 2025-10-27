//
//  DataServiceError.swift
//  ReadRhythm
//
//  Kontext → Warum → Wie
//  Kontext: Einheitliche Fehlerquelle für Repository-/Persistenz-Operationen.
//  Warum: Klare Fehlerkommunikation in Debug-Logs und eine Basis für spätere User-facing Errors.
//  Wie: Sehr fokussiert auf das, was in Phase 12 wirklich vorkommt (Session speichern).
//

import Foundation

enum DataServiceError: Error {
    /// Session konnte nicht geschrieben werden (SwiftData Save schlug fehl)
    case failedToSaveSession(underlying: Error)

    /// Angeforderte Daten existieren nicht (z. B. Buch nicht gefunden)
    case notFound

    /// Ungültige Eingaben (z. B. Minuten < 1)
    case invalidInput(description: String)
}

extension DataServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failedToSaveSession(let underlying):
            return "Failed to save session: \(underlying.localizedDescription)"
        case .notFound:
            return "Requested item not found."
        case .invalidInput(let description):
            return "Invalid input: \(description)"
        }
    }
}
