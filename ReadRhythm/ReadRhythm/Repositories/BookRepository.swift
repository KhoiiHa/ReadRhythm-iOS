//
//  BookRepository.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 17.10.25.
//

import Foundation
import SwiftData

// MARK: - Kontext → Warum → Wie
// Kontext: Dieses File definiert die Schnittstelle für das **lokale** Bücher-Repository (SwiftData).
// Warum: Andere Komponenten (z. B. LibraryViewModel, Use-Cases) sollen nur gegen dieses Protokoll
//        programmieren – die konkrete Implementierung (LocalBookRepository) bleibt austauschbar.
// Wie: Minimaler, MVP-tauglicher Umfang: Add & Delete. Lesen erfolgt meist über @Query im UI,
//      kann aber bei Bedarf hier ergänzt werden (fetchAll(), fetch(by:), ...).

/// Abstraktion für lokale Buch-Operationen (SwiftData).
protocol BookRepository {
    /// Legt ein Buch an und gibt die persistierte Entität zurück.
    @discardableResult
    func add(title: String, author: String?) throws -> BookEntity

    /// Entfernt ein Buch aus der Persistenz.
    func delete(_ book: BookEntity) throws
}

// HINWEIS:
// Die Remote-Suche (Google Books) gehört **nicht** hierher, sondern in:
//   Repositories/BookSearchRepository.swift
// mit dem Protokoll `BookSearchRepository` und der Implementierung
// `DefaultBookSearchRepository` (bereits vorhanden).
