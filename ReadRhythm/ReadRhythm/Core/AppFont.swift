// Kontext: Wir definieren ein einheitliches Typografie-System für ReadRhythm.
// Warum: Konsistente Schriftgrößen stärken das Branding und reduzieren Styling-Duplikate.
// Wie: Statische SwiftUI-Fonts stellen klar benannte Tokens bereit, die Views konsumieren.
import SwiftUI

// Kontext → Warum → Wie
// Kontext: Zentrales Typo-System für ReadRhythm (Phase 15 – Behance-Look, ruhige Lesbarkeit).
// Warum: Konsistente, skalierbare Tokens; klare Headings/Body-Hierarchie; A11y-freundliche Defaults.
// Wie: Tokenisierte Größen + optionale Custom-Font; Line-Height via lineSpacing; #if DEBUG Previews.

enum AppFont {
    // Optional: Trage hier den Custom-Font-Namen ein, falls eingebunden (z. B. "Poppins").
    // Bei nil wird System (SF/Inter) genutzt – für portable Builds.
    static let customName: String? = nil

    // MARK: - Token Sizes (Behance-orientiert)
    enum Size {
        static let display: CGFloat  = 32   // Hero/Timer
        static let hL: CGFloat       = 22   // Heading Large
        static let hM: CGFloat       = 20   // Heading Medium
        static let hS: CGFloat       = 18   // Heading Small
        static let body: CGFloat     = 16   // Standard Body
        static let caption: CGFloat  = 14
        static let caption2: CGFloat = 12
        // Legacy/BC (falls altes Layout 17pt erwartet)
        static let bodyLegacy17: CGFloat = 17
    }

    // MARK: - Core Font Builders
    private static func font(_ size: CGFloat, _ weight: Font.Weight) -> Font {
        if let name = customName, UIFont(name: name, size: size) != nil {
            return .custom(name, size: size).weight(weight)
        } else {
            return .system(size: size, weight: weight, design: .rounded)
        }
    }

    // MARK: - Public Tokens (neue Skala)
    static func headingL(_ weight: Font.Weight = .semibold) -> Font { font(Size.hL, weight) }
    static func headingM(_ weight: Font.Weight = .semibold) -> Font { font(Size.hM, weight) }
    static func headingS(_ weight: Font.Weight = .semibold) -> Font { font(Size.hS, weight) }
    static func bodyStandard(_ weight: Font.Weight = .regular) -> Font { font(Size.body, weight) }

    // Optional: Body Small (z. B. für Metadaten, Autorenzeile)
    static func bodySmall(_ weight: Font.Weight = .regular) -> Font {
        font(Size.caption, weight) // 14pt – etwas kleiner als Body, ideal für Meta-Texte
    }

    // Primary caption tokens
    static func caption1(_ weight: Font.Weight = .regular) -> Font { font(Size.caption, weight) }
    static func caption2(_ weight: Font.Weight = .regular) -> Font { font(Size.caption2, weight) }

    // Backwards-compatible alias (alt: caption() ohne Nummer)
    static func caption(_ weight: Font.Weight = .regular) -> Font { caption1(weight) }

    // MARK: - Backwards Compatibility (bestehende Aufrufe in Views)
    static var titleLarge: Font { font(Size.display, .semibold) }
    static var title: Font { font(Size.hL, .semibold) }      // war 22 → gleich
    static var body: Font { font(Size.body, .regular) }      // vorher 17 → jetzt 16 (ruhiger, Behance)
    static var captionLegacy13: Font {                       // BC für 13pt-Aufrufer
        .system(size: 13, weight: .regular, design: .rounded)
    }

    // MARK: - Line Height Helpers (≈1.6 für Headings, ≈1.5 für Body)
    static func lineSpacing(for size: CGFloat, multiplier: CGFloat) -> CGFloat {
        // SwiftUI: Zeilenabstand = (Ziellinie - FontSize)
        (size * multiplier) - size
    }
}

// MARK: - Convenience Modifiers (einheitliche Nutzung in Views)
struct HeadingL: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFont.headingL())
            .lineSpacing(AppFont.lineSpacing(for: AppFont.Size.hL, multiplier: 1.6))
    }
}
struct HeadingM: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFont.headingM())
            .lineSpacing(AppFont.lineSpacing(for: AppFont.Size.hM, multiplier: 1.6))
    }
}
struct HeadingS: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFont.headingS())
            .lineSpacing(AppFont.lineSpacing(for: AppFont.Size.hS, multiplier: 1.6))
    }
}
struct BodyText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFont.bodyStandard())
            .lineSpacing(AppFont.lineSpacing(for: AppFont.Size.body, multiplier: 1.5))
    }
}
struct CaptionText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFont.caption())
            .lineSpacing(AppFont.lineSpacing(for: AppFont.Size.caption, multiplier: 1.4))
    }
}

extension View {
    func headingL() -> some View { modifier(HeadingL()) }
    func headingM() -> some View { modifier(HeadingM()) }
    func headingS() -> some View { modifier(HeadingS()) }
    func bodyText() -> some View { modifier(BodyText()) }
    func captionText() -> some View { modifier(CaptionText()) }
}

#if DEBUG
struct AppFont_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Discover").headingL().foregroundStyle(AppColors.Semantic.text)
            Text("What will the final product look like?").headingS().foregroundStyle(AppColors.Semantic.textMuted)
            Text("Body text – readable, calm, warm. This is how standard paragraphs look.")
                .bodyText()
                .foregroundStyle(AppColors.Semantic.text)
            Text("Meta / caption").captionText().foregroundStyle(AppColors.Semantic.textMuted)
        }
        .padding()
        .background(AppColors.Semantic.bgScreen)
        .previewLayout(.sizeThatFits)
    }
}
#endif
