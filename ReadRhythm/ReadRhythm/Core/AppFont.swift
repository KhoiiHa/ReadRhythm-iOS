// MARK: - Typografie-System / Typography System
// Kontext: Einheitliches Typografie-System für ReadRhythm / Context: Unified typography system for ReadRhythm.
// Warum: Stärkt Branding & reduziert Styling-Duplikate / Why: Strengthens branding and reduces styling duplication.
// Wie: Statische SwiftUI-Fonts als benannte Tokens / How: Provides named SwiftUI font tokens.
import SwiftUI

// Kontext: Behance-inspirierte Lesbarkeit / Context: Behance-inspired readability
// Warum: Konsistente Hierarchie & A11y-Defaults / Why: Consistent hierarchy and accessibility defaults
// Wie: Tokenisierte Größen + optionale Custom-Font / How: Tokenized sizes with optional custom font support

enum AppFont {
    // Optionaler Custom-Font-Name / Optional custom font name
    // Nil nutzt die Systemschrift für portable Builds / Nil falls back to the system font
    static let customName: String? = nil

    // MARK: - Token Sizes / Schriftgrößen-Tokens
    enum Size {
        static let display: CGFloat  = 32   // Hero/Timer / Hero or timer display
        static let hL: CGFloat       = 22   // Heading Large / Large heading
        static let hM: CGFloat       = 20   // Heading Medium / Medium heading
        static let hS: CGFloat       = 18   // Heading Small / Small heading
        static let body: CGFloat     = 16   // Standard Body / Default body copy
        static let caption: CGFloat  = 14
        static let caption2: CGFloat = 12
        // Legacy/BC für 17pt Layouts / Legacy compatibility for 17pt layouts
        static let bodyLegacy17: CGFloat = 17
    }

    // MARK: - Core Font Builders / Zentrale Font-Helfer
    private static func font(_ size: CGFloat, _ weight: Font.Weight) -> Font {
        if let name = customName, UIFont(name: name, size: size) != nil {
            return .custom(name, size: size).weight(weight)
        } else {
            return .system(size: size, weight: weight, design: .rounded)
        }
    }

    // MARK: - Public Tokens / Öffentliche Tokens
    static func headingL(_ weight: Font.Weight = .semibold) -> Font { font(Size.hL, weight) }
    static func headingM(_ weight: Font.Weight = .semibold) -> Font { font(Size.hM, weight) }
    static func headingS(_ weight: Font.Weight = .semibold) -> Font { font(Size.hS, weight) }
    static func bodyStandard(_ weight: Font.Weight = .regular) -> Font { font(Size.body, weight) }

    // Body Small für Metadaten / Body small for metadata rows
    static func bodySmall(_ weight: Font.Weight = .regular) -> Font {
        font(Size.caption, weight) // 14pt – ideal für Meta-Texte / 14pt – ideal for meta text
    }

    // Primary caption tokens / Primäre Caption-Tokens
    static func caption1(_ weight: Font.Weight = .regular) -> Font { font(Size.caption, weight) }
    static func caption2(_ weight: Font.Weight = .regular) -> Font { font(Size.caption2, weight) }

    // Backwards-kompatibler Alias / Backwards-compatible alias
    static func caption(_ weight: Font.Weight = .regular) -> Font { caption1(weight) }

    // MARK: - Backwards Compatibility / Rückwärtskompatibilität
    static var titleLarge: Font { font(Size.display, .semibold) }
    static var title: Font { font(Size.hL, .semibold) }      // war 22 → gleich / remains 22 pt
    static var body: Font { font(Size.body, .regular) }      // vorher 17 → jetzt 16 / calmer body text
    static var captionLegacy13: Font {                       // BC für 13pt-Aufrufer / compatibility for 13 pt usage
        .system(size: 13, weight: .regular, design: .rounded)
    }

    // MARK: - Line Height Helpers / Zeilenabstands-Helfer
    static func lineSpacing(for size: CGFloat, multiplier: CGFloat) -> CGFloat {
        // SwiftUI: Zeilenabstand = Ziellinie - Fontgröße /
        // SwiftUI line spacing = target line height minus font size
        (size * multiplier) - size
    }
}

// MARK: - Convenience Modifiers / Konsistente Nutzung in Views
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
