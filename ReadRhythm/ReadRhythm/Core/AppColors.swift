import SwiftUI

// Kontext → Warum → Wie
// Kontext: Zentrale Farb-Tokens der App. Phase 15 führt eine warme Editorial-Palette ein.
// Warum: Konsistente, portfolio-taugliche Visuals (AA-Kontrast), identische Sprache in Light/Dark.
// Wie: Brand + Neutral → Semantic Tokens. Helper für dynamische Farben ohne Asset-Konflikte.

enum AppColors {
    // MARK: - Brand (gedämpftes Teal + dezentes Ocker)
    enum Brand {
        /// Primär: gedämpftes Teal (UI-Aktionen, Links, Highlights)
        static let teal: Color = .dynamic(
            light: Color(red: 0.50, green: 0.70, blue: 0.67),   // #80B2AB
            dark:  Color(red: 0.56, green: 0.78, blue: 0.74)    // #8FC7BE (leicht heller im Dark)
        )
        /// Sekundär: ruhiges Ocker (Badges, Chart-Akzente)
        static let ochre: Color = .dynamic(
            light: Color(red: 0.83, green: 0.64, blue: 0.31),   // #D4A24F
            dark:  Color(red: 0.86, green: 0.70, blue: 0.42)    // #DBB369
        )

        // Backwards-compat (alte Namen)
        static var primary: Color { teal }
        static var secondary: Color { ochre }
    }

    // MARK: - Neutral (warme Neutrals für ruhige Flächen)
    enum Neutral {
        /// Screen-Hintergrund (große Flächen)
        static let screen: Color = .dynamic(
            light: Color(red: 0.97, green: 0.95, blue: 0.91),   // #F7F2E8
            dark:  Color(red: 0.11, green: 0.11, blue: 0.10)    // #1C1C1A
        )
        /// Kartenfläche / Elevated Surface
        static let surface: Color = .dynamic(
            light: Color(red: 0.91, green: 0.88, blue: 0.84),   // #E7E0D6
            dark:  Color(red: 0.16, green: 0.16, blue: 0.14)    // #282823
        )
        /// Rahmen/Separator/Axis
        static let outline: Color = .dynamic(
            light: Color(red: 0.72, green: 0.68, blue: 0.63),   // #B7ADA0
            dark:  Color(red: 0.45, green: 0.43, blue: 0.39)    // #736E63
        )
        /// Primärtext
        static let textPrimary: Color = .dynamic(
            light: Color(red: 0.14, green: 0.14, blue: 0.12),   // #23231F
            dark:  Color(red: 0.93, green: 0.92, blue: 0.90)    // #EEECE6
        )
        /// Sekundärtext
        static let textSecondary: Color = .dynamic(
            light: Color(red: 0.36, green: 0.35, blue: 0.32),   // #5C5A51
            dark:  Color(red: 0.79, green: 0.77, blue: 0.72)    // #C9C4B8
        )
    }

    // MARK: - Semantic Tokens (einheitliche Sprache für UI)
    enum Semantic {
        // Backgrounds
        static let bgScreen   = Neutral.screen
        static let bgPrimary  = Neutral.screen       // Alias für Bestandscode
        static let bgSecondary = Neutral.surface     // Alias für Bestandscode
        static let bgCard     = Neutral.surface
        // Text
        static let text       = Neutral.textPrimary
        static let textPrimary = Neutral.textPrimary // Alias für Bestandscode
        static let textSecondary = Neutral.textSecondary
        static let textMuted  = Neutral.textSecondary
        static let textInverse: Color = .dynamic(light: .white, dark: .black)
        // Tints
        static let tintPrimary   = Brand.teal
        static let tintSecondary = Brand.ochre
        // Chips / Pills
        static let chipBg = Color.dynamic(
            light: Color(red: 0.90, green: 0.95, blue: 0.93),
            dark:  Color(red: 0.17, green: 0.24, blue: 0.23)
        )
        static let chipFg = Color.dynamic(
            light: Color(red: 0.14, green: 0.28, blue: 0.27),
            dark:  Color(red: 0.78, green: 0.89, blue: 0.86)
        )
        // Separators
        static let borderMuted: Color  = Neutral.outline
        static let borderStrong: Color = Neutral.outline
        static let separator: Color    = Neutral.outline
        // Charts
        static let chartBar  = Brand.teal
        static let chartAxis = Neutral.outline
        static let chartSelection = Brand.ochre
        // Shadows
        static var shadowColor: Color {
            Color(UIColor { trait in
                let alpha: CGFloat = (trait.userInterfaceStyle == .dark) ? 0.35 : 0.10
                return UIColor.black.withAlphaComponent(alpha)
            })
        }
    }

    // MARK: - Aliases (Backwards-compat für existierende Aufrufe)
    static var brandPrimary: Color { Brand.primary }
    static var brandSecondary: Color { Brand.secondary }

    static var surfacePrimary: Color { Semantic.bgPrimary }
    static var surfaceSecondary: Color { Semantic.bgSecondary }

    static var textPrimary: Color { Semantic.textPrimary }
    static var textSecondary: Color { Semantic.textSecondary }
    static var textInverse: Color { Semantic.textInverse }

    // MARK: - Charts (Kompatibilität + Token-Weiterleitung)
    enum Chart {
        static var barPrimary: Color { Semantic.chartBar }
        static var goalLine: Color { Semantic.chartSelection }
        static var secondaryBar: Color { Brand.secondary.opacity(0.55) }
        static var axis: Color { Semantic.chartAxis }
    }
}

// MARK: - Utilities
extension Color {
    /// Einfacher Dynamic-Color-Helper ohne Asset-Katalog.
    static func dynamic(light: Color, dark: Color) -> Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

#if DEBUG
// MARK: - Preview für Case Study & Visual QA
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
