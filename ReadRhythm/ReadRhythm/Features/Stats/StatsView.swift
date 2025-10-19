import SwiftUI
import SwiftData
import Charts

/// Kontext → Warum → Wie
/// Kontext: Die StatsView zeigt aggregierte Leseminuten pro Tag (Timeline) und die Gesamtminuten.
/// Warum: Visuelles Feedback zum Leseverhalten ist ein MVP-Kernnutzen und Portfolio-Highlight.
/// Wie: Nutzt modulare Components (Header/Chart/Empty) + bestehendes ViewModel (days/total/daily).
struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = StatsViewModel()

    /// UI-Range steuert die Auswahl im Header (wird auf ViewModel.days gemappt).
    @State private var range: StatsRange = .week

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpace._16) {
                // Header mit Range-Picker und Summary
                StatsHeader(
                    selectedRange: $range,
                    totalMinutes: viewModel.totalMinutes,
                    streakDays: viewModel.currentStreak
                ) { newRange in
                    apply(range: newRange)
                    viewModel.reload(context: modelContext)
                }

                // Chart oder Empty State
                if viewModel.daily.allSatisfy({ $0.minutes == 0 }) || viewModel.daily.isEmpty {
                    StatsEmptyState()
                        .padding(.top, AppSpace._16)
                } else {
                    StatsChart(data: chartData, goalMinutes: 30)
                        .frame(height: 220)
                        .padding(.horizontal, AppSpace._16)
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
                .accessibilityIdentifier("rr-stats-debug-add10")
                .buttonStyle(.bordered)
                .tint(AppColors.Semantic.tintPrimary)
                .padding(.horizontal, AppSpace._16)
                #endif
            }
        }
        .background(AppColors.Semantic.bgPrimary)
        .tint(AppColors.Semantic.tintPrimary)
        .onAppear {
            // Initiales Mapping von UI-Range → ViewModel.days
            apply(range: range)
            viewModel.reload(context: modelContext)
        }
        .navigationTitle(Text("rr.stats.title"))
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("stats.view")
    }

    // MARK: - Helpers
    /// Mappt die UI-Range auf die bestehende days-Logik im ViewModel (7/14/30/∞)
    private func apply(range: StatsRange) {
        switch range {
        case .week:  viewModel.days = 7
        case .month: viewModel.days = 30
        case .year:  viewModel.days = 365
        case .all:   viewModel.days = Int.max // oder ein großer Wert, je nach Implementierung
        }
    }

    /// Konvertiert ViewModel-Daten in Chart-Datenpunkte der StatsChart-Komponente.
    private var chartData: [StatsChart.DataPoint] {
        viewModel.daily.map { .init(date: $0.date, minutes: $0.minutes) }
    }
}
