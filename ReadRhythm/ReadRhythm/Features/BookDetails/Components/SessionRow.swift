//
//  SessionRow.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 19.10.25.
//

import SwiftUI

/// Einzelzeile für eine Lesesession.
/// - Fokus: klare Typografie, relative Datumsinfo, i18n & A11y.
/// - Keine Model-Abhängigkeit: View bekommt `date` & `minutes` injiziert.
struct SessionRow: View {
    let date: Date
    let minutes: Int

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: AppSpace._12) {
            // Leading: Datum (abgekürzt) + relative Info
            VStack(alignment: .leading, spacing: AppSpace._4) {
                Text(date, format: .dateTime
                    .day(.twoDigits)
                    .month(.abbreviated)
                    .year(.defaultDigits))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.Semantic.textPrimary)
                    .accessibilityLabel(Text("session.date"))

                Text(relativeString(for: date))
                    .font(.footnote)
                    .foregroundStyle(AppColors.Semantic.textSecondary)
                    .accessibilityHidden(true) // dekorativ zusätzlich zum Datum
            }

            Spacer(minLength: 0)

            // Trailing: Minuten als „Pill“ mit Icon
            HStack(spacing: AppSpace._6) {
                Image(systemName: "stopwatch")
                    .imageScale(.small)
                Text("\(minutes)")
                    .font(.subheadline.weight(.semibold))
                Text(String(localized: "session.minutes.suffix")) // z. B. „min“
                    .font(.footnote)
                    .foregroundStyle(AppColors.Semantic.textSecondary)
            }
            .padding(.horizontal, AppSpace._12)
            .padding(.vertical, AppSpace._8)
            .background(
                Capsule(style: .circular)
                    .fill(AppColors.Semantic.bgElevated)
            )
            .overlay(
                Capsule()
                    .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.5)
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                Text("session.a11y.minutes \(minutes)")
            )
        }
        .padding(.vertical, AppSpace._8)
        .accessibilityIdentifier("bookdetail.session.row")
    }

    // MARK: - Helpers

    /// Liefert z. B. „vor 2 Tagen“ / „in 3 Stunden“ basierend auf `date`.
    private func relativeString(for date: Date) -> String {
        RelativeDateTimeFormatter.cached.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Formatter Cache

private extension RelativeDateTimeFormatter {
    static let cached: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .short  // „2 Tg.“ / „3 Std.“ – gern auf .full ändern
        f.locale = .current
        return f
    }()
}


