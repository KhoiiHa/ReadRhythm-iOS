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
    @StateObject private var viewModel: StatsViewModel

    /// UI-Range steuert die Auswahl im Header (wird auf ViewModel.days gemappt).
    @State private var range: StatsRange = .week

    init(context: ModelContext) {
        // Repository kapselt SwiftData-Zugriff und wird durchgereicht
        let repo = LocalSessionRepository(context: context)

        self._viewModel = StateObject(
            wrappedValue: StatsViewModel(
                sessionRepository: repo,
                statsService: .shared
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpace.lg) {
                statsCard

#if DEBUG
                // Seed-Knopf für schnelle visuelle Prüfung
                Button(String(localized: "rr.stats.debug.seed")) {
                    viewModel.seedDebugMinutes()
                }
                .accessibilityIdentifier("rr-stats-debug-seed")
                .buttonStyle(.bordered)
                .tint(AppColors.Semantic.tintPrimary)
                .padding(.top, AppSpace.sm)
#endif
            }
            .padding(.horizontal, AppSpace.lg)
            .padding(.vertical, AppSpace.lg)
        }
        .background(AppColors.Semantic.bgScreen)
        .tint(AppColors.Semantic.tintPrimary)
        .task {
            // Initiales Mapping von UI-Range → ViewModel.days
            apply(range: range)
            viewModel.refreshFromRepositoryContext()
        }
        .navigationTitle(Text("rr.stats.title"))
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("stats.view")
    }

    // MARK: - Card Content
    private var statsCard: some View {
        VStack(alignment: .leading, spacing: AppSpace.lg) {
            headerSection

            if viewModel.daily.allSatisfy({ $0.minutes == 0 }) || viewModel.daily.isEmpty {
                StatsEmptyState()
                    .padding(.top, AppSpace.md)
            } else {
                StatsChart(data: chartData, goalMinutes: 30)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(chartAccessibilitySummary)
                    .animation(.easeInOut(duration: 0.2), value: chartData)
            }
        }
        .padding(AppSpace.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.Semantic.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .shadow(
            color: AppShadow.card.color,
            radius: AppShadow.card.radius,
            x: AppShadow.card.x,
            y: AppShadow.card.y
        )
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpace.md) {
            Text("rr.stats.title")
                .font(AppFont.headingM())
                .foregroundStyle(AppColors.Semantic.textPrimary)
                .accessibilityIdentifier("stats.header.title")

            Picker("", selection: $range) {
                ForEach(StatsRange.allCases) { range in
                    Text(range.titleKey)
                        .tag(range)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: range) { _, newValue in
                withAnimation(.easeInOut(duration: 0.2)) {
                    apply(range: newValue)
                    viewModel.refreshFromRepositoryContext()
                }
            }
            .accessibilityIdentifier("stats.header.rangePicker")

            HStack(spacing: AppSpace.md) {
                summaryTile(
                    value: "\(viewModel.totalMinutes)",
                    labelKey: "rr.stats.minutes.total"
                )

                summaryTile(
                    value: "\(viewModel.currentStreak)",
                    labelKey: "rr.stats.streak.days"
                )

                Spacer(minLength: 0)
            }
        }
        .accessibilityIdentifier("stats.header")
    }

    private func summaryTile(value: String, labelKey: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: AppSpace.xs) {
            Text(value)
                .font(AppFont.headingM())
                .foregroundStyle(AppColors.Semantic.textPrimary)
            Text(labelKey)
                .font(AppFont.caption2())
                .foregroundStyle(AppColors.Semantic.textSecondary)
        }
        .padding(AppSpace.md)
        .background(AppColors.Semantic.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.m, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.m)
                .stroke(AppColors.Semantic.chipBg.opacity(0.6), lineWidth: AppStroke.cardBorder)
        )
        .accessibilityElement(children: .combine)
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
