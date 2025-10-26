//
//  InsightsView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 20.10.25.
//

import SwiftUI
import SwiftData
import Charts

@MainActor
struct InsightsView: View {
    @StateObject private var vm: ProfileViewModel

    init(context: ModelContext) {
        _vm = StateObject(
            wrappedValue: ProfileViewModel(context: context)
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpace.lg) {
                Text(LocalizedStringKey(vm.titleKey))
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("insights.title")
                    .padding(.bottom, 2)

                modePicker
                    .padding(.top, 2)
                    .accessibilityIdentifier("insights.modePicker")

                sectionDailyChart()

                sectionWeekdayMinutes()
            }
            .padding(.horizontal, AppSpace.lg)
            .padding(.top, AppSpace.lg)
            .accessibilityIdentifier("Insights.Screen")
        }
        .accessibilityIdentifier("Insights.Screen.Scroll")
        .navigationTitle(Text(LocalizedStringKey(vm.titleKey)))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            vm.reload()
        }
    }

    private var modePicker: some View {
        Picker("", selection: $vm.mode) {
            ForEach(ProfileViewModel.InsightsMode.allCases) { m in
                Text(LocalizedStringKey(m.i18nKey)).tag(m)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: vm.mode) { _, _ in
            withAnimation(.interpolatingSpring(stiffness: 180, damping: 22)) {}
        }
    }

    private func sectionDailyChart() -> some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            Chart(vm.dailyStats, id: \.date) { day in
                let v = vm.value(for: day)
                BarMark(
                    x: .value("Date", day.date, unit: .day),
                    y: .value("Minutes", v)
                )
                .foregroundStyle(AppColors.brandPrimary)
                .cornerRadius(3)
                .annotation(position: .top) {
                    if v > 0 {
                        Text("\(v)")
                            .font(.caption2.monospacedDigit())
                            .foregroundColor(AppColors.textSecondary)
                            .accessibilityHidden(true)
                    }
                }
                .accessibilityLabel(Text(dateA11y(day.date)))
                .accessibilityValue(Text("\(v)"))
                .accessibilityIdentifier("insights.chart.bar.\(isoDay(day.date))")
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 5)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartYScale(domain: yDomain)
            .animation(.spring(response: 0.45, dampingFraction: 0.85), value: vm.dailyStats)
            .animation(.interpolatingSpring(stiffness: 180, damping: 22), value: vm.mode)
            .frame(height: 260)
            .accessibilityIdentifier("insights.chart")
            .overlay(alignment: .topLeading) {
                if vm.averageMinutes > 0 {
                    Chart {
                        RuleMark(y: .value("Average", vm.averageMinutes))
                            .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [6,6]))
                            .foregroundStyle(.secondary)
                            .annotation(position: .topLeading) {
                                Text(String(format: NSLocalizedString("insights.average.label", comment: "avg label"), Int(vm.averageMinutes.rounded())))
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.ultraThinMaterial, in: Capsule())
                                    .accessibilityIdentifier("insights.chart.average.label")
                            }
                    }
                    .allowsHitTesting(false)
                    .transition(.opacity)
                }
            }
        }
        .padding()
        .background(AppColors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.l)
                .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75)
        )
        #if DEBUG
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        #endif
    }

    // MARK: - Helpers (local)
    private func isoDay(_ d: Date) -> String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate]
        return f.string(from: d)
    }

    private func dateA11y(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .full
        return f.string(from: d)
    }

    // Dynamic Y domain with headroom for labels (min 60)
    private var yDomain: ClosedRange<Double> {
        let values = vm.dailyStats.map { Double(vm.value(for: $0)) }
        let maxV = values.max() ?? 0
        let headroom = max(60.0, maxV * 1.25)
        return 0...headroom
    }

    private func sectionWeekdayMinutes() -> some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            Text(String(localized: "insights.section.weekday"))
                .font(.headline)
                .accessibilityIdentifier("insights.section.weekday.title")
            Text(String(localized: "insights.section.weekday.subtitle"))
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .accessibilityIdentifier("insights.section.weekday.subtitle")

            // Statt Chart: einfache Liste (Phase: Erstellung, kein Polish)
            VStack(spacing: 8) {
                // Recompute local so we don't expose service here; ProfileVM hält Logik
                // In Iteration 2 ziehen wir echte Charts aus vm (Datenstruktur erweitern).
                ForEach(0..<7, id: \.self) { i in
                    HStack {
                        Text(vm.weekdayLabel(for: i))
                            .accessibilityIdentifier("insights.weekday.label.\(i)")
                        Spacer()
                        let value = (i == vm.bestWeekdayIndex) ? vm.bestWeekdayMinutes : 0
                        Text("\(value)")
                            .monospacedDigit()
                            .foregroundColor(i == vm.bestWeekdayIndex ? AppColors.brandPrimary : AppColors.textPrimary)
                            .accessibilityIdentifier("insights.weekday.value.\(i)")
                    }
                    .padding(.vertical, 6)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(Text(vm.weekdayLabel(for: i)))
                    .accessibilityValue(Text("\( (i == vm.bestWeekdayIndex) ? vm.bestWeekdayMinutes : 0 )"))
                    .accessibilityIdentifier("insights.weekday.row.\(i)")
                }
                Text(String(localized: "insights.section.weekday.note"))
                    .font(.caption2)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.top, 4)
                    .accessibilityHidden(true)
                    .accessibilityIdentifier("insights.weekday.note")
            }
            .padding()
            .background(AppColors.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.l)
                    .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75)
            )
        }
        .accessibilityIdentifier("Insights.WeekdayMinutes")
    }
}

#if DEBUG
import Charts

// MARK: - Case-Study Preview Harness (deterministisch)
private struct PreviewDailyStat: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let readingMinutes: Int
    let listeningMinutes: Int
}

private enum PreviewInsightsMode: String, CaseIterable, Identifiable {
    case reading, listening, combined
    var id: String { rawValue }
    var titleKey: LocalizedStringKey {
        switch self {
        case .reading:   return "insights.segment.reading"
        case .listening: return "insights.segment.listening"
        case .combined:  return "insights.segment.combined"
        }
    }
}

private struct PreviewStatsGenerator {
    func last30Days() -> [PreviewDailyStat] {
        let cal = Calendar(identifier: .gregorian)
        let start = cal.startOfDay(for: Date())
        return (0..<30).reversed().map { offset in
            let day = cal.date(byAdding: .day, value: -offset, to: start)!
            let weekday = cal.component(.weekday, from: day) // 1=So ... 7=Sa
            let isWeekend = (weekday == 1 || weekday == 7)
            let baseRead   = isWeekend ? 36 : 22
            let baseListen = isWeekend ? 12 : 26
            let noise = (offset * 5 + weekday) % 8
            return PreviewDailyStat(
                date: day,
                readingMinutes: max(0, baseRead + noise - 2),
                listeningMinutes: max(0, baseListen + (7 - noise))
            )
        }
    }
}

@MainActor
private final class InsightsPreviewVM: ObservableObject {
    @Published var mode: PreviewInsightsMode = .combined
    @Published var stats: [PreviewDailyStat] = []
    var averageMinutes: Double {
        let vals = stats.map { value(for: $0) }
        guard !vals.isEmpty else { return 0 }
        return Double(vals.reduce(0, +)) / Double(vals.count)
    }
    init() { stats = PreviewStatsGenerator().last30Days() }
    func value(for day: PreviewDailyStat) -> Int {
        switch mode {
        case .reading:   return day.readingMinutes
        case .listening: return day.listeningMinutes
        case .combined:  return day.readingMinutes + day.listeningMinutes
        }
    }
}

// MARK: - Helpers (Preview-only, spiegeln A11y aus Produktion)
private func _isoDay(_ d: Date) -> String {
    let f = ISO8601DateFormatter(); f.formatOptions = [.withFullDate]; return f.string(from: d)
}
private func _dateA11y(_ d: Date) -> String {
    let f = DateFormatter(); f.dateStyle = .full; return f.string(from: d)
}

// MARK: - Harness View
private struct InsightsPreviewHarness: View {
    @StateObject private var vm = InsightsPreviewVM()

    private var yDomain: ClosedRange<Double> {
        let values = vm.stats.map { Double(vm.value(for: $0)) }
        let maxV = values.max() ?? 0
        let headroom = max(60.0, maxV * 1.25)
        return 0...headroom
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpace.lg) {
                Text("insights.title")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("insights.title")
                    .padding(.bottom, 2)

                Picker("", selection: $vm.mode) {
                    ForEach(PreviewInsightsMode.allCases) { m in
                        Text(m.titleKey).tag(m)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.top, 2)
                .accessibilityIdentifier("insights.modePicker")

                VStack(alignment: .leading, spacing: AppSpace.sm) {
                    Chart(vm.stats, id: \.id) { day in
                        let v = vm.value(for: day)
                        BarMark(
                            x: .value("Date", day.date, unit: .day),
                            y: .value("Minutes", v)
                        )
                        .foregroundStyle(AppColors.brandPrimary)
                        .cornerRadius(3)
                        .annotation(position: .top) {
                            if v > 0 {
                                Text("\(v)")
                                    .font(.caption2.monospacedDigit())
                                    .foregroundColor(AppColors.textSecondary)
                                    .accessibilityHidden(true)
                            }
                        }
                        .accessibilityLabel(Text(_dateA11y(day.date)))
                        .accessibilityValue(Text("\(v)"))
                        .accessibilityIdentifier("insights.chart.bar.\(_isoDay(day.date))")
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day, count: 5)) { _ in
                            AxisGridLine(); AxisTick(); AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                        }
                    }
                    .chartYAxis { AxisMarks(position: .leading) }
                    .chartYScale(domain: yDomain)
                    .frame(height: 260)
                    .accessibilityIdentifier("insights.chart")
                    .overlay(alignment: .topLeading) {
                        if vm.averageMinutes > 0 {
                            Chart {
                                RuleMark(y: .value("Average", vm.averageMinutes))
                                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [6,6]))
                                    .foregroundStyle(.secondary)
                                    .annotation(position: .topLeading) {
                                        Text(String(format: NSLocalizedString("insights.average.label", comment: "avg label"), Int(vm.averageMinutes.rounded())))
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(.ultraThinMaterial, in: Capsule())
                                            .accessibilityIdentifier("insights.chart.average.label")
                                    }
                            }
                            .allowsHitTesting(false)
                            .transition(.opacity)
                        }
                    }
                    .overlay(alignment: .topLeading) {
                        Chart {
                            RuleMark(x: .value("Heute", Calendar.current.startOfDay(for: Date())))
                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4,4]))
                                .foregroundStyle(.secondary)
                                .annotation(position: .top, alignment: .leading) {
                                    Text("Heute")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                        }
                        .allowsHitTesting(false)
                    }
                }
                .padding()
                .background(AppColors.surfacePrimary)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.l)
                        .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)

                // Weekday-Block als visueller Platzhalter (Case-Study)
                VStack(alignment: .leading, spacing: AppSpace.sm) {
                    Text(String(localized: "insights.section.weekday")).font(.headline)
                        .accessibilityIdentifier("insights.section.weekday.title")
                    Text(String(localized: "insights.section.weekday.subtitle")).font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                        .accessibilityIdentifier("insights.section.weekday.subtitle")
                    VStack(spacing: 8) {
                        ForEach(0..<7, id: \.self) { i in
                            HStack {
                                Text(weekdayLabel(for: i))
                                    .accessibilityIdentifier("insights.weekday.label.\(i)")
                                Spacer()
                                let val = i == 3 ? 48 : 0
                                Text("\(val)")
                                    .monospacedDigit()
                                    .foregroundColor(i == 3 ? AppColors.brandPrimary : AppColors.textPrimary)
                                    .accessibilityIdentifier("insights.weekday.value.\(i)")
                            }
                            .padding(.vertical, 6)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel(Text(weekdayLabel(for: i)))
                            .accessibilityValue(Text("\(i == 3 ? 48 : 0)"))
                            .accessibilityIdentifier("insights.weekday.row.\(i)")
                        }
                        Text(String(localized: "insights.section.weekday.note"))
                            .font(.caption2)
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.top, 4)
                            .accessibilityHidden(true)
                            .accessibilityIdentifier("insights.weekday.note")
                    }
                    .padding()
                    .background(AppColors.surfacePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.l)
                            .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75)
                    )
                }
                .accessibilityIdentifier("Insights.WeekdayMinutes")
            }
            .padding(.horizontal, AppSpace.lg)
            .padding(.top, AppSpace.lg)
            .accessibilityIdentifier("Insights.Screen")
        }
        .navigationTitle(Text("insights.title"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func weekdayLabel(for index: Int) -> String {
        var cal = Calendar.current
        cal.locale = Locale(identifier: "de_DE")
        let symbols = cal.weekdaySymbols // So..Sa
        let monFirst = [symbols[1], symbols[2], symbols[3], symbols[4], symbols[5], symbols[6], symbols[0]]
        return monFirst[index]
    }
}

// MARK: - Previews
struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack { InsightsPreviewHarness() }
                .environment(\.locale, .init(identifier: "de"))
                .preferredColorScheme(.light)
                .previewDisplayName("Insights – Light (DE)")

            NavigationStack { InsightsPreviewHarness() }
                .environment(\.locale, .init(identifier: "de"))
                .preferredColorScheme(.dark)
                .previewDisplayName("Insights – Dark (DE)")
        }
    }
}
#endif
