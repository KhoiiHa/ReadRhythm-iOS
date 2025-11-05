//
//  StatsChart.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 19.10.25.
//

import SwiftUI
import Charts

/// Kontext → Warum → Wie
/// Kontext: Zeigt die tägliche Lese-/Hörzeit als Balkendiagramm.
/// Warum: Nutzer*innen sollen Fortschritt (Minuten pro Tag) und ein persönliches Ziel (goalMinutes) visuell verstehen.
/// Wie: BarMark + RuleMark. Farben, Spacing, CornerRadius und Linienbreiten kommen aus dem Designsystem
///      (AppColors, AppChart, AppStroke), keine Magic Numbers im View-Code.
struct StatsChart: View {
    struct DataPoint: Identifiable, Equatable, Hashable {
        var id: Date { date }
        let date: Date
        let minutes: Int
    }

    let data: [DataPoint]
    /// Optionales Tagesziel in Minuten (Portfolio-Polish). Standard: 30.
    var goalMinutes: Int = 30

    var body: some View {
        Chart {
            // Balken
            ForEach(data) { point in
                BarMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Minutes", point.minutes)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            AppColors.Semantic.chartBar.opacity(0.95),
                            AppColors.Semantic.chartBar.opacity(0.7)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(AppChart.barCornerRadius)
                .annotation(position: .top, alignment: .center) {
                    if point.minutes > 0 {
                        Text("\(point.minutes)")
                            .font(AppFont.caption2())
                            .foregroundStyle(AppColors.Semantic.textSecondary)
                    }
                }
            }

            // Ziel-Linie
            RuleMark(y: .value("Goal", goalMinutes))
                .lineStyle(StrokeStyle(lineWidth: AppStroke.chartGoal, dash: [4]))
                .foregroundStyle(AppColors.Semantic.tintPrimary.opacity(0.85))
                .annotation(position: .topLeading, alignment: .leading) {
                    Text("\(goalMinutes)")
                        .font(AppFont.caption2())
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                        .padding(.horizontal, AppSpace.xs)
                }
        }
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisGridLine()
                    .foregroundStyle(AppColors.Semantic.chartAxis.opacity(0.35))
                AxisTick()
                    .foregroundStyle(AppColors.Semantic.chartAxis)
                AxisValueLabel()
                    .foregroundStyle(AppColors.Semantic.textSecondary)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) {
                AxisGridLine()
                    .foregroundStyle(AppColors.Semantic.chartAxis.opacity(0.2))
                AxisTick()
                    .foregroundStyle(AppColors.Semantic.chartAxis)
                AxisValueLabel(format: .dateTime.day().weekday(.narrow))
                    .foregroundStyle(AppColors.Semantic.textSecondary)
            }
        }
        .chartYScale(domain: 0...maxY)
        .chartPlotStyle { plot in
            plot
                .background(AppColors.Semantic.bgScreen)
                .accessibilityHidden(true) // Deko-Hintergrund ist visuell, nicht in VoiceOver relevant
        }
        .frame(height: AppChart.height)
        .padding(.horizontal, AppChart.horizontalPadding)
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier("stats.chart")
    }

    private var maxY: Int {
        max(max(data.map { $0.minutes }.max() ?? 30, goalMinutes), 30)
    }
}
