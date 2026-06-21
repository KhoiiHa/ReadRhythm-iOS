// MARK: - Farb-Tokens / Color Tokens
// Bündelt die gesamte Farbpalette für konsistente UI-Erlebnisse /
// Centralizes the color palette for a consistent UI experience.

import SwiftUI

// Kontext: Zentrale Farb-Tokens der App / Context: Central color tokens for the app
// Warum: Konsistente Visuals mit AA-Kontrast / Why: Consistent visuals with AA contrast
// Wie: Brand & Neutral leiten Semantic Tokens ab / How: Brand & neutral colors drive semantic tokens

enum AppColors {
    // MARK: - Brand / Marke
    enum Brand {
        /// Primär: tiefes Teal für klare Aktionen / Primary: deep teal for clear actions
        static let teal: Color = .dynamic(
            light: Color(red: 0.09, green: 0.42, blue: 0.39),   // #176B63
            dark:  Color(red: 0.29, green: 0.78, blue: 0.72)    // #4AC7B8
        )
        /// Sekundär: warmes Korall für Listening, Highlights und sekundäre Betonung /
        /// Secondary: warm coral for listening, highlights, and secondary emphasis
        static let ochre: Color = .dynamic(
            light: Color(red: 0.72, green: 0.28, blue: 0.23),   // #B8473A
            dark:  Color(red: 0.95, green: 0.52, blue: 0.43)    // #F2856E
        )

        // Backwards-Compat für alte Namen / Backwards compatibility for legacy names
        static var primary: Color { teal }
        static var secondary: Color { ochre }
    }

    // MARK: - Neutral (warme Töne) / Neutral (warm tones)
    enum Neutral {
        /// Screen-Hintergrund für große Flächen / Screen background for large surfaces
        static let screen: Color = .dynamic(
            light: Color(red: 0.96, green: 0.97, blue: 0.95),   // #F4F7F2
            dark:  Color(red: 0.06, green: 0.08, blue: 0.08)    // #0F1414
        )
        /// Kartenfläche / Elevated surface color
        static let surface: Color = .dynamic(
            light: Color(red: 1.00, green: 0.99, blue: 0.97),   // #FFFDF8
            dark:  Color(red: 0.11, green: 0.14, blue: 0.13)    // #1C2321
        )
        /// Sanft getönte Fläche für Suchfelder, Filter und ruhige Sektionen /
        /// Soft tinted surface for search fields, filters, and quiet sections
        static let surfaceMuted: Color = .dynamic(
            light: Color(red: 0.91, green: 0.94, blue: 0.91),   // #E8EFE8
            dark:  Color(red: 0.14, green: 0.18, blue: 0.17)    // #242E2B
        )
        /// Rahmen und Separator / Frame and separator color
        static let outline: Color = .dynamic(
            light: Color(red: 0.75, green: 0.80, blue: 0.76),   // #BFCCC1
            dark:  Color(red: 0.30, green: 0.38, blue: 0.36)    // #4D615C
        )
        /// Primärtext / Primary text color
        static let textPrimary: Color = .dynamic(
            light: Color(red: 0.10, green: 0.14, blue: 0.13),   // #1A2421
            dark:  Color(red: 0.93, green: 0.96, blue: 0.94)    // #EDF5F0
        )
        /// Sekundärtext / Secondary text color
        static let textSecondary: Color = .dynamic(
            light: Color(red: 0.34, green: 0.40, blue: 0.37),   // #56665F
            dark:  Color(red: 0.75, green: 0.82, blue: 0.78)    // #BFCFC7
        )
    }

    // MARK: - Semantic Tokens / Semantische Tokens
    enum Semantic {
        // Backgrounds / Hintergründe
        static let bgScreen   = Neutral.screen
        static let bgPrimary  = Neutral.screen       // Alias für Bestandscode / Alias for legacy calls
        static let bgSecondary = Neutral.surfaceMuted // Alias für Bestandscode / Alias for legacy calls
        static let bgCard     = Neutral.surface
        // Text / Texte
        static let text       = Neutral.textPrimary
        static let textPrimary = Neutral.textPrimary // Alias für Bestandscode / Alias for legacy calls
        static let textSecondary = Neutral.textSecondary
        static let textMuted  = Neutral.textSecondary
        static let textInverse: Color = .dynamic(light: .white, dark: .black)
        // Tints / Akzentfarben
        static let tintPrimary   = Brand.teal
        static let tintSecondary = Brand.ochre
        // Chips / Pills / Chips & Pills styling
        static let chipBg = Color.dynamic(
            light: Color(red: 0.84, green: 0.93, blue: 0.90),   // #D6EEE6
            dark:  Color(red: 0.10, green: 0.28, blue: 0.26)    // #1A4742
        )
        static let chipFg = Color.dynamic(
            light: Color(red: 0.06, green: 0.34, blue: 0.31),   // #0F574F
            dark:  Color(red: 0.79, green: 0.96, blue: 0.91)    // #C9F5E8
        )
        // Badges (z. B. "Google Books") / Badge styling for meta tags
        static let badgeBg: Color = Brand.ochre.opacity(0.14)
        static let badgeFg: Color = Brand.ochre
        // Separators / Separatoren
        static let borderMuted: Color  = Neutral.outline
        static let borderStrong: Color = Neutral.outline
        static let separator: Color    = Neutral.outline
        // Charts / Diagramme
        static let chartBar  = Brand.teal
        static let chartAxis = Neutral.outline
        static let chartSelection = Brand.ochre
        // Shadows / Schattenfarben
        static var shadowColor: Color {
            Color(UIColor { trait in
                let alpha: CGFloat = (trait.userInterfaceStyle == .dark) ? 0.42 : 0.12
                return UIColor.black.withAlphaComponent(alpha)
            })
        }
        // Alias für Bestandscode
        static var shadow: Color { shadowColor }
    }

    // MARK: - Aliases / Alias-Zugriffe
    static var brandPrimary: Color { Brand.primary }
    static var brandSecondary: Color { Brand.secondary }

    static var surfacePrimary: Color { Semantic.bgPrimary }
    static var surfaceSecondary: Color { Semantic.bgSecondary }

    static var textPrimary: Color { Semantic.textPrimary }
    static var textSecondary: Color { Semantic.textSecondary }
    static var textInverse: Color { Semantic.textInverse }

    // MARK: - Charts (Kompatibilität) / Charts (compatibility)
    enum Chart {
        static var barPrimary: Color { Semantic.chartBar }
        static var goalLine: Color { Semantic.chartSelection }
        static var secondaryBar: Color { Brand.secondary.opacity(0.55) }
        static var axis: Color { Semantic.chartAxis }
    }
}

// MARK: - Utilities / Dienstprogramme
extension Color {
    /// Einfacher Dynamic-Color-Helper ohne Asset-Katalog /
    /// Simple dynamic color helper without asset catalog usage.
    static func dynamic(light: Color, dark: Color) -> Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

#if DEBUG
// MARK: - Preview für Case Study & Visual QA / Preview for case study & visual QA
struct AppColors_DebugPreview: View {
    let cols = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("AppColors – Semantic Tokens")
                    .font(.title3.bold())
                    .foregroundStyle(AppColors.Semantic.text)
                LazyVGrid(columns: cols, spacing: 12) {
                    token("bgScreen", AppColors.Semantic.bgScreen)
                    token("bgCard", AppColors.Semantic.bgCard)
                    token("separator", AppColors.Semantic.separator)
                    token("text", AppColors.Semantic.text)
                    token("textMuted", AppColors.Semantic.textMuted)
                    token("tintPrimary", AppColors.Semantic.tintPrimary)
                    token("tintSecondary", AppColors.Semantic.tintSecondary)
                    token("chipBg", AppColors.Semantic.chipBg)
                    token("chipFg", AppColors.Semantic.chipFg)
                    token("badgeBg", AppColors.Semantic.badgeBg)
                    token("badgeFg", AppColors.Semantic.badgeFg)
                    token("chartBar", AppColors.Semantic.chartBar)
                    token("chartAxis", AppColors.Semantic.chartAxis)
                }
                .padding(16)
                .background(AppColors.Semantic.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding()
            .background(AppColors.Semantic.bgScreen.ignoresSafeArea())
        }
    }
    private func token(_ name: String, _ color: Color) -> some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
                .frame(height: 56)
            Text(name).font(.caption)
                .foregroundStyle(AppColors.Semantic.text)
        }
        .accessibilityIdentifier("color.\(name)")
    }
}
struct AppColors_DebugPreview_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppColors_DebugPreview().preferredColorScheme(.light)
            AppColors_DebugPreview().preferredColorScheme(.dark)
        }
    }
}
#endif
