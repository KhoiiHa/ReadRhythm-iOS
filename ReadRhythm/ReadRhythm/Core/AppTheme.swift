//
//  AppTheme.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 15.10.25.
//


//
//  AppTheme.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 15.10.25.
//

import SwiftUI

/// Kontext → Warum → Wie
/// - Kontext: Definiert Design-Tokens (Spacing, Radius, Shadow) und wiederverwendbare ViewStyles.
/// - Warum: Einheitliches visuelles System für Buttons, Karten, Container – wartbar und portfolio-freundlich.
/// - Wie: Statische Token-Definitionen + ViewModifier + ButtonStyle.

enum AppRadius {
    static let s: CGFloat = 4
    static let m: CGFloat = 8
    static let l: CGFloat = 16
    static let xl: CGFloat = 24
}

enum AppSpace {
    static let _4: CGFloat = 4
    static let _8: CGFloat = 8
    static let _12: CGFloat = 12
    static let _16: CGFloat = 16
    static let _24: CGFloat = 24
    static let _32: CGFloat = 32
}

enum AppShadow {
    static let elevation1 = Color.black.opacity(0.08)
    static let elevation2 = Color.black.opacity(0.12)
    static let elevation3 = Color.black.opacity(0.16)
    static let elevation4 = Color.black.opacity(0.20)
}

// MARK: - Reusable Modifiers

struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppSpace._12)
            .background(AppColors.Semantic.bgElevated)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.l)
                    .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.5)
            )
            .shadow(color: AppShadow.elevation1, radius: 2, x: 0, y: 1)
    }
}

extension View {
    func cardBackground() -> some View { modifier(CardBackground()) }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.vertical, AppSpace._12)
            .frame(maxWidth: .infinity)
            .background(
                AppColors.Semantic.tintPrimary
                    .opacity(configuration.isPressed ? 0.84 : 1.0)
            )
            .foregroundStyle(AppColors.Semantic.textInverse)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.m, style: .continuous))
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .padding(.vertical, AppSpace._8)
            .frame(maxWidth: .infinity)
            .background(
                AppColors.Semantic.bgElevated
                    .opacity(configuration.isPressed ? 0.9 : 1.0)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.m)
                    .stroke(AppColors.Semantic.borderMuted, lineWidth: 1)
            )
            .foregroundStyle(AppColors.Semantic.textPrimary)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.m, style: .continuous))
    }
}
