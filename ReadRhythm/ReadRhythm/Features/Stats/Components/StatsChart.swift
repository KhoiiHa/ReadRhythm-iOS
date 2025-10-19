//
//  StatsChart.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 19.10.25.
//

import SwiftUI
import Charts

/// Einfache Swift Charts Darstellung der Lesezeit über einen Zeitraum.
/// Warum → Wie
/// - Warum: Visualisiert Fortschritt über Zeit, klar und leicht lesbar.
/// - Wie: BarChart + dezente Ziel-Linie (RuleMark) und integer Y-Achse.
struct StatsChart: View {
    struct DataPoint: Identifiable {
        let id = UUID()
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
                .foregroundStyle(AppColors.Semantic.chartBar)
                .cornerRadius(AppRadius.s)
                .annotation(position: .top, alignment: .center) {
                    if point.minutes > 0 {
                        Text("\(point.minutes)")
                            .font(.caption2)
                            .foregroundStyle(AppColors.Semantic.textSecondary)
                    }
                }
            }

            // Ziel-Linie
            RuleMark(y: .value("Goal", goalMinutes))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                .foregroundStyle(AppColors.Semantic.borderMuted)
                .annotation(position: .topLeading, alignment: .leading) {
                    Text("\(goalMinutes)")
                        .font(.caption2)
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                        .padding(.horizontal, 2)
                }
        }
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) {
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.day().weekday(.narrow))
            }
        }
        .chartYScale(domain: 0...maxY)
        .chartPlotStyle { plot in
            plot.background(AppColors.Semantic.bgSecondary)
        }
        .padding(.horizontal, AppSpace._8)
        .accessibilityIdentifier("stats.chart")
    }

    private var maxY: Int {
        max(max(data.map { $0.minutes }.max() ?? 30, goalMinutes), 30)
    }
}

