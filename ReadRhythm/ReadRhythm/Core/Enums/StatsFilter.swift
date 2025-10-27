//
//  StatsFilter.swift
//  ReadRhythm
//
//  Kontext → Warum → Wie
//  Kontext: Repräsentiert den aktuell ausgewählten Zeitraum für Statistiken.
//  Warum: Macht den Intent („Woche / Monat / Jahr / Gesamt“) explizit an einer Stelle,
//         und bereitet eine klare Übergabe für View ↔ ViewModel vor.
//  Wie: Spiegelt die bestehenden Bereiche in StatsView / StatsViewModel wider.
//

import Foundation

enum StatsFilter: String, CaseIterable, Identifiable {
    case week
    case month
    case year
    case total

    var id: String { rawValue }

    /// Menschlich lesbarer Titel (lokalisierbar über Localizable.strings, falls gewünscht)
    var localizationKey: String {
        switch self {
        case .week:  return "stats.filter.week"
        case .month: return "stats.filter.month"
        case .year:  return "stats.filter.year"
        case .total: return "stats.filter.total"
        }
    }

    /// Eine grobe Standardzahl an Tagen dafür.
    /// Achtung: dein ViewModel hat safeDays(for:), das clamped z. B. year/total runter.
    var suggestedDays: Int {
        switch self {
        case .week:  return 7
        case .month: return 30
        case .year:  return 365
        case .total: return 9999 // wird in safeDays(for:) begrenzt
        }
    }
}
