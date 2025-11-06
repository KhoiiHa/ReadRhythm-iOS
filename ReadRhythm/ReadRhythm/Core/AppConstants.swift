// MARK: - UI-Konstanten / UI Constants
// Kontext: Zentrale UI-Konstanten (Charts, A11y) / Context: Central UI constants for charts and accessibility.
// Warum: Magic Numbers eliminieren & konsistente Optik / Why: Remove magic numbers and keep visuals consistent.
// Wie: Spacings & Strokes als Tokens, Farben bleiben in AppColors / How: Expose spacings & strokes as tokens while colors live in AppColors.
import SwiftUI

enum AppStroke {
    /// Linienbreite für Karten-Border / Divider / Border thickness for cards and dividers
    static let cardBorder: CGFloat = 0.75

    /// Linienbreite für Chart-Achsen / Axis stroke width for charts
    static let chartAxis: CGFloat = 0.75
    /// Linienbreite für Chart-Grids / Lighter stroke width for chart grids
    static let chartGrid: CGFloat = 0.5

    /// Linienbreite für Ziel-/Durchschnitts-Linien / Stroke for goal and average lines
    static let chartGoal: CGFloat = 2
    /// Auswahl-/Marker-Linie in Charts / Selection or marker line width in charts
    static let chartSelection: CGFloat = 1
}

enum AppChart {
    /// Einheitliche Höhe für Balkencharts / Uniform height for bar and progress charts
    static let height: CGFloat = 220

    /// Horizontaler Außenabstand um Charts / Horizontal padding around charts
    static let horizontalPadding: CGFloat = AppSpace._16

    /// Abgerundete Ecken der Balken / Rounded bar corners for calmer visuals
    static let barCornerRadius: CGFloat = 6

    /// Abstand zwischen Bars/Marks / Spacing between bars and marks
    static let barSpacing: CGFloat = AppSpace._8

    /// Länge der Achsen-Markierungen / Length of axis markers
    static let axisMarkLength: CGFloat = 4

    /// Abstand zwischen Achsenlabels und Achse / Gap between axis labels and axis
    static let labelSpacing: CGFloat = AppSpace._8

    /// Größe des Selection-Dots / Size of the selection dot
    static let selectionDotSize: CGFloat = 6
}

/// A11y/HIG-relevante Konstanten / Accessibility constants following Apple HIG.
enum AppA11y {
    /// Mindest-Tap-Fläche laut Apple HIG / Minimum tap height following Apple HIG
    static let minTapHeight: CGFloat = 44
}
