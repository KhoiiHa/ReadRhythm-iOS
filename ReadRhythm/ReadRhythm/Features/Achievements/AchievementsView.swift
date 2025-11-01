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
                .font(.title2).bold()
            Text(String(localized: "achv.subtitle"))
                .font(.subheadline)
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
                    .font(.headline)
                    .foregroundStyle(fg)
                Spacer()
            }

            Text(LocalizedStringKey(a.subtitleKey))
                .font(.subheadline)
                .foregroundStyle(fg)

            if let hv = a.highlightValue, a.unlocked {
                Text(hv)
                    .font(.caption)
                    .foregroundStyle(AppColors.Brand.primary)
                    .padding(.top, 2)
            }

            if !a.unlocked {
                Text(String(localized: "achv.locked.hint"))
                    .font(.caption)
                    .foregroundStyle(AppColors.Semantic.textSecondary)
            }
        }
        .padding(AppSpace.lg)
        .cardBackground()
        .shadow(color: AppShadow.card.color,
                radius: AppShadow.card.radius,
                x: AppShadow.card.x,
                y: AppShadow.card.y)
        .opacity(a.unlocked ? 1.0 : 0.8)
        .accessibilityIdentifier("Achievements.Badge.\(a.id)")
    }
}
