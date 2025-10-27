// Kontext: Dieses ViewModel liefert den Statistik-Screen mit aggregierten Lesezahlen und Intervallen.
// Warum: Die Charts brauchen kuratierte Datenströme statt roher Entities aus SwiftData.
// Wie: Wir orchestrieren StatsService-Aufrufe, cachen Ergebnisse und beliefern die View mit formatierten Strukturen.
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
///   und bietet eine `refreshFromRepositoryContext`-Funktion, die beim Start oder nach Änderungen aufgerufen wird.
@MainActor
final class StatsViewModel: ObservableObject {
    // MARK: - Dependencies
    private let sessionRepository: LocalSessionRepository
    private let statsService: StatsService
    private let context: ModelContext

    // MARK: - Init
    /// ViewModel wird mit Repository- / Service-Abhängigkeiten erzeugt,
    /// damit die View selbst nie direkt auf SwiftData zugreifen muss.
    init(
        sessionRepository: LocalSessionRepository,
        statsService: StatsService
    ) {
        self.sessionRepository = sessionRepository
        self.statsService = statsService
        self.context = sessionRepository.context
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
    /// Optionales Refresh, das gleichzeitig die Tage setzt (MVP-Helper)
    func refreshFromRepositoryContext(days: Int) {
        self.days = days
        refreshFromRepositoryContext()
    }

    /// Lädt die Statistikwerte basierend auf dem aktuellen `days`-Fenster neu.
    func refreshFromRepositoryContext() {
        // Performance-Schutz: clamp der gewünschten Tage
        let window = safeDays(for: days)

        // Hole aggregierte Tageswerte über den StatsService.
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
        DebugLogger.log("[StatsViewModel] refreshFromRepositoryContext() – days=\(days), combinedTotalMinutes=\(combined)")
        #endif
    }

    // MARK: - Debug helpers
    #if DEBUG
    /// Wird von der StatsView (nur im DEBUG-UI) aufgerufen, um schnell Testdaten einzuspielen.
    /// Wichtig: Die View selbst spricht NICHT mehr direkt mit SwiftData,
    /// sondern geht über das Repository und lässt das ViewModel sich selbst neu berechnen.
    func seedDebugMinutes() {
        do {
            // Im MVP behandeln wir das als "reading".
            // Später könnte hier ein Medium-Toggle landen.
            try sessionRepository.debugAddSession(
                minutes: 10,
                medium: "reading",
                date: Date(),
                book: nil
            )

            // Danach sofort neu berechnen, ohne dass die View einen ModelContext durchreichen muss.
            refreshFromRepositoryContext()
        } catch {
            DebugLogger.log("❌ [StatsViewModel] seedDebugMinutes() failed: \(error.localizedDescription)")
        }
    }
    #endif
}
