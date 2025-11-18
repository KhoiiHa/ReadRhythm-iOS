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

    // Subtitle key based on selected range
    private var rangeSubtitleKey: LocalizedStringKey {
        switch selectedRange {
        case .week:
            return "rr.stats.range.week.subtitle"
        case .month:
            return "rr.stats.range.month.subtitle"
        case .year:
            return "rr.stats.range.year.subtitle"
        case .all:
            return "rr.stats.range.all.subtitle"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpace._16) {
            VStack(alignment: .leading, spacing: AppSpace._4) {
                Text("rr.stats.title")
                    .font(AppFont.headingM())
                    .foregroundStyle(AppColors.Semantic.textPrimary)
                    .accessibilityIdentifier("stats.header.title")

                Text(rangeSubtitleKey)
                    .font(AppFont.caption1())
                    .foregroundStyle(AppColors.Semantic.textSecondary)
                    .accessibilityIdentifier("stats.header.subtitle")
            }

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
                    labelKey: "rr.stats.minutes.total",
                    systemImage: "clock"
                )
                summaryTile(
                    value: "\(streakDays)",
                    labelKey: "rr.stats.streak.days",
                    systemImage: "flame"
                )
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, AppSpace._16)
        .padding(.vertical, AppSpace._16)
        .accessibilityIdentifier("stats.header")
    }

    // MARK: - Subviews
    private func summaryTile(
        value: String,
        labelKey: LocalizedStringKey,
        systemImage: String
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpace._4) {
            Image(systemName: systemImage)
                .font(.caption)
                .foregroundStyle(AppColors.Semantic.tintPrimary.opacity(0.8))

            Text(value)
                .font(AppFont.headingS())
                .foregroundStyle(AppColors.Semantic.textPrimary)

            Text(labelKey)
                .font(AppFont.caption2())
                .foregroundStyle(AppColors.Semantic.textSecondary)
        }
        .padding(AppSpace._12)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.m, style: .continuous)
                .fill(AppColors.Semantic.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.m, style: .continuous)
                        .stroke(
                            AppColors.Semantic.chipBg.opacity(0.6),
                            lineWidth: 1
                        )
                )
        )
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
