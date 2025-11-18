// MARK: - Farb-Tokens / Color Tokens
// Bündelt die gesamte Farbpalette für konsistente UI-Erlebnisse /
// Centralizes the color palette for a consistent UI experience.

import SwiftUI

// Kontext: Zentrale Farb-Tokens der App / Context: Central color tokens for the app
// Warum: Konsistente Visuals mit AA-Kontrast / Why: Consistent visuals with AA contrast
// Wie: Brand & Neutral leiten Semantic Tokens ab / How: Brand & neutral colors drive semantic tokens

enum AppColors {
    // MARK: - Brand (Behance-inspiriert) / Brand (Behance-inspired)
    enum Brand {
        /// Primär: warmes Rot für Aktionen / Primary: warm red for actions and highlights
        static let teal: Color = .dynamic(
            // Behance-Rot-Verlauf / Behance red gradient
            light: Color(red: 0.73, green: 0.47, blue: 0.46),   // #BA7876
            dark:  Color(red: 0.65, green: 0.32, blue: 0.31)    // #A55250
        )
        /// Sekundär: ruhiges Ocker für Akzente / Secondary: calm ochre for accents
        static let ochre: Color = .dynamic(
            light: Color(red: 0.83, green: 0.64, blue: 0.31),   // #D4A24F
            dark:  Color(red: 0.86, green: 0.70, blue: 0.42)    // #DBB369
        )

        // Backwards-Compat für alte Namen / Backwards compatibility for legacy names
        static var primary: Color { teal }
        static var secondary: Color { ochre }
    }

    // MARK: - Neutral (warme Töne) / Neutral (warm tones)
    enum Neutral {
        /// Screen-Hintergrund für große Flächen / Screen background for large surfaces
        static let screen: Color = .dynamic(
            light: Color(red: 0.97, green: 0.95, blue: 0.91),   // #F7F2E8
            dark:  Color(red: 0.11, green: 0.11, blue: 0.10)    // #1C1C1A
        )
        /// Kartenfläche / Elevated surface color
        static let surface: Color = .dynamic(
            light: Color(red: 0.91, green: 0.88, blue: 0.84),   // #E7E0D6
            dark:  Color(red: 0.16, green: 0.16, blue: 0.14)    // #282823
        )
        /// Rahmen und Separator / Frame and separator color
        static let outline: Color = .dynamic(
            light: Color(red: 0.72, green: 0.68, blue: 0.63),   // #B7ADA0
            dark:  Color(red: 0.45, green: 0.43, blue: 0.39)    // #736E63
        )
        /// Primärtext / Primary text color
        static let textPrimary: Color = .dynamic(
            light: Color(red: 0.14, green: 0.14, blue: 0.12),   // #23231F
            dark:  Color(red: 0.93, green: 0.92, blue: 0.90)    // #EEECE6
        )
        /// Sekundärtext / Secondary text color
        static let textSecondary: Color = .dynamic(
            light: Color(red: 0.36, green: 0.35, blue: 0.32),   // #5C5A51
            dark:  Color(red: 0.79, green: 0.77, blue: 0.72)    // #C9C4B8
        )
    }

    // MARK: - Semantic Tokens / Semantische Tokens
    enum Semantic {
        // Backgrounds / Hintergründe
        static let bgScreen   = Neutral.screen
        static let bgPrimary  = Neutral.screen       // Alias für Bestandscode / Alias for legacy calls
        static let bgSecondary = Neutral.surface     // Alias für Bestandscode / Alias for legacy calls
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
            // Behance-Red-Soft (#EFD6D6 / #E4C3C3) / Soft Behance red accent
            light: Color(red: 0.94, green: 0.84, blue: 0.84),
            dark:  Color(red: 0.26, green: 0.15, blue: 0.15)
        )
        static let chipFg = Color.dynamic(
            // Tieferes Rot für Kontrast / Deeper red for contrast
            light: Color(red: 0.56, green: 0.28, blue: 0.27),   // etwa zwischen 600/700
            dark:  Color(red: 0.93, green: 0.88, blue: 0.87)
        )
        // Badges (z. B. "Google Books") / Badge styling for meta tags
        static let badgeBg: Color = Brand.teal.opacity(0.14)
        static let badgeFg: Color = Brand.teal
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
                let alpha: CGFloat = (trait.userInterfaceStyle == .dark) ? 0.35 : 0.10
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
