//
//  ProfileView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 20.10.25.
//

import SwiftUI
import SwiftData

@MainActor
struct ProfileView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var vm: ProfileViewModel

    init(context: ModelContext) {
        _vm = StateObject(
            wrappedValue: ProfileViewModel(context: context)
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpace.lg) {
                header()
                metricsGrid()
                navigationCards
            }
            .padding(.horizontal, AppSpace.lg)
            .padding(.vertical, AppSpace.lg)
        }
        .screenBackground()
        .navigationTitle(Text(LocalizedStringKey("profile.title")))
        .task {
            vm.reload()
        }
    }

    // MARK: - Subviews

    private func header() -> some View {
        HStack(spacing: AppSpace.md) {
            Circle()
                .fill(AppColors.brandPrimary.opacity(0.2))
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundStyle(AppColors.brandPrimary)
                )
                .frame(width: 64, height: 64)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: AppSpace.xs) {
                Text(LocalizedStringKey("profile.greeting"))
                    .font(AppFont.headingM())
                Text(LocalizedStringKey("profile.subtitle"))
                    .font(AppFont.bodyStandard())
                    .foregroundStyle(AppColors.Semantic.textSecondary)
            }
            Spacer()
        }
        .padding(AppSpace.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardBackground()
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .shadow(
            color: AppShadow.card.color,
            radius: AppShadow.card.radius,
            x: AppShadow.card.x,
            y: AppShadow.card.y
        )
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("Profile.Header")
    }

    private func metricsGrid() -> some View {
        VStack(spacing: AppSpace.lg) {
            metricRow(
                title: String(localized: "profile.metric.monthMinutes"),
                value: "\(vm.monthMinutes) " + String(localized: "goals.metric.minutes"),
                a11y: "Profile.Metric.MonthMinutes"
            )

            metricRow(
                title: String(localized: "profile.metric.mediumBreakdown"),
                value: vm.monthMediumBreakdownString(),
                a11y: "Profile.Metric.MediumBreakdown"
            )

            metricRow(
                title: String(localized: "profile.metric.monthSessions"),
                value: "\(vm.monthSessions)",
                a11y: "Profile.Metric.MonthSessions"
            )

            metricRow(
                title: String(localized: "profile.metric.avgPerDay"),
                value: NumberFormatter.localizedString(from: NSNumber(value: vm.avgPerDay), number: .decimal) + " " + String(localized: "goals.metric.minutes"),
                a11y: "Profile.Metric.AvgPerDay"
            )

            metricRow(
                title: String(localized: "profile.metric.streak"),
                value: "\(vm.currentStreak) " + String(localized: "goals.streak.days"),
                a11y: "Profile.Metric.Streak"
            )

            if let idx = vm.bestWeekdayIndex {
                metricRow(
                    title: String(localized: "profile.metric.bestWeekday"),
                    value: "\(vm.weekdayLabel(for: idx)) – \(vm.bestWeekdayMinutes) " + String(localized: "goals.metric.minutes"),
                    a11y: "Profile.Metric.BestWeekday"
                )
            }
        }
        .accessibilityIdentifier("Profile.Metrics")
    }

    private var navigationCards: some View {
        VStack(spacing: AppSpace.lg) {
            NavigationLink {
                InsightsView(context: context)
            } label: {
                HStack {
                    Text(LocalizedStringKey("profile.cta.insights"))
                        .font(AppFont.bodyStandard())
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(AppFont.caption2())
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(AppSpace.lg)
                .cardBackground()
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
                .shadow(
                    color: AppShadow.card.color,
                    radius: AppShadow.card.radius,
                    x: AppShadow.card.x,
                    y: AppShadow.card.y
                )
            }
            .accessibilityIdentifier("Profile.InsightsLink")

            NavigationLink {
                AchievementsView(context: context)
            } label: {
                Label(LocalizedStringKey("achv.title"), systemImage: "rosette")
                    .font(AppFont.bodyStandard())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(AppSpace.lg)
                    .cardBackground()
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
                    .shadow(
                        color: AppShadow.card.color,
                        radius: AppShadow.card.radius,
                        x: AppShadow.card.x,
                        y: AppShadow.card.y
                    )
            }
            .accessibilityIdentifier("Profile.AchievementsLink")

            NavigationLink {
                AudiobookLightView(
                    initialText: "",
                    sessionRepository: LocalSessionRepository(context: context),
                    speechService: SpeechService.shared
                )
            } label: {
                Label(LocalizedStringKey("audio.nav.title"), systemImage: "waveform")
                    .font(AppFont.bodyStandard())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(AppSpace.lg)
                    .cardBackground()
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
                    .shadow(
                        color: AppShadow.card.color,
                        radius: AppShadow.card.radius,
                        x: AppShadow.card.x,
                        y: AppShadow.card.y
                    )
            }
            .accessibilityIdentifier("Profile.AudiobookLightLink")

            NavigationLink {
                ReadingHistoryView(context: context)
            } label: {
                Label(LocalizedStringKey("history.title"), systemImage: "clock")
                    .font(AppFont.bodyStandard())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(AppSpace.lg)
                    .cardBackground()
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
                    .shadow(
                        color: AppShadow.card.color,
                        radius: AppShadow.card.radius,
                        x: AppShadow.card.x,
                        y: AppShadow.card.y
                    )
            }
            .accessibilityIdentifier("Profile.HistoryLink")
        }
    }

    private func metricRow(title: String, value: String, a11y: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: AppSpace.xs) {
                Text(title)
                    .font(AppFont.caption2())
                    .foregroundStyle(AppColors.Semantic.textSecondary)
                Text(value)
                    .font(AppFont.headingM())
                    .foregroundStyle(AppColors.Semantic.textPrimary)
            }
            Spacer()
        }
        .padding(AppSpace.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(AppColors.Semantic.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .stroke(
                            AppColors.Semantic.tintPrimary.opacity(0.14),
                            lineWidth: 1
                        )
                )
        )
        .accessibilityIdentifier(a11y)
    }
}
