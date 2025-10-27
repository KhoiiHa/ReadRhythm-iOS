import SwiftUI
import SwiftData
import Charts

// MARK: - Dependency Injection for StatsViewModel

/// Kontext → Warum → Wie
/// Kontext: Die StatsView zeigt aggregierte Leseminuten pro Tag (Timeline) und die Gesamtminuten.
/// Warum: Visuelles Feedback zum Leseverhalten ist ein MVP-Kernnutzen und Portfolio-Highlight.
/// Wie: Nutzt modulare Components (Header/Chart/Empty) + bestehendes ViewModel (days/total/daily).
@MainActor
struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: StatsViewModel
    
    /// UI-Range steuert die Auswahl im Header (wird auf ViewModel.days gemappt).
    @State private var range: StatsRange = .week
    // Repository wird hier gehalten, damit auch DEBUG-Seed über Repository läuft
    private let sessionRepository: LocalSessionRepository
    
    init(context: ModelContext) {
        // Repository kapselt SwiftData-Zugriff und wird durchgereicht
        let repo = LocalSessionRepository(context: context)
        self.sessionRepository = repo

        self._viewModel = StateObject(
            wrappedValue: StatsViewModel(
                sessionRepository: repo,
                statsService: .shared
            )
        )
    }
    
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
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(chartAccessibilitySummary)
                }
                
#if DEBUG
                // Seed-Knopf für schnelle visuelle Prüfung
                Button(String(localized: "rr.stats.debug.add10")) {
                    viewModel.debugAddTenMinutes(repository: sessionRepository)
                }
                .accessibilityIdentifier("rr-stats-debug-add10")
                .buttonStyle(.bordered)
                .tint(AppColors.Semantic.tintPrimary)
                .padding(.horizontal, AppSpace._16)
#endif
            }
            .background(AppColors.Semantic.bgPrimary)
            .tint(AppColors.Semantic.tintPrimary)
            .task {
                // Initiales Mapping von UI-Range → ViewModel.days
                apply(range: range)
                viewModel.reload(context: modelContext)
            }
            .navigationTitle(Text("rr.stats.title"))
            .navigationBarTitleDisplayMode(.inline)
            .accessibilityIdentifier("stats.view")
        }
    }
    
    // MARK: - Helpers
    
    /// Mappt die UI-Range auf die bestehende days-Logik im ViewModel (7/30/365/∞)
    private func apply(range: StatsRange) {
        switch range {
        case .week:
            viewModel.days = 7
        case .month:
            viewModel.days = 30
        case .year:
            viewModel.days = 365
        case .all:
            viewModel.days = Int.max // "alles"
        }
    }
    
    /// Konvertiert ViewModel-Daten in Chart-Datenpunkte der StatsChart-Komponente.
    private var chartData: [StatsChart.DataPoint] {
        viewModel.daily.map { .init(date: $0.date, minutes: $0.minutes) }
    }

    /// Liefert eine zusammenfassende Beschreibung für VoiceOver anstelle einzelner Balken.
    private var chartAccessibilitySummary: String {
        // Maximalwert finden
        if let maxEntry = viewModel.daily.max(by: { $0.minutes < $1.minutes }) {
            let minutes = maxEntry.minutes
            let dateText = AppFormatter.shortDateFormatter.string(from: maxEntry.date)
            return String(
                format: NSLocalizedString(
                    "stats.chart.accessibility",
                    comment: "VoiceOver summary for stats chart: maximum minutes and reference date"
                ),
                minutes,
                dateText
            )
        } else {
            return NSLocalizedString(
                "stats.chart.accessibility.empty",
                comment: "VoiceOver summary when there's no data in the stats chart"
            )
        }
    }
}
