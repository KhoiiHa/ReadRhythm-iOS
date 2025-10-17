//
//  BookRepository.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 17.10.25.
//

import Foundation
import SwiftData

/// Vertrag für den Datenzugriff auf Bücher.
/// ViewModels kennen **nur dieses Protokoll** – nicht, ob Daten lokal (SwiftData) oder remote (API) kommen.
/// Für den MVP bewusst minimal gehalten (Add/Delete). Lesen übernimmt SwiftUI via `@Query`.
protocol BookRepository {

    /// Fügt ein neues Buch ein und persistiert es.
    /// - Parameters:
    ///   - title: Erforderlicher Titel (bereits getrimmt/validiert im VM/UI).
    ///   - author: Optionaler Autorname.
    /// - Returns: Die persistierte `BookEntity` (nützlich für Navigation o.ä.).
    /// - Throws: Reicht Persistenzfehler nach oben (ViewModel zeigt dann i18n-Fehler an).
    @discardableResult
    func add(title: String, author: String?) throws -> BookEntity

    /// Löscht ein bestehendes Buch und persistiert die Änderung.
    /// - Parameter book: Die zu entfernende `BookEntity`.
    /// - Throws: Reicht Persistenzfehler nach oben (ViewModel zeigt dann i18n-Fehler an).
    func delete(_ book: BookEntity) throws
}
