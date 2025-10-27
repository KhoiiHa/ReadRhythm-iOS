// Kontext: Diese Datei beherbergt UI-Konstanten für Charts und metrische Komponenten.
// Warum: Wir wollen Magic Numbers aus Views ziehen und Design-Tokens komplementieren.
// Wie: Wir deklarieren Strokes, Spacing und weitere Werte als zentrale SwiftUI-Statics.
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
