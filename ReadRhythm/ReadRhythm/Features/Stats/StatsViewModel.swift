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
/// - Wie: Es ruft den StatsService auf, speichert aggregierte Werte (daily, totalMinutes)
///   und bietet eine reload-Funktion, die beim Start oder nach Änderungen aufgerufen wird.
@MainActor
final class StatsViewModel: ObservableObject {
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
        let service = StatsService.shared
        let window = safeDays(for: days)
        
        // Hole aggregierte Tageswerte (letzte X Tage)
        let items = service.minutesPerDay(context: context, days: window)
        daily = items
        
        // Gesamtminuten summieren
        totalMinutes = items.reduce(0) { $0 + $1.minutes }
        currentStreak = service.currentStreak(context: context)
        
        #if DEBUG
        print("[StatsViewModel] reload() – days=\(days), totalMinutes=\(totalMinutes)")
        #endif
    }
}
