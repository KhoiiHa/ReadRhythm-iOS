//
//  StatsEmptyState.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 19.10.25.
//

import SwiftUI

/// Zeigt einen freundlichen leeren Zustand, wenn keine Statistikdaten vorliegen.
/// Warum → Wie
/// - Warum: Verhindert leeren Bildschirm und führt Nutzer motivierend zurück zur App-Hauptaktion.
/// - Wie: Hierarchisches SF-Symbol, i18n-Texte, Theme-Farben; kann später durch Illustration ersetzt werden.
struct StatsEmptyState: View {
    var body: some View {
        VStack(spacing: AppSpace._12) {
            Image(systemName: "chart.bar.doc.horizontal")
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 48))
                .foregroundStyle(AppColors.Semantic.textSecondary)
                .accessibilityHidden(true)

            Text("rr.stats.empty.title")
                .font(.headline)
                .foregroundStyle(AppColors.Semantic.textPrimary)
                .accessibilityIdentifier("stats.empty.title")

            Text("rr.stats.empty.subtitle")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColors.Semantic.textSecondary)
                .padding(.horizontal, AppSpace._16)
                .accessibilityIdentifier("stats.empty.subtitle")
        }
        .padding(.vertical, AppSpace._24)
        .frame(maxWidth: .infinity)
        .background(AppColors.Semantic.bgPrimary)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("stats.emptyState")
    }
}

