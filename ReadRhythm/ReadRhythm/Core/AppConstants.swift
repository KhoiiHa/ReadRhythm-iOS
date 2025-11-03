// Kontext: Zentrale UI-Konstanten (Charts, Metriken, A11y) – Phase 15 Brand & Polish.
// Warum: Magic Numbers eliminieren, konsistente Behance-Optik, saubere Testbarkeit.
// Wie: Strokes/Spacings als Tokens; Farben bleiben in AppColors.Semantic, hier nur numerische Werte.
import SwiftUI

enum AppStroke {
    /// Linienbreite für Karten-Border / Divider (passt zu 0.5 / 0.75, die du schon nutzt)
    static let cardBorder: CGFloat = 0.75

    /// Linienbreite für Chart-Achsen (passt zum Separator)
    static let chartAxis: CGFloat = 0.75
    /// Linienbreite für Chart-Grids (dezenter als Axis)
    static let chartGrid: CGFloat = 0.5

    /// Linienbreite für Ziel-/Durchschnitts-Linien in Charts
    static let chartGoal: CGFloat = 2
    /// Auswahl-/Marker-Linie in Charts
    static let chartSelection: CGFloat = 1
}

enum AppChart {
    /// Einheitliche Höhe für Balkencharts / Fortschrittscharts
    static let height: CGFloat = 220

    /// Horizontaler Außenabstand um Charts herum
    static let horizontalPadding: CGFloat = AppSpace._16

    /// Abgerundete Ecken der Balken (ruhigere Anmutung)
    static let barCornerRadius: CGFloat = 6

    /// Abstand zwischen Bars/Marks
    static let barSpacing: CGFloat = AppSpace._8

    /// Länge der Achsen-Markierungen
    static let axisMarkLength: CGFloat = 4

    /// Abstand zwischen Achsenlabels und Achse
    static let labelSpacing: CGFloat = AppSpace._8

    /// Größe des Selection-Dots
    static let selectionDotSize: CGFloat = 6
}

/// A11y/HIG-relevante Konstanten
enum AppA11y {
    /// Mindest-Tap-Fläche (Apple HIG)
    static let minTapHeight: CGFloat = 44
}
