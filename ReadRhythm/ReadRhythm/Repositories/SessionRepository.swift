//  SessionRepository.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 17.10.25.
//

import SwiftData
import Foundation

/// Vertrag für den Zugriff auf ReadingSessions.
/// Ermöglicht lokale oder zukünftige Remote-Implementierungen.
/// Repository-Operationen laufen auf dem MainActor, da SwiftData-ModelContext im UI-Thread genutzt wird.
/// (Hält Aufrufer- und Persistenzthread konsistent. Für Background-Work später separate Repos/Methoden anlegen.)
@MainActor
protocol SessionRepository {
    @discardableResult
    func addSession(for book: BookEntity, minutes: Int, date: Date) throws -> ReadingSessionEntity
    func deleteSession(_ session: ReadingSessionEntity) throws
}
