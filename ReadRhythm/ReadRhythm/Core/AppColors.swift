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
        static var primary: Color { Color(red: 98/255, green: 140/255, blue: 133/255) }
        static var secondary: Color { Color(red: 214/255, green: 193/255, blue: 164/255) }
    }

    enum Accent {
        static var success: Color { Color(red: 112/255, green: 155/255, blue: 117/255) }
        static var warning: Color { Color(red: 201/255, green: 155/255, blue: 73/255) }
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

    // MARK: - Semantik (systemdynamisch für Light/Dark)
    enum Semantic {
        // Backgrounds – folgen automatisch dem System (Light/Dark)
        static var bgPrimary: Color   { Color(UIColor.systemBackground) }
        static var bgSecondary: Color { Color(UIColor.secondarySystemBackground) }
        static var bgElevated: Color  { Color(UIColor.tertiarySystemBackground) }

        // Text – dynamische Label-Farben für korrekten Kontrast
        static var textPrimary: Color   { Color(UIColor.label) }
        static var textSecondary: Color { Color(UIColor.secondaryLabel) }
        static var textInverse: Color   { Color(UIColor.systemBackground) }

        // Tints – App-Akzent; Brand.primary bleibt als visueller Akzent verfügbar
        static var tintPrimary: Color   { Color.accentColor }
        static var tintSecondary: Color { Brand.secondary }

        // Border/Separator – systemdynamisch
        static var borderMuted: Color  { Color(UIColor.separator) }
        static var borderStrong: Color { Color(UIColor.tertiaryLabel) }

        // Charts – Achsen an UI-Labels angelehnt, Balken/Selection aus Accent
        static var chartBar: Color       { Accent.success }
        static var chartAxis: Color      { Color(UIColor.tertiaryLabel) }
        static var chartSelection: Color { Accent.warning }

        // Shadows – dezent in Light, stärker in Dark
        static var shadowColor: Color {
            Color(UIColor { trait in
                let alpha: CGFloat = (trait.userInterfaceStyle == .dark) ? 0.35 : 0.10
                return UIColor.black.withAlphaComponent(alpha)
            })
        }
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
        static var secondaryBar: Color { Brand.secondary.opacity(0.55) }

        /// Achsen und Gridlines
        static var axis: Color { Semantic.chartAxis }
    }
}
