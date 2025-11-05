//
//  ReadingGoalsView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 20.10.25.
//
import SwiftUI
import SwiftData
#if os(iOS)
import UIKit
#endif

@MainActor
struct ReadingGoalsView: View {
    @StateObject private var viewModel: ReadingGoalsViewModel
    @Environment(\.modelContext) private var context
    @State private var hasReachedGoal: Bool = false
    @State private var celebrate: Bool = false
    // Init mit explizitem Context (aus Environment vom Aufrufer übergeben)
    // Wir übergeben StatsService optional und fallen intern auf .shared zurück,
    // um Swift 6 (@MainActor isolation) zufrieden zu stellen.
    init(context: ModelContext, statsService: StatsService? = nil) {
        let service = statsService ?? StatsService.shared
        _viewModel = StateObject(
            wrappedValue: ReadingGoalsViewModel(
                context: context,
                statsService: service
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpace.lg) {

                NavigationLink {
                    FocusModeView(
                        sessionRepository: LocalSessionRepository(context: context),
                        initialBook: nil
                    )
                } label: {
                    Label(LocalizedStringKey("focus.title"), systemImage: "timer")
                        .font(AppFont.bodyStandard())
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .cardBackground()
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.l)
                                .stroke(AppColors.Semantic.chipBg.opacity(0.6), lineWidth: AppStroke.cardBorder)
                        )
                        .accessibilityIdentifier("Goals.FocusLink.Label")
                }
                .accessibilityIdentifier("Goals.FocusLink")

                // MARK: Progress Ring
                ZStack {
                    Circle()
                        .stroke(AppColors.Semantic.chartAxis.opacity(0.25), lineWidth: 16)
                    Circle()
                        .trim(from: 0, to: CGFloat(min(max(viewModel.progress, 0), 1)))
                        .stroke(AppColors.Semantic.tintPrimary, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.progress)

                    VStack(spacing: 4) {
                        Text(progressPercent(viewModel.progress))
                            .font(AppFont.titleLarge)
                            .foregroundStyle(AppColors.Semantic.textPrimary)
                            .accessibilityIdentifier("Goals.ProgressPercent")

                        if let goal = viewModel.activeGoal {
                            Text(String(format: NSLocalizedString("goals.target.minutes", comment: "Ziel-Minuten"), goal.targetMinutes))
                                .font(AppFont.caption2())
                                .foregroundStyle(AppColors.Semantic.textSecondary)
                                .accessibilityIdentifier("Goals.TargetLabel")
                        } else {
                            Text(NSLocalizedString("goals.cta.set", comment: "Ziel festlegen"))
                                .font(AppFont.caption2())
                                .foregroundStyle(AppColors.Semantic.textSecondary)
                                .accessibilityIdentifier("Goals.NoGoalLabel")
                        }
                    }
                    if celebrate {
                        Text(LocalizedStringKey("goals.celebration.reached"))
                            .font(AppFont.caption2(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                            .overlay(
                                Capsule().stroke(
                                    AppColors.Semantic.chipBg.opacity(0.6),
                                    lineWidth: AppStroke.cardBorder
                                )
                            )
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .topTrailing)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .accessibilityIdentifier("Goals.CelebrationBadge")
                    }
                }
                .frame(width: 220, height: 220)
                .padding(.top, AppSpace.xl)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(NSLocalizedString("goals.accessibility.progress", comment: "Fortschritt"))
                .accessibilityValue(progressPercent(viewModel.progress))
                .accessibilityIdentifier("Goals.ProgressRing")
                #if DEBUG
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
                #else
                .shadow(color: AppColors.Semantic.shadowColor, radius: 6, x: 0, y: 3)
                #endif

                // MARK: Streak
                HStack(spacing: AppSpace.sm) {
                    Label {
                        Text("\(viewModel.streakCount)")
                            .font(AppFont.headingS())
                        Text(NSLocalizedString("goals.streak.days", comment: "Tage in Folge"))
                            .font(AppFont.bodyStandard())
                            .foregroundStyle(AppColors.Semantic.textSecondary)
                    } icon: {
                        Image(systemName: "flame.fill")
                    }
                    .accessibilityIdentifier("Goals.StreakBadge")

                    Spacer()

                    // CTA
                    Button {
                        viewModel.startEditing()
                    } label: {
                        Text(NSLocalizedString("goals.edit.title", comment: "Ziel bearbeiten"))
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("Goals.Edit.Open")
                }
                .padding(.horizontal, AppSpace.lg)

                // Optional: kleine Metrik-Karte
                metricTile(minutes: viewModel.totalMinutes)
                    .padding(.horizontal, AppSpace.lg)

                Spacer(minLength: AppSpace.xl)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, AppSpace.xl)
            .accessibilityIdentifier("Goals.Screen")
        }
        .background(AppColors.Semantic.bgScreen)
        .navigationTitle(Text(NSLocalizedString("goals.title", comment: "Lesziele")))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.calculateProgress()
        }
        .onChange(of: viewModel.progress) { oldValue, newValue in
            let wasBelow = oldValue < 1.0
            let isNowFull = newValue >= 1.0
            if wasBelow && isNowFull && !hasReachedGoal {
                hasReachedGoal = true
                #if os(iOS)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                #endif
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    celebrate = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    withAnimation(.easeOut(duration: 0.3)) { celebrate = false }
                }
            }
        }
        .sheet(isPresented: $viewModel.isEditing) {
            EditGoalSheet(vm: viewModel)
            #if os(iOS)
            .presentationDetents([.medium])
            #endif
        }
    }

    // MARK: - Helpers
    private func progressPercent(_ p: Double) -> String {
        let clamped = max(0, min(1, p))
        return NumberFormatter.localizedString(from: NSNumber(value: clamped * 100), number: .percent)
    }


    @ViewBuilder
    private func metricTile(minutes: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(NSLocalizedString("goals.metric.readThisPeriod", comment: "Gelesen in dieser Periode"))
                .font(AppFont.bodyStandard())
                .foregroundStyle(AppColors.Semantic.textSecondary)
            Text("\(minutes) " + NSLocalizedString("goals.metric.minutes", comment: "Minuten"))
                .font(AppFont.headingM())
                .foregroundStyle(AppColors.Semantic.textPrimary)
        }
        .padding(AppSpace.lg)
        .background(AppColors.Semantic.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous))
        .shadow(color: AppColors.Semantic.shadowColor, radius: 3, x: 0, y: 1)
        .accessibilityIdentifier("Goals.MetricTile")
    }
}

// MARK: - DEBUG Case-Study Harness
#if DEBUG
// MARK: - Case-Study Harness (Preview-only, ohne Produktions-VM/SwiftData)
private struct GoalsPreviewVM {
    var progress: Double
    var targetMinutes: Int?
    var streakCount: Int
    var totalMinutes: Int
}

private struct ReadingGoalsCaseStudy: View {
    @State private var vm: GoalsPreviewVM
    @State private var celebrate: Bool = false

    init(vm: GoalsPreviewVM) { _vm = State(initialValue: vm) }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpace.lg) {
                // Focus-Link (statisch)
                Label(LocalizedStringKey("focus.title"), systemImage: "timer")
                    .font(AppFont.bodyStandard())
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.Semantic.bgCard)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.l)
                            .stroke(AppColors.Semantic.chipBg.opacity(0.6), lineWidth: AppStroke.cardBorder)
                    )
                    .accessibilityIdentifier("Goals.FocusLink.Label")
                    .accessibilityElement(children: .combine)

                // Progress Ring
                ZStack {
                    Circle()
                        .stroke(AppColors.Semantic.chartAxis.opacity(0.25), lineWidth: 16)
                    Circle()
                        .trim(from: 0, to: CGFloat(min(max(vm.progress, 0), 1)))
                        .stroke(AppColors.Semantic.tintPrimary, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: vm.progress)

                    VStack(spacing: 4) {
                        Text(previewProgressPercent(vm.progress))
                            .font(AppFont.titleLarge)
                            .foregroundStyle(AppColors.Semantic.textPrimary)
                            .accessibilityIdentifier("Goals.ProgressPercent")

                        if let target = vm.targetMinutes {
                            Text(String(format: NSLocalizedString("goals.target.minutes", comment: "Ziel-Minuten"), target))
                                .font(AppFont.caption2())
                                .foregroundStyle(AppColors.Semantic.textSecondary)
                                .accessibilityIdentifier("Goals.TargetLabel")
                        } else {
                            Text(NSLocalizedString("goals.cta.set", comment: "Ziel festlegen"))
                                .font(AppFont.caption2())
                                .foregroundStyle(AppColors.Semantic.textSecondary)
                                .accessibilityIdentifier("Goals.NoGoalLabel")
                        }
                    }

                    if vm.progress >= 1.0 && celebrate {
                        Text(LocalizedStringKey("goals.celebration.reached"))
                            .font(AppFont.caption2(.semibold))
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                            .overlay(
                                Capsule().stroke(
                                    AppColors.Semantic.chipBg.opacity(0.6),
                                    lineWidth: AppStroke.cardBorder
                                )
                            )
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .topTrailing)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .accessibilityIdentifier("Goals.CelebrationBadge")
                    }
                }
                .frame(width: 220, height: 220)
                .padding(.top, AppSpace.xl)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(NSLocalizedString("goals.accessibility.progress", comment: "Fortschritt"))
                .accessibilityValue(previewProgressPercent(vm.progress))
                .accessibilityIdentifier("Goals.ProgressRing")
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
                .onAppear {
                    if vm.progress >= 1 {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { celebrate = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                            withAnimation(.easeOut(duration: 0.3)) { celebrate = false }
                        }
                    }
                }

                // Streak + Edit-CTA (statisch)
                HStack(spacing: AppSpace.sm) {
                    Label {
                        Text("\(vm.streakCount)").font(AppFont.headingS())
                        Text(NSLocalizedString("goals.streak.days", comment: "Tage in Folge"))
                            .font(AppFont.bodyStandard())
                            .foregroundStyle(AppColors.Semantic.textSecondary)
                    } icon: { Image(systemName: "flame.fill") }
                    .accessibilityIdentifier("Goals.StreakBadge")

                    Spacer()

                    Button(action: {}, label: { Text(NSLocalizedString("goals.edit.title", comment: "Ziel bearbeiten")) })
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("Goals.Edit.Open")
                }
                .padding(.horizontal, AppSpace.lg)

                // Metric Tile (statisch)
                VStack(alignment: .leading, spacing: 6) {
                    Text(NSLocalizedString("goals.metric.readThisPeriod", comment: "Gelesen in dieser Periode"))
                        .font(AppFont.bodyStandard())
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                    Text("\(vm.totalMinutes) " + NSLocalizedString("goals.metric.minutes", comment: "Minuten"))
                        .font(AppFont.headingM())
                        .foregroundStyle(AppColors.Semantic.textPrimary)
                }
                .padding(AppSpace.lg)
                .background(AppColors.Semantic.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous))
                .shadow(color: AppColors.Semantic.shadowColor, radius: 3, x: 0, y: 1)
                .accessibilityIdentifier("Goals.MetricTile")

                Spacer(minLength: AppSpace.xl)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, AppSpace.xl)
            .accessibilityIdentifier("Goals.Screen")
        }
        .background(AppColors.Semantic.bgScreen)
        .navigationTitle(Text(NSLocalizedString("goals.title", comment: "Lesziele")))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func previewProgressPercent(_ p: Double) -> String {
        let clamped = max(0, min(1, p))
        return NumberFormatter.localizedString(from: NSNumber(value: clamped * 100), number: .percent)
    }
}

// MARK: - ReadingGoalsView Previews (Case Study – DE, Light/Dark)
#Preview("Goals – Case Study 95% (Light, DE)") {
    NavigationStack {
        ReadingGoalsCaseStudy(vm: .init(progress: 0.95, targetMinutes: 200, streakCount: 7, totalMinutes: 190))
            .environment(\.locale, .init(identifier: "de"))
            .preferredColorScheme(.light)
    }
}

#Preview("Goals – Case Study 105% (Dark, DE)") {
    NavigationStack {
        ReadingGoalsCaseStudy(vm: .init(progress: 1.05, targetMinutes: 200, streakCount: 12, totalMinutes: 210))
            .environment(\.locale, .init(identifier: "de"))
            .preferredColorScheme(.dark)
    }
}
#endif
