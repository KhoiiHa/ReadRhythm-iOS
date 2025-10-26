//  SessionRepository.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 17.10.25.
//

import SwiftData
import Foundation


@MainActor
protocol SessionRepository {

    /// Neuer, zukünftiger Standardweg (Phase 9)
    @discardableResult
    func saveSession(
        book: BookEntity?,
        minutes: Int,
        date: Date,
        medium: String
    ) throws -> ReadingSessionEntity

    /// Alte API (für AddSessionView & Kompatibilität)
    @discardableResult
    func addSession(
        for book: BookEntity,
        minutes: Int,
        date: Date
    ) throws -> ReadingSessionEntity

    /// Löscht eine vorhandene Session
    func deleteSession(_ session: ReadingSessionEntity) throws
}

