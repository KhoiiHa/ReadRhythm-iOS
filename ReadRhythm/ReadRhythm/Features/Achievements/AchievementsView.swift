//
//  AchievementsView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 20.10.25.
//


import SwiftUI
import SwiftData

struct AchievementsView: View {
    @ObservedObject private var vm: AchievementsViewModel

    init(context: ModelContext) {
        self.vm = AchievementsViewModel(context: context)
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppSpace.lg) {
                headerSection

                LazyVGrid(columns: gridLayout, spacing: AppSpace.lg) {
                    ForEach(vm.items) { achievement in
                        badgeCard(for: achievement)
                    }
                }
                .padding(.horizontal, AppSpace.lg)
                .accessibilityIdentifier("Achievements.Grid")
            }
            .padding(.top, AppSpace.xl)
        }
        .screenBackground()
        .navigationTitle(Text(String(localized: "achv.title")))
        .onAppear { vm.reload() }
    }

    // MARK: - Layouts

    private var gridLayout: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible())]
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            Text(String(localized: "achv.headline"))
                .font(AppFont.headingM())
            Text(String(localized: "achv.subtitle"))
                .font(AppFont.bodyStandard())
                .foregroundStyle(AppColors.Semantic.textSecondary)
        }
        .padding(.horizontal, AppSpace.lg)
        .accessibilityIdentifier("Achievements.Header")
    }

    // MARK: - Badge Card

    @ViewBuilder
    private func badgeCard(for a: Achievement) -> some View {
        let fg = a.unlocked ? AppColors.Semantic.textPrimary : AppColors.Semantic.textSecondary
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            HStack(spacing: AppSpace.sm) {
                Image(systemName: a.systemImage)
                    .imageScale(.large)
                    .foregroundStyle(a.unlocked ? AppColors.Brand.primary : AppColors.Semantic.textSecondary)
                    .frame(width: 28)
                Text(LocalizedStringKey(a.titleKey))
                    .font(AppFont.headingS())
                    .foregroundStyle(fg)
                Spacer()
            }

            Text(LocalizedStringKey(a.subtitleKey))
                .font(AppFont.bodyStandard())
                .foregroundStyle(fg)

            if let hv = a.highlightValue, a.unlocked {
                Text(hv)
                    .font(AppFont.caption2())
                    .foregroundStyle(AppColors.Brand.primary)
                    .padding(.top, 2)
            }

            if !a.unlocked {
                Text(String(localized: "achv.locked.hint"))
                    .font(AppFont.caption2())
                    .foregroundStyle(AppColors.Semantic.textSecondary)
            }
        }
        .padding(AppSpace.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.m, style: .continuous)
                .fill(AppColors.Semantic.bgCard)
                .shadow(
                    color: AppColors.Semantic.shadowColor.opacity(0.12),
                    radius: 10,
                    x: 0,
                    y: 6
                )
        )
        .opacity(a.unlocked ? 1.0 : 0.8)
        .accessibilityIdentifier("Achievements.Badge.\(a.id)")
    }
}
