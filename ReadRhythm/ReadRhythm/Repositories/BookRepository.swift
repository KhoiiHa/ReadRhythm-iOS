//
//  BookRepository.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 17.10.25.
//

import Foundation
import SwiftData

// MARK: - Kontext → Warum → Wie
// Kontext: Diese Datei definiert die Schnittstelle für das **lokale** Bücher-Repository (SwiftData).
// Warum: Andere Komponenten (z. B. DiscoverViewModel, LibraryViewModel) programmieren nur gegen
//        dieses Protokoll – die konkrete Implementierung (LocalBookRepository) bleibt austauschbar
//        und ist leicht mockbar für Tests / Previews.
// Wie: Wir speichern Bücher aus zwei Quellen:
//      - vom Nutzer manuell hinzugefügt
//      - aus der Google Books API importiert
//      Deshalb erlauben wir optionale Metadaten wie Cover-URL und sourceID.

/// Abstraktion für lokale Buch-Operationen (SwiftData).
protocol BookRepository {
    /// Persistiert ein Buch in SwiftData und gibt die gespeicherte Entität zurück.
    /// - Parameters:
    ///   - title: Anzeigename des Buches (Pflicht)
    ///   - author: Autor oder Autor:innen-Liste (optional)
    ///   - thumbnailURL: (optional) Remote-Cover-URL (z. B. Google Books Thumbnail)
    ///   - sourceID: (optional) Eine externe ID (z. B. Google Books Volume ID)
    ///   - source: Kennzeichnung der Quelle (z. B. "Google Books", "User")
    @discardableResult
    func add(
        title: String,
        author: String?,
        thumbnailURL: String?,
        sourceID: String?,
        source: String
    ) throws -> BookEntity

    /// Löscht ein Buch aus der Persistenz.
    func delete(_ book: BookEntity) throws
}

// MARK: - Default Convenience
// Das hier ist nice für Aufrufe aus UI/Previews, die (noch) keine Metadaten haben.
// Wir liefern Standardwerte für Thumbnail/Source, damit ältere Call Sites weiter kompilieren
// (z. B. AddBookView oder Seeder-Code).
extension BookRepository {
    @discardableResult
    func add(
        title: String,
        author: String?
    ) throws -> BookEntity {
        try add(
            title: title,
            author: author,
            thumbnailURL: nil,
            sourceID: nil,
            source: "User" // Fallback-Quelle für manuell hinzugefügte Bücher
        )
    }
}
