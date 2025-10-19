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

    /// Liefert (from, todayStart) für die letzten `days` Tage. Clamped auf >= 1.
    private func dateWindow(days: Int, calendar: Calendar = .current) -> (from: Date, today: Date)? {
        let cal = calendar
        let today = cal.startOfDay(for: Date())
        let d = max(1, days)
        return cal.date(byAdding: .day, value: -(d - 1), to: today).map { ($0, today) }
    }

    // Gesamt-Lesezeit in Sekunden (TimeInterval = Double)
    func totalReadingTime(context: ModelContext) -> TimeInterval {
        do {
            let descriptor = FetchDescriptor<ReadingSessionEntity>()
            let sessions = try context.fetch(descriptor)
            return sessions.reduce(0.0) { sum, session in
                sum + TimeInterval(session.minutes * 60)
            }
        } catch {
            #if DEBUG
            print("⚠️ Fehler beim Laden der Sessions: \(error)")
            #endif
            return 0
        }
    }

    /// Aggregiert die Leseminuten pro Tag für die letzten `days` (Standard: 7 Tage)
    /// - Returns: Array aus (Datum, Minuten)
    func minutesPerDay(context: ModelContext, days: Int = 7) -> [(date: Date, minutes: Int)] {
        let cal = Calendar.current
        guard let (fromDate, today) = dateWindow(days: days, calendar: cal) else { return [] }

        // Filter: Nur Sessions innerhalb der letzten N Tage
        let predicate = #Predicate<ReadingSessionEntity> { $0.date >= fromDate }
        let descriptor = FetchDescriptor<ReadingSessionEntity>(predicate: predicate)

        do {
            let sessions = try context.fetch(descriptor)
            var bucket: [Date: Int] = [:]

            for session in sessions {
                let day = cal.startOfDay(for: session.date)
                bucket[day, default: 0] += session.minutes
            }

            // Lücken füllen, sortiert (ältester → heute)
            let d = max(1, days)
            return (0..<d).compactMap { offset in
                guard let day = cal.date(byAdding: .day, value: -((d - 1) - offset), to: today) else { return nil }
                return (day, bucket[day, default: 0])
            }
        } catch {
            #if DEBUG
            print("⚠️ Fehler beim Berechnen der Minuten pro Tag: \(error)")
            #endif
            return []
        }
    }

    /// Summiert Leseminuten – optional für ein Zeitfenster, sonst "All time".
    func totalMinutes(context: ModelContext, days: Int? = nil) -> Int {
        if let d = days {
            return minutesPerDay(context: context, days: d).reduce(0) { $0 + $1.minutes }
        } else {
            do {
                let fd = FetchDescriptor<ReadingSessionEntity>()
                let sessions = try context.fetch(fd)
                return sessions.reduce(0) { $0 + $1.minutes }
            } catch {
                #if DEBUG
                print("⚠️ Fehler beim Summieren der Minuten: \(error)")
                #endif
                return 0
            }
        }
    }

    /// Ermittelt die aktuelle Lese-"Streak" (aufeinanderfolgende Tage mit >0 Minuten) bis heute.
    /// - Parameters:
    ///   - context: SwiftData-ModelContext
    ///   - daysLimit: Sicherheitslimit, wie weit rückwärts gezählt wird (Default 365)
    /// - Returns: Anzahl der Tage in Folge (heute eingeschlossen, wenn heute >0 Minuten)
    func currentStreak(context: ModelContext, daysLimit: Int = 365) -> Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        guard let from = cal.date(byAdding: .day, value: -(daysLimit - 1), to: today) else { return 0 }

        // Sessions im betrachteten Zeitraum laden
        let predicate = #Predicate<ReadingSessionEntity> { $0.date >= from }
        let fd = FetchDescriptor<ReadingSessionEntity>(predicate: predicate)
        let sessions = (try? context.fetch(fd)) ?? []

        // Tage, an denen gelesen wurde (Minuten > 0)
        var readDays: Set<Date> = []
        for s in sessions where s.minutes > 0 {
            readDays.insert(cal.startOfDay(for: s.date))
        }

        // Ab heute rückwärts zählen, bis ein Tag ohne Eintrag kommt
        var streak = 0
        var cursor = today
        while readDays.contains(cursor) {
            streak += 1
            if streak >= daysLimit { break }
            guard let prev = cal.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return streak
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
