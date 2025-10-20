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
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, AppSpace.lg)
        .accessibilityIdentifier("Achievements.Header")
    }

    // MARK: - Badge Card

    @ViewBuilder
    private func badgeCard(for a: Achievement) -> some View {
        let fg = a.unlocked ? AppColors.textPrimary : AppColors.textSecondary
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            HStack(spacing: AppSpace.sm) {
                Image(systemName: a.systemImage)
                    .imageScale(.large)
                    .foregroundStyle(a.unlocked ? AppColors.brandPrimary : AppColors.textSecondary)
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
                    .foregroundStyle(AppColors.brandPrimary)
                    .padding(.top, 2)
            }

            if !a.unlocked {
                Text(String(localized: "achv.locked.hint"))
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(AppSpace.lg)
        .background(AppColors.surfacePrimary.opacity(a.unlocked ? 1.0 : 0.9))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.l)
                .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75)
        )
        .shadow(color: AppShadow.card.color,
                radius: AppShadow.card.radius,
                x: AppShadow.card.x,
                y: AppShadow.card.y)
        .opacity(a.unlocked ? 1.0 : 0.8)
        .accessibilityIdentifier("Achievements.Badge.\(a.id)")
    }
}

