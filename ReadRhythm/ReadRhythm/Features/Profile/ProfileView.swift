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
            .padding(.bottom, AppLayout.tabBarContentClearance)
        }
        .screenBackground()
        .navigationTitle(Text(LocalizedStringKey("profile.title")))
        .task {
            vm.reload()
        }
    }

    // MARK: - Subviews

    private func header() -> some View {
        VStack(alignment: .leading, spacing: AppSpace.lg) {
            HStack(alignment: .top, spacing: AppSpace.md) {
                Circle()
                    .fill(AppColors.Semantic.chipBg)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(AppColors.Semantic.tintPrimary)
                    )
                    .frame(width: 58, height: 58)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: AppSpace.xs) {
                    Text(LocalizedStringKey("profile.greeting"))
                        .font(AppFont.headingM())
                        .foregroundStyle(AppColors.Semantic.textPrimary)

                    Text(LocalizedStringKey("profile.subtitle"))
                        .font(AppFont.bodyStandard())
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: AppSpace.sm) {
                Text(LocalizedStringKey("profile.metric.monthMinutes"))
                    .font(AppFont.caption1(.semibold))
                    .foregroundStyle(AppColors.Semantic.textSecondary)

                Text(minutesText(vm.monthMinutes))
                    .font(AppFont.titleLarge)
                    .foregroundStyle(AppColors.Semantic.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)

                mediumBreakdownBar()
            }
        }
        .padding(AppSpace.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(AppColors.Semantic.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .stroke(AppColors.Semantic.borderMuted.opacity(0.75), lineWidth: 0.75)
                )
        )
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
        let columns = [
            GridItem(.flexible(), spacing: AppSpace.md),
            GridItem(.flexible(), spacing: AppSpace.md)
        ]

        return LazyVGrid(columns: columns, alignment: .leading, spacing: AppSpace.md) {
            metricCard(
                icon: "calendar.badge.clock",
                tint: AppColors.Semantic.tintPrimary,
                title: String(localized: "profile.metric.monthSessions"),
                value: "\(vm.monthSessions)",
                a11y: "Profile.Metric.MonthSessions"
            )

            metricCard(
                icon: "flame.fill",
                tint: AppColors.Semantic.tintSecondary,
                title: String(localized: "profile.metric.streak"),
                value: "\(vm.currentStreak) " + String(localized: "goals.streak.days"),
                a11y: "Profile.Metric.Streak"
            )

            metricCard(
                icon: "chart.line.uptrend.xyaxis",
                tint: AppColors.Semantic.tintPrimary,
                title: String(localized: "profile.metric.avgPerDay"),
                value: decimalText(vm.avgPerDay) + " " + String(localized: "goals.metric.minutes"),
                a11y: "Profile.Metric.AvgPerDay"
            )

            metricCard(
                icon: "book.closed.fill",
                tint: AppColors.Semantic.tintPrimary,
                title: String(localized: "profile.metric.monthMinutes"),
                value: "\(vm.monthMinutes) " + String(localized: "goals.metric.minutes"),
                a11y: "Profile.Metric.MonthMinutes"
            )

            metricCard(
                icon: "waveform",
                tint: AppColors.Semantic.tintSecondary,
                title: String(localized: "profile.metric.mediumBreakdown"),
                value: vm.monthMediumBreakdownString(),
                a11y: "Profile.Metric.MediumBreakdown"
            )

            if let idx = vm.bestWeekdayIndex {
                metricCard(
                    icon: "star.fill",
                    tint: AppColors.Semantic.tintSecondary,
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
                actionRow(
                    title: LocalizedStringKey("profile.cta.insights"),
                    subtitle: LocalizedStringKey("profile.subtitle"),
                    systemImage: "chart.xyaxis.line",
                    isPrimary: true
                )
            }
            .accessibilityIdentifier("Profile.InsightsLink")

            NavigationLink {
                AchievementsView(context: context)
            } label: {
                actionRow(
                    title: LocalizedStringKey("achv.title"),
                    subtitle: LocalizedStringKey("profile.metric.streak"),
                    systemImage: "rosette"
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
                actionRow(
                    title: LocalizedStringKey("audio.nav.title"),
                    subtitle: LocalizedStringKey("profile.metric.mediumBreakdown"),
                    systemImage: "waveform"
                )
            }
            .accessibilityIdentifier("Profile.AudiobookLightLink")

            NavigationLink {
                ReadingHistoryView(context: context)
            } label: {
                actionRow(
                    title: LocalizedStringKey("history.title"),
                    subtitle: LocalizedStringKey("profile.metric.monthSessions"),
                    systemImage: "clock"
                )
            }
            .accessibilityIdentifier("Profile.HistoryLink")
        }
    }

    private func metricCard(
        icon: String,
        tint: Color,
        title: String,
        value: String,
        a11y: String
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 30, height: 30)
                .background(tint.opacity(0.12), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: AppSpace.xs) {
                Text(title)
                    .font(AppFont.caption2())
                    .foregroundStyle(AppColors.Semantic.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(value)
                    .font(AppFont.headingS())
                    .foregroundStyle(AppColors.Semantic.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(AppSpace.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 136, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous)
                .fill(AppColors.Semantic.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous)
                        .stroke(
                            AppColors.Semantic.borderMuted.opacity(0.72),
                            lineWidth: 0.75
                        )
                )
        )
        .accessibilityIdentifier(a11y)
        .accessibilityElement(children: .combine)
    }

    private func actionRow(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey,
        systemImage: String,
        isPrimary: Bool = false
    ) -> some View {
        HStack(spacing: AppSpace.md) {
            Image(systemName: systemImage)
                .font(.headline.weight(.semibold))
                .foregroundStyle(isPrimary ? AppColors.Semantic.textInverse : AppColors.Semantic.tintPrimary)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(isPrimary ? AppColors.Semantic.tintPrimary : AppColors.Semantic.chipBg)
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: AppSpace.xs) {
                Text(title)
                    .font(AppFont.headingS())
                    .foregroundStyle(AppColors.Semantic.textPrimary)

                Text(subtitle)
                    .font(AppFont.caption1())
                    .foregroundStyle(AppColors.Semantic.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: AppSpace.sm)

            Image(systemName: "chevron.right")
                .font(AppFont.caption1(.semibold))
                .foregroundStyle(AppColors.Semantic.textSecondary)
                .accessibilityHidden(true)
        }
        .padding(AppSpace.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(AppColors.Semantic.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .stroke(AppColors.Semantic.borderMuted.opacity(0.75), lineWidth: 0.75)
                )
        )
        .shadow(
            color: AppShadow.card.color,
            radius: AppShadow.card.radius,
            x: AppShadow.card.x,
            y: AppShadow.card.y
        )
        .accessibilityElement(children: .combine)
    }

    private func mediumBreakdownBar() -> some View {
        let total = max(vm.monthReadingMinutes + vm.monthListeningMinutes, 1)
        let readingShare = CGFloat(vm.monthReadingMinutes) / CGFloat(total)

        return VStack(alignment: .leading, spacing: AppSpace.sm) {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppColors.Semantic.chipBg)

                    Capsule()
                        .fill(AppColors.Semantic.tintPrimary)
                        .frame(width: vm.monthReadingMinutes > 0 ? max(8, proxy.size.width * readingShare) : 0)
                }
            }
            .frame(height: 8)
            .accessibilityHidden(true)

            HStack(spacing: AppSpace.sm) {
                mediumLegend(
                    color: AppColors.Semantic.tintPrimary,
                    label: String(localized: "insights.mode.reading"),
                    value: vm.monthReadingMinutes
                )

                Spacer(minLength: AppSpace.sm)

                mediumLegend(
                    color: AppColors.Semantic.tintSecondary,
                    label: String(localized: "insights.mode.listening"),
                    value: vm.monthListeningMinutes
                )
            }
        }
    }

    private func mediumLegend(color: Color, label: String, value: Int) -> some View {
        HStack(spacing: AppSpace.xs) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
                .accessibilityHidden(true)

            Text("\(label) \(value) min")
                .font(AppFont.caption2(.semibold))
                .foregroundStyle(AppColors.Semantic.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }

    private func minutesText(_ minutes: Int) -> String {
        "\(minutes) " + String(localized: "goals.metric.minutes")
    }

    private func decimalText(_ value: Double) -> String {
        NumberFormatter.localizedString(from: NSNumber(value: value), number: .decimal)
    }
}
