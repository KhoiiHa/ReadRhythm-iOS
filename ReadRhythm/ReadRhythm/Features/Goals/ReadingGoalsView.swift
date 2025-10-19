//
//  ReadingGoalsView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 20.10.25.
//
import SwiftUI
import SwiftData

struct ReadingGoalsView: View {
    @StateObject private var viewModel: ReadingGoalsViewModel
    // Init mit explizitem Context (aus Environment vom Aufrufer übergeben)
    init(context: ModelContext, statsService: StatsService = .shared) {
        _viewModel = StateObject(wrappedValue: ReadingGoalsViewModel(context: context, statsService: statsService))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpace.lg) {

                // MARK: Progress Ring
                ZStack {
                    Circle()
                        .stroke(AppColors.surfaceSecondary, lineWidth: 16)
                    Circle()
                        .trim(from: 0, to: CGFloat(min(max(viewModel.progress, 0), 1)))
                        .stroke(AppColors.brandPrimary, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.6), value: viewModel.progress)

                    VStack(spacing: 4) {
                        Text(progressPercent(viewModel.progress))
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                            .accessibilityIdentifier("Goals.ProgressPercent")

                        if let goal = viewModel.activeGoal {
                            Text(String(format: NSLocalizedString("goals.target.minutes", comment: "Ziel-Minuten"), goal.targetMinutes))
                                .font(.callout)
                                .foregroundColor(AppColors.textSecondary)
                                .accessibilityIdentifier("Goals.TargetLabel")
                        } else {
                            Text(NSLocalizedString("goals.cta.set", comment: "Ziel festlegen"))
                                .font(.callout)
                                .foregroundColor(AppColors.textSecondary)
                                .accessibilityIdentifier("Goals.NoGoalLabel")
                        }
                    }
                }
                .frame(width: 220, height: 220)
                .padding(.top, AppSpace.xl)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(NSLocalizedString("goals.accessibility.progress", comment: "Fortschritt"))
                .accessibilityValue(progressPercent(viewModel.progress))
                .accessibilityIdentifier("Goals.ProgressRing")

                // MARK: Streak
                HStack(spacing: AppSpace.sm) {
                    Label {
                        Text("\(viewModel.streakCount)")
                            .font(.headline)
                        Text(NSLocalizedString("goals.streak.days", comment: "Tage in Folge"))
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    } icon: {
                        Image(systemName: "flame.fill")
                    }
                    .accessibilityIdentifier("Goals.StreakBadge")

                    Spacer()

                    // CTA
                    Button {
                        // Sheet/Edit folgt in Iteration 2
                    } label: {
                        Text(NSLocalizedString("goals.cta.edit", comment: "Ziel anpassen"))
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("Goals.EditButton")
                }
                .padding(.horizontal, AppSpace.lg)

                // Optional: kleine Metrik-Karte
                metricTile(minutes: viewModel.totalMinutes)
                    .padding(.horizontal, AppSpace.lg)

                Spacer(minLength: AppSpace.xl)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, AppSpace.xl)
        }
        .navigationTitle(Text(NSLocalizedString("goals.title", comment: "Lesziele")))
        .onAppear {
            viewModel.calculateProgress()
        }
        .onChange(of: viewModel.progress) { oldValue, newValue in
            // Nur bei Erreichen des Ziels (Threshold-Crossing) haptisch feedbacken
            let wasBelow = oldValue < 1.0
            let isNowFull = newValue >= 1.0
            if wasBelow && isNowFull {
                #if !TARGET_IPHONE_SIMULATOR
                let gen = UINotificationFeedbackGenerator()
                gen.notificationOccurred(.success)
                #endif
            }
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
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
            Text("\(minutes) " + NSLocalizedString("goals.metric.minutes", comment: "Minuten"))
                .font(.title3).bold()
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(AppSpace.lg)
        .background(AppColors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .shadow(color: AppShadow.card.color, radius: AppShadow.card.radius, x: AppShadow.card.x, y: AppShadow.card.y)
        .accessibilityIdentifier("Goals.MetricTile")
    }
}

