
//
//  AppConstants.swift
//  ReadRhythm
//
//  Kontext → Warum → Wie
//  Kontext: Zentrale UI-Konstanten für Charts & metrische Visualisierungen.
//  Warum: Entfernt Magic Numbers aus StatsChart & Co. ohne AppSpace/AppRadius doppelt zu definieren.
//  Wie: Ergänzt das bestehende Designsystem aus AppTheme.swift.
//

import SwiftUI

enum AppStroke {
    /// Linienbreite für Karten-Border / Divider (passt zu 0.5 / 0.75, die du schon nutzt)
    static let cardBorder: CGFloat = 0.75

    /// Linienbreite für Ziel-/Durchschnitts-Linien in Charts
    static let chartGoal: CGFloat = 2
}

enum AppChart {
    /// Einheitliche Höhe für Balkencharts / Fortschrittscharts
    static let height: CGFloat = 220

    /// Horizontaler Außenabstand um Charts herum
    static let horizontalPadding: CGFloat = AppSpace._16
}
