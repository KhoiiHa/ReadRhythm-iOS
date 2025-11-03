/// - Kontext: Phase 15 – visuelles Token-System (Spacing, Radius, Shadow + Farb-Semantik über AppColors).
/// - Warum: Konsistenter Behance-Look (warm, ruhig), AA-Kontrast, saubere Wiederverwendung.
/// - Wie: Tokens + ViewModifier + ButtonStyle, alle Farben nur über AppColors.Semantic.
import SwiftUI


enum AppRadius {
    static let s: CGFloat = 4
    static let m: CGFloat = 8
    static let l: CGFloat = 16
    /// Alias for large radius
    static let lg: CGFloat = l
    static let xl: CGFloat = 24
}

enum AppSpace {
    // Base scale (legacy-safe)
    static let _4:  CGFloat = 4
    static let _6:  CGFloat = 6
    static let _8:  CGFloat = 8
    static let _12: CGFloat = 12
    static let _16: CGFloat = 16
    static let _24: CGFloat = 24
    static let _32: CGFloat = 32

    // Semantic aliases (preferred)
    static let xs: CGFloat = _4
    static let sm: CGFloat = _8
    static let md: CGFloat = _12
    static let lg: CGFloat = _16
    static let xl: CGFloat = _24
    static let xxl: CGFloat = _32

    // Convenience gaps for stacks
    static let stackTight: CGFloat = sm
    static let stack: CGFloat = md
    static let stackLoose: CGFloat = lg
}

enum AppShadow {
    struct Spec { let color: Color; let radius: CGFloat; let x: CGFloat; let y: CGFloat }
    /// Sanfter Schatten für Karten/Tiles (Phase 4)
    static let card = Spec(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    static let elevation1 = Color.black.opacity(0.08)
    static let elevation2 = Color.black.opacity(0.12)
    static let elevation3 = Color.black.opacity(0.16)
    static let elevation4 = Color.black.opacity(0.20)
}

// MARK: - Reusable Modifiers

struct ScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppColors.Semantic.bgScreen)
    }
}

struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppSpace._12)
            .background(AppColors.Semantic.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.l)
                    .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.5)
            )
            .shadow(color: AppColors.Semantic.shadowColor, radius: 3, x: 0, y: 1)
    }
}

struct MetricTile: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, AppSpace._12)
            .padding(.horizontal, AppSpace._16)
            .background(AppColors.Semantic.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.l)
                    .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75)
            )
    }
}

struct TagCapsule: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .padding(.vertical, 6)
            .padding(.horizontal, AppSpace._12)
            .background(AppColors.Semantic.chipBg)
            .clipShape(Capsule(style: .continuous))
            .overlay(
                Capsule(style: .continuous)
                    .stroke(AppColors.Semantic.chipBg.opacity(0.6), lineWidth: 0.75)
            )
            .foregroundStyle(AppColors.Semantic.chipFg)
    }
}

extension View {
    func screenBackground() -> some View { modifier(ScreenBackground()) }
    func cardBackground() -> some View { modifier(CardBackground()) }
    func metricTile() -> some View { modifier(MetricTile()) }
    func tagCapsule() -> some View { modifier(TagCapsule()) }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.vertical, AppSpace._12)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .background(
                AppColors.Semantic.tintPrimary
                    .opacity(configuration.isPressed ? 0.84 : (isEnabled ? 1.0 : 0.6))
            )
            .foregroundStyle(AppColors.Semantic.textInverse)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.m, style: .continuous))
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .padding(.vertical, AppSpace._8)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .background(
                AppColors.Semantic.bgCard
                    .opacity(configuration.isPressed ? 0.9 : (isEnabled ? 1.0 : 0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.m)
                    .stroke(AppColors.Semantic.borderMuted, lineWidth: 1)
            )
            .foregroundStyle(AppColors.Semantic.textPrimary)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.m, style: .continuous))
    }
}
