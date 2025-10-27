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
                NavigationLink {
                    InsightsView(context: context)
                } label: {
                    HStack {
                        Text(LocalizedStringKey("profile.cta.insights"))
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(AppColors.surfacePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.l)
                            .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75)
                    )
                }
                .accessibilityIdentifier("Profile.InsightsLink")
                NavigationLink {
                    AchievementsView(context: context)
                } label: {
                    Label(LocalizedStringKey("achv.title"), systemImage: "rosette")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.surfacePrimary)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.l)
                                .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75)
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
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.surfacePrimary)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.l)
                                .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75)
                        )
                }
                .accessibilityIdentifier("Profile.AudiobookLightLink")
                NavigationLink {
                    ReadingHistoryView(context: context)
                } label: {
                    Label(LocalizedStringKey("history.title"), systemImage: "clock")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.surfacePrimary)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.l)
                                .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75)
                        )
                }
                .accessibilityIdentifier("Profile.HistoryLink")
            }
            .padding(.horizontal, AppSpace.lg)
            .padding(.top, AppSpace.xl)
        }
        .navigationTitle(Text(LocalizedStringKey("profile.title")))
        .task {
            vm.reload()
        }
    }

    // MARK: - Subviews

    private func header() -> some View {
        HStack(spacing: AppSpace.lg) {
            Circle()
                .fill(AppColors.brandPrimary.opacity(0.15))
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundStyle(AppColors.brandPrimary)
                )
                .frame(width: 56, height: 56)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey("profile.greeting"))
                    .font(.headline)
                Text(LocalizedStringKey("profile.subtitle"))
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("Profile.Header")
    }

    private func metricsGrid() -> some View {
        VStack(spacing: AppSpace.md) {
            // Gesamtminuten im aktuellen Monat (lesen + hören)
            metricRow(
                title: String(localized: "profile.metric.monthMinutes"),
                value: "\(vm.monthMinutes) " + String(localized: "goals.metric.minutes"),
                a11y: "Profile.Metric.MonthMinutes"
            )

            // Aufgeschlüsselt nach Medium
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

    private func metricRow(title: String, value: String, a11y: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline).foregroundColor(AppColors.textSecondary)
                Text(value).font(.headline)
            }
            Spacer()
        }
        .padding(AppSpace.lg)
        .background(AppColors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.l)
                .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75)
        )
        .shadow(color: AppShadow.card.color, radius: AppShadow.card.radius, x: AppShadow.card.x, y: AppShadow.card.y)
        .accessibilityIdentifier(a11y)
    }
}
