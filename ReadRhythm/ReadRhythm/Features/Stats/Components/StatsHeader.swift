//
//  StatsHeader.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 19.10.25.
//

import SwiftUI

/// Kopfbereich für den Stats-Screen: Titel, Range-Picker, kompakte Summary.
/// Warum → Wie
/// - Warum: Schnelles Wechseln zwischen Zeiträumen; zeigt wichtigste Kennzahlen sofort.
/// - Wie: Segmented Picker (Week/Month/Year/All) + zwei Tiles (Total Minutes, Streak Days).
struct StatsHeader: View {
    @Binding var selectedRange: StatsRange
    let totalMinutes: Int
    let streakDays: Int
    var onRangeChanged: (StatsRange) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpace._16) {
            Text("rr.stats.title")
                .font(.title2.weight(.semibold))
                .foregroundStyle(AppColors.Semantic.textPrimary)
                .accessibilityIdentifier("stats.header.title")

            // Range Picker
            Picker("", selection: $selectedRange) {
                ForEach(StatsRange.allCases) { range in
                    Text(range.titleKey)
                        .tag(range)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedRange) { _, newValue in
                onRangeChanged(newValue)
            }
            .accessibilityIdentifier("stats.header.rangePicker")

            // Summary tiles
            HStack(spacing: AppSpace._16) {
                summaryTile(
                    value: "\(totalMinutes)",
                    labelKey: "rr.stats.minutes.total"
                )
                summaryTile(
                    value: "\(streakDays)",
                    labelKey: "rr.stats.streak.days"
                )
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, AppSpace._16)
        .padding(.vertical, AppSpace._16)
        .accessibilityIdentifier("stats.header")
    }

    // MARK: - Subviews
    private func summaryTile(value: String, labelKey: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: AppSpace._4) {
            Text(value)
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppColors.Semantic.textPrimary)
            Text(labelKey)
                .font(.footnote)
                .foregroundStyle(AppColors.Semantic.textSecondary)
        }
        .padding(AppSpace._12)
        .cardBackground()
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Local Range Enum (kann später in Core/Enums umziehen)
enum StatsRange: String, CaseIterable, Identifiable {
    case week, month, year, all

    var id: String { rawValue }

    var titleKey: LocalizedStringKey {
        switch self {
        case .week: return "rr.stats.range.week"
        case .month: return "rr.stats.range.month"
        case .year: return "rr.stats.range.year"
        case .all: return "rr.stats.range.all"
        }
    }
}
