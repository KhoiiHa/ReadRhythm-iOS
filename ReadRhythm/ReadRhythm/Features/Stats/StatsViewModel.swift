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
    @Published var days: Int = 7
    @Published private(set) var daily: [(date: Date, minutes: Int)] = []
    @Published private(set) var totalMinutes: Int = 0
    @Published private(set) var currentStreak: Int = 0

    // MARK: - Load Data
    func reload(context: ModelContext) {
        let service = StatsService.shared
        
        // Hole aggregierte Tageswerte (letzte X Tage)
        let items = service.minutesPerDay(context: context, days: days)
        daily = items
        
        // Gesamtminuten summieren
        totalMinutes = items.reduce(0) { $0 + $1.minutes }
        currentStreak = service.currentStreak(context: context)
        
        #if DEBUG
        print("[StatsViewModel] reload() – days=\(days), totalMinutes=\(totalMinutes)")
        #endif
    }
}
