//
//  StatsService.swift
//  ReadRhythm
//
//  Berechnet Lesestatistiken auf Basis gespeicherter Sessions.
//  Ziel: Anzeige von Fortschritt, gelesenen Seiten und Lesezeit.
//

import Foundation
import SwiftData

final class StatsService {
    static let shared = StatsService()
    private init() {}

    // Gesamt-Lesezeit in Sekunden (TimeInterval = Double)
    func totalReadingTime(context: ModelContext) -> TimeInterval {
        do {
            let descriptor = FetchDescriptor<ReadingSessionEntity>()
            let sessions = try context.fetch(descriptor)
            
            // Nutzt jetzt die Property aus Entity
            return sessions.reduce(0) { sum, session in
                sum + session.calculatedDuration
            }
        } catch {
            #if DEBUG
            print("⚠️ Fehler beim Laden der Sessions: \(error)")
            #endif
            return 0
        }
    }

    // Anzahl gespeicherter Bücher
    func totalBooksRead(context: ModelContext) -> Int {
        do {
            let descriptor = FetchDescriptor<BookEntity>()
            let books = try context.fetch(descriptor)
            return books.count
        } catch {
            #if DEBUG
            print("⚠️ Fehler beim Laden der Bücher: \(error)")
            #endif
            return 0
        }
    }
}
