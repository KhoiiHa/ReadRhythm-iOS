import SwiftUI
import SwiftData
import Charts

/// Kontext → Warum → Wie
/// Kontext: Die StatsView zeigt aggregierte Leseminuten pro Tag (Timeline) und die Gesamtminuten.
/// Warum: Visuelles Feedback zum Leseverhalten ist ein MVP-Kernnutzen und Portfolio-Highlight.
/// Wie: Daten kommen aus dem StatsViewModel (das den StatsService nutzt); die View rendert eine einfache Bar-Chart.
struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = StatsViewModel()
    @State private var hoverDate: Date? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Titel
            Text("rr.stats.title")
                .font(.title2).bold()
                .foregroundStyle(AppColors.Semantic.textPrimary)

            // Zeitraum (Segmented Picker): 7 / 14 / 30 Tage
            Picker("", selection: $viewModel.days) {
                Text("7d").tag(7)
                Text("14d").tag(14)
                Text("30d").tag(30)
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("rr-stats-range")
            .onChange(of: viewModel.days) { _, _ in
                viewModel.reload(context: modelContext)
            }

            // Gesamtminuten (kompakt)
            Text("\(viewModel.totalMinutes) \(String(localized: "rr.stats.minutes.total"))")
                .accessibilityIdentifier("rr-stats-totalMinutes")

            // Aktuelle Lese-Streak anzeigen (Tage in Folge)
            if viewModel.currentStreak > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                    Text("\(viewModel.currentStreak) \(String(localized: "rr.stats.streak.days"))")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("rr-stats-streak")
            }

            // Timeline-Chart (letzte viewModel.days Tage) + Achsenformat + Tooltip
            if viewModel.daily.allSatisfy({ $0.minutes == 0 }) {
                VStack(spacing: 8) {
                    Text("rr.stats.empty")
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("rr-stats-empty")
                }
                .frame(height: 220)
            } else {
                Chart(viewModel.daily, id: \.date) { item in
                    BarMark(
                        x: .value(String(localized: "rr.stats.day"), item.date, unit: .day),
                        y: .value(String(localized: "rr.stats.minutes"), item.minutes)
                    )
                    .foregroundStyle(AppColors.Semantic.chartBar)
                    .annotation(position: .top, alignment: .center) {
                        if item.minutes > 0 {
                            Text("\(item.minutes)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) {
                        AxisGridLine().foregroundStyle(AppColors.Semantic.chartAxis)
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    }
                }
                .frame(height: 220)
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        Rectangle()
                            .fill(.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        guard let frame = proxy.plotFrame else { return }
                                        let origin = geo[frame].origin
                                        let xPos = value.location.x - origin.x
                                        if let date: Date = proxy.value(atX: xPos) {
                                            let day = Calendar.current.startOfDay(for: date)
                                            if let match = viewModel.daily.first(where: { Calendar.current.startOfDay(for: $0.date) == day }) {
                                                hoverDate = match.date
                                            }
                                        }
                                    }
                                    .onEnded { _ in
                                        hoverDate = nil
                                    }
                            )
                    }
                }
                .accessibilityIdentifier("rr-stats-chart-timeline")

                // Tooltip-Zeile unter dem Chart
                if let d = hoverDate,
                   let item = viewModel.daily.first(where: { Calendar.current.startOfDay(for: $0.date) == Calendar.current.startOfDay(for: d) }) {
                    Text("\(item.minutes) \(String(localized: "rr.stats.minutes")) • \(d.formatted(.dateTime.day().month().year()))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("rr-stats-tooltip")
                }
            }

            #if DEBUG
            // Seed-Knopf für schnelle visuelle Prüfung
            Button(String(localized: "rr.stats.debug.add10")) {
                // Finde vorhandenes Buch oder erzeuge ein Debug-Buch
                let fetch = FetchDescriptor<BookEntity>()
                let existing = (try? modelContext.fetch(fetch))?.first
                let book = existing ?? {
                    let b = BookEntity(title: "Debug Book", author: "")
                    modelContext.insert(b)
                    return b
                }()

                // Neue Session (10 Minuten) anlegen
                let s = ReadingSessionEntity(date: .now, minutes: 10, book: book)
                modelContext.insert(s)
                try? modelContext.save()

                // Daten neu laden
                viewModel.reload(context: modelContext)
            }
            .buttonStyle(SecondaryButtonStyle())
            .accessibilityIdentifier("rr-stats-debug-add10")
            #endif
        }
        .padding()
        .onAppear {
            viewModel.reload(context: modelContext)
        }
        .accessibilityIdentifier("stats.view")
        .background(AppColors.Semantic.bgPrimary)
        .tint(AppColors.Semantic.tintPrimary)
    }
}
