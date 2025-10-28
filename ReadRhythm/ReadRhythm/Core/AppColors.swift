// Kontext: Diese Farbpalette zentralisiert alle Marken- und UI-Farben der App.
// Warum: Konsistente Farbnutzung braucht einen einzigen Wahrheitsanker statt Inline-Hexwerte.
// Wie: Wir mappen definierte Markenfarben auf statische SwiftUI-Properties für hell/dunkel.
import SwiftUI

/// Kontext → Warum → Wie
/// - Kontext: Zentrale Farb-Tokens der App. Verweisen auf Color Sets im Asset Catalog (Any/Dark).
/// - Warum: Einheitliche Farbverwendung über alle Features; leichtes Austauschen im Portfolio-Refactor.
/// - Wie: `Color`-Initialisierer liefern definierte Markenwerte; semantische Farben bauen auf den Basis-Tokens auf.
enum AppColors {
    // MARK: - Brand & Accent (Basis-Tokens)
    enum Brand {
        static var primary: Color { Color(red: 127/255, green: 179/255, blue: 174/255) }
        static var secondary: Color { Color(red: 216/255, green: 200/255, blue: 180/255) }
    }

    enum Accent {
        static var success: Color { Color(red: 122/255, green: 174/255, blue: 140/255) }
        static var warning: Color { Color(red: 212/255, green: 162/255, blue: 79/255) }
        static var error: Color { Color("accent.error", bundle: .main) }
    }

    // MARK: - Neutrals
    enum Neutral {
        static var _0: Color   { Color("neutral.0", bundle: .main) }
        static var _50: Color  { Color("neutral.50", bundle: .main) }
        static var _100: Color { Color("neutral.100", bundle: .main) }
        static var _200: Color { Color("neutral.200", bundle: .main) }
        static var _300: Color { Color("neutral.300", bundle: .main) }
        static var _700: Color { Color("neutral.700", bundle: .main) }
        static var _900: Color { Color("neutral.900", bundle: .main) }
    }

    // MARK: - Semantik (auf Basis der Palette)
    enum Semantic {
        // Backgrounds
        static var bgPrimary: Color   { Neutral._50 }                                   // App-Hintergrund
        static var bgSecondary: Color { Color(red: 245/255, green: 240/255, blue: 230/255) } // Sektionen
        static var bgElevated: Color  { Color(red: 233/255, green: 225/255, blue: 214/255) } // Karten

        // Text
        static var textPrimary: Color   { Neutral._900 }
        static var textSecondary: Color { Neutral._700 }
        static var textInverse: Color   { Neutral._50 }

        // Tints
        static var tintPrimary: Color   { Brand.primary }
        static var tintSecondary: Color { Brand.secondary }

        // Border
        static var borderMuted: Color  { Neutral._300 }
        static var borderStrong: Color { Neutral._700 }

        // Charts
        static var chartBar: Color       { Accent.success }
        static var chartAxis: Color      { Neutral._300 }
        static var chartSelection: Color { Accent.warning }
    }
    // MARK: - Aliases (Phase 4 convenience)
    /// Für Views, die mit systemweiten Tokens arbeiten wollen, ohne die Palette zu kennen.
    /// Diese Aliase mappen auf die bestehende semantische Palette oben.
    static var brandPrimary: Color { Brand.primary }
    static var brandSecondary: Color { Brand.secondary }

    static var surfacePrimary: Color { Semantic.bgPrimary }
    static var surfaceSecondary: Color { Semantic.bgSecondary }

    static var textPrimary: Color { Semantic.textPrimary }
    static var textSecondary: Color { Semantic.textSecondary }
    static var textInverse: Color { Semantic.textInverse }


    // MARK: - Charts (extended)
    enum Chart {
        /// Primäre Farbe für Balken
        static var barPrimary: Color { Accent.success }

        /// Farbe für das Ziel-Linien-Overlay oder Durchschnitt
        static var goalLine: Color { Accent.warning }

        /// Farbe für Sekundär- oder Vergleichs-Daten
        static var secondaryBar: Color { Brand.secondary.opacity(0.6) }

        /// Achsen und Gridlines
        static var axis: Color { Semantic.chartAxis }
    }
}
