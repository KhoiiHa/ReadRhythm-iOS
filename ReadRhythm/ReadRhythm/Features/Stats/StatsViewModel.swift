//
//  StatsViewModel.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 15.10.25.
//

import SwiftUI
import SwiftData

/// ViewModel für den Statistik-Bereich (Refactor-/Portfolio-Niveau)
/// Kontext → Warum → Wie:
/// - Kontext: Dieses ViewModel ist die zentrale Schicht zwischen StatsService (Datenaggregation)
///   und der StatsView (Chart & UI). Es verwaltet den Zeitraum, lädt die Daten und
///   liefert sie als Chart-taugliche Struktur zurück.
/// - Warum: Ohne diese Schicht müsste die View direkt Daten berechnen.
///   Das ViewModel kapselt die Logik, macht sie testbar und sauber getrennt.
///   Die View greift dadurch nicht mehr direkt auf SwiftData zu (Repository-Layer bleibt sauber, auch im DEBUG-Modus).
/// - Wie: Es ruft den StatsService auf, speichert aggregierte Werte (daily, totalMinutes)
///   und bietet eine reload-Funktion, die beim Start oder nach Änderungen aufgerufen wird.
@MainActor
final class StatsViewModel: ObservableObject {
    // MARK: - Dependencies
    private let sessionRepository: LocalSessionRepository
    private let statsService: StatsService

    // MARK: - Init
    /// ViewModel wird mit Repository- / Service-Abhängigkeiten erzeugt,
    /// damit die View selbst nie direkt auf SwiftData zugreifen muss.
    init(
        sessionRepository: LocalSessionRepository,
        statsService: StatsService
    ) {
        self.sessionRepository = sessionRepository
        self.statsService = statsService
    }

    // MARK: - Published Properties
    @Published var days: Int = 7 {
        didSet {
            #if DEBUG
            if days < 1 && days != Int.max {
                print("[StatsViewModel] invalid days=\(days) → clamped to 1")
            }
            #endif
            if days < 1 && days != Int.max { days = 1 }
        }
    }
    @Published private(set) var daily: [(date: Date, minutes: Int)] = []
    @Published private(set) var totalMinutes: Int = 0
    @Published private(set) var currentStreak: Int = 0

    // Zusätzliche aggregierte Werte (Phase 12 Ziel)
    @Published private(set) var totalReadingMinutes: Int = 0
    @Published private(set) var totalListeningMinutes: Int = 0
    @Published private(set) var combinedTotalMinutes: Int = 0

    // MARK: - Convenience
    /// True, wenn es mindestens einen Tag mit >0 Minuten gibt
    func hasData() -> Bool {
        daily.contains { $0.minutes > 0 }
    }

    /// Optionales Reload, das gleichzeitig die Tage setzt (MVP-Helper)
    func reload(context: ModelContext, days: Int) {
        self.days = days
        reload(context: context)
    }
    
    /// Liefert die Anzahl der Tage basierend auf UI-Auswahl (z. B. Woche, Monat, Jahr, Gesamt).
    /// Verhindert zu große Zeiträume (Performance-Limit für mobile Darstellung).
    private func safeDays(for requestedDays: Int) -> Int {
        switch requestedDays {
        case ..<1:
            return 1
        case 1...7:
            return requestedDays
        case 8...31:
            return 30
        case 32...180:
            return 90  // maximal 3 Monate
        case 181...364:
            return 120 // Jahr → auf 120 Tage limitieren
        default:
            return 120 // "Gesamt" → gleiche Obergrenze
        }
    }

    // MARK: - Load Data
    func reload(context: ModelContext) {
        // Performance-Schutz: clamp der gewünschten Tage
        let window = safeDays(for: days)

        // 1. Hole aggregierte Tageswerte (letzte X Tage) über den StatsService.
        //    Aktuell liefert minutesPerDay nur eine kombinierte Summe pro Tag.
        //    In Phase 12 wird StatsService auf DailyStatDTO (reading/listening getrennt) erweitert.
        let items = statsService.minutesPerDay(context: context, days: window)
        daily = items

        // 2. Bisherige Gesamtminuten (kombiniert)
        let combined = items.reduce(0) { $0 + $1.minutes }
        totalMinutes = combined

        // 3. Trennung Lesen / Hören (Platzhalter):
        //    Solange StatsService noch nicht nach medium splittet,
        //    setzen wir beide auf combined. Nach dem Service-Refactor
        //    werden diese Werte separat befüllt.
        totalReadingMinutes = combined
        totalListeningMinutes = 0
        combinedTotalMinutes = combined

        // 4. Aktuelle Streak
        currentStreak = statsService.currentStreak(context: context)

        #if DEBUG
        DebugLogger.log("[StatsViewModel] reload() – days=\(days), combinedTotalMinutes=\(combined)")
        #endif
    }

    /// Aktualisiert all veröffentlichte Werte basierend auf dem aktuellen `days`-Fenster,
    /// verwendet das Repository und den StatsService. Diese Variante wird nach Debug-Seeds
    /// aufgerufen, damit die View keinen ModelContext durchreichen muss.
    private func recomputeFromRepository() {
        // Performance-Schutz: clamp der gewünschten Tage
        let window = safeDays(for: days)

        // Hole aggregierte Tageswerte über den StatsService.
        // Wir geben hier explizit den context des LocalSessionRepository weiter,
        // damit StatsService weiterhin SwiftData lesen kann.
        let context = sessionRepository.context
        let items = statsService.minutesPerDay(context: context, days: window)
        daily = items

        let combined = items.reduce(0) { $0 + $1.minutes }
        totalMinutes = combined

        // Platzhalter bis der StatsService Lesen/Hören trennt
        totalReadingMinutes = combined
        totalListeningMinutes = 0
        combinedTotalMinutes = combined

        currentStreak = statsService.currentStreak(context: context)

        #if DEBUG
        DebugLogger.log("[StatsViewModel] recomputeFromRepository() – days=\(days), combinedTotalMinutes=\(combined)")
        #endif
    }

    // MARK: - Debug helpers
    #if DEBUG
    /// Wird von der StatsView (nur im DEBUG-UI) aufgerufen, um schnell Testdaten einzuspielen.
    /// Wichtig: Die View selbst spricht NICHT mehr direkt mit SwiftData,
    /// sondern geht über das Repository und lässt das ViewModel sich selbst neu berechnen.
    func debugAddTenMinutes(repository: LocalSessionRepository) {
        do {
            // Im MVP behandeln wir das als "reading".
            // Später könnte hier ein Medium-Toggle landen.
            try repository.debugAddSession(
                minutes: 10,
                medium: "reading",
                date: Date(),
                book: nil
            )

            // Danach sofort neu berechnen, ohne dass die View einen ModelContext durchreichen muss.
            recomputeFromRepository()
        } catch {
            DebugLogger.log("❌ [StatsViewModel] debugAddTenMinutes() failed: \(error.localizedDescription)")
        }
    }
    #endif
}
