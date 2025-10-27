// Kontext: Dieser Service destilliert ReadingSessions in Kennzahlen für Insights und Charts.
// Warum: UI-Schichten brauchen vorveredelte Statistikdaten statt jede Aggregation selbst zu rechnen.
// Wie: Wir ziehen SwiftData-Daten, formen DailyStatDTOs und liefern strukturierte Zeitreihen.
import Foundation
import SwiftData

// MARK: - Protocol & DTO for Insights/Charts
@MainActor
protocol StatsServiceProtocol {
    /// Returns last `days` items with date + per-day minutes (reading/listening).
    func fetchDailyStats(context: ModelContext, days: Int) -> [DailyStatDTO]
}

struct DailyStatDTO: Hashable {
    let date: Date
    let readingMinutes: Int
    let listeningMinutes: Int
}

@MainActor
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
            DebugLogger.log("⚠️ Fehler beim Laden der Sessions: \(error)")
            #endif
            return 0
        }
    }

    /// Aggregiert die Leseminuten pro Kalendertag für die letzten `days` (Default 7).
    /// Lücken werden mit 0 gefüllt und die Reihenfolge ist aufsteigend (ältester → heute).
    /// Hinweis: Für zukünftige Audiobook-Light-Erweiterungen liefert `fetchDailyStats` zusätzlich Hörminuten.
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
            DebugLogger.log("⚠️ Fehler beim Berechnen der Minuten pro Tag: \(error)")
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
                DebugLogger.log("⚠️ Fehler beim Summieren der Minuten: \(error)")
                #endif
                return 0
            }
        }
    }

    // MARK: - Goals Helpers (date-range based)
    /// Summe der Leseminuten im [start, end) Intervall (halb-offen).
    /// - Parameters:
    ///   - start: inklusiver Startzeitpunkt
    ///   - end: exklusiver Endzeitpunkt
    ///   - context: SwiftData-ModelContext
    /// - Returns: Gesamtminuten im Intervall
    func totalMinutes(from start: Date, to end: Date, in context: ModelContext) -> Int {
        let predicate = #Predicate<ReadingSessionEntity> { session in
            session.date >= start && session.date < end
        }
        let fd = FetchDescriptor<ReadingSessionEntity>(predicate: predicate)
        do {
            let sessions = try context.fetch(fd)
            return sessions.reduce(0) { $0 + $1.minutes }
        } catch {
            #if DEBUG
            DebugLogger.log("⚠️ Fehler beim Laden der Sessions (range): \(error)")
            #endif
            return 0
        }
    }

    /// Leseminuten für einen konkreten Kalendertag (lokaler Kalender).
    /// - Parameters:
    ///   - day: Irgendein Zeitpunkt an diesem Tag
    ///   - context: SwiftData-ModelContext
    /// - Returns: Minuten an diesem Tag
    func minutes(on day: Date, in context: ModelContext) -> Int {
        let cal = Calendar.current
        let start = cal.startOfDay(for: day)
        let end = cal.date(byAdding: .day, value: 1, to: start) ?? start
        return totalMinutes(from: start, to: end, in: context)
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
            DebugLogger.log("⚠️ Fehler beim Laden der Bücher: \(error)")
            #endif
            return 0
        }
    }

    // MARK: - Insights Helpers

    /// Anzahl der Sessions im Intervall [start, end)
    func totalSessions(from start: Date, to end: Date, in context: ModelContext) -> Int {
        let pred = #Predicate<ReadingSessionEntity> { s in
            s.date >= start && s.date < end
        }
        let fd = FetchDescriptor<ReadingSessionEntity>(predicate: pred)
        do {
            return try context.fetch(fd).count
        } catch {
            #if DEBUG
            DebugLogger.log("⚠️ Fehler beim Zählen der Sessions (range): \(error)")
            #endif
            return 0
        }
    }

    /// Minuten je Wochentag (0=So ... 6=Sa) im Intervall [start, end)
    func minutesByWeekday(from start: Date, to end: Date, in context: ModelContext) -> [Int: Int] {
        let pred = #Predicate<ReadingSessionEntity> { s in
            s.date >= start && s.date < end
        }
        let fd = FetchDescriptor<ReadingSessionEntity>(predicate: pred)
        let cal = Calendar.current
        var bucket: [Int: Int] = [:]
        do {
            let sessions = try context.fetch(fd)
            for s in sessions {
                let weekday = cal.component(.weekday, from: s.date) // 1..7 (depends on locale)
                let idx = (weekday - cal.firstWeekday + 7) % 7 // 0..6, starting at firstWeekday
                bucket[idx, default: 0] += s.minutes
            }
            return bucket
        } catch {
            #if DEBUG
            DebugLogger.log("⚠️ Fehler bei minutesByWeekday: \(error)")
            #endif
            return [:]
        }
    }

    /// Durchschnitts-Minuten pro Tag im Intervall [start, end) (inkl. Nulltage)
    func averageMinutesPerDay(from start: Date, to end: Date, in context: ModelContext) -> Double {
        let total = totalMinutes(from: start, to: end, in: context)
        let days = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 1
        let d = max(1, days)
        return Double(total) / Double(d)
    }
}

// MARK: - StatsServiceProtocol
extension StatsService: StatsServiceProtocol {
    /// Aggregates per-day minutes for the last `days` (reading + listening).
    /// Listening minutes are currently not modeled -> default 0 (forward-compatible with Audiobook-Light).
    func fetchDailyStats(context: ModelContext, days: Int) -> [DailyStatDTO] {
        let cal = Calendar.current
        guard let (fromDate, today) = dateWindow(days: days, calendar: cal) else { return [] }

        // Load sessions in window
        let predicate = #Predicate<ReadingSessionEntity> { $0.date >= fromDate }
        let descriptor = FetchDescriptor<ReadingSessionEntity>(predicate: predicate)

        do {
            let sessions = try context.fetch(descriptor)

            // Bucket per startOfDay, split by medium
            var readingBucket: [Date: Int] = [:]
            var listeningBucket: [Date: Int] = [:]

            for s in sessions {
                let day = cal.startOfDay(for: s.date)
                let minutes = s.minutes

                // medium: "reading" or "listening" (default "reading")
                switch s.medium {
                case "listening":
                    listeningBucket[day, default: 0] += minutes
                default:
                    readingBucket[day, default: 0] += minutes
                }
            }

            // Fill gaps oldest -> today
            let d = max(1, days)
            return (0..<d).compactMap { offset in
                guard let day = cal.date(byAdding: .day, value: -((d - 1) - offset), to: today) else { return nil }
                let reading = readingBucket[day, default: 0]
                let listening = listeningBucket[day, default: 0]
                return DailyStatDTO(date: day, readingMinutes: reading, listeningMinutes: listening)
            }
        } catch {
            #if DEBUG
            DebugLogger.log("⚠️ fetchDailyStats error: \(error)")
            #endif
            return []
        }
    }
}
