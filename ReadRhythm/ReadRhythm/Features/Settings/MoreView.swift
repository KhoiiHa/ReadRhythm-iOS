//
//  MoreView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 03.11.25.
//

import SwiftUI
import SwiftData

struct MoreView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpace._16) {
                Text(LocalizedStringKey("more.subtitle"))
                    .font(AppFont.bodyStandard())
                    .foregroundStyle(AppColors.Semantic.textSecondary)
                    .padding(.horizontal, AppSpace._16)

                VStack(spacing: 0) {
                    MoreRow(
                        titleKey: "rr.tab.profile",
                        subtitleKey: "more.profile.subtitle",
                        systemImage: "person.crop.circle"
                    ) {
                        ProfileView(context: context)
                    }
                    .accessibilityIdentifier("More.ProfileLink")

                    Divider()
                        .padding(.leading, 72)

                    MoreRow(
                        titleKey: "rr.tab.settings",
                        subtitleKey: "more.settings.subtitle",
                        systemImage: "gearshape"
                    ) {
                        SettingsView()
                    }
                    .accessibilityIdentifier("More.SettingsLink")
                }
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous)
                        .fill(AppColors.Semantic.bgCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous)
                                .stroke(AppColors.Semantic.borderMuted.opacity(0.75), lineWidth: AppStroke.cardBorder)
                        )
                        .shadow(color: AppColors.Semantic.shadowColor.opacity(0.9), radius: 12, x: 0, y: 6)
                )
                .padding(.horizontal, AppSpace._16)
            }
            .padding(.top, AppSpace._16)
            .padding(.bottom, AppLayout.tabBarContentClearance)
        }
        .screenBackground()
        .tint(AppColors.Semantic.tintPrimary)
        .navigationTitle(Text(LocalizedStringKey("rr.tab.more")))
        .navigationBarTitleDisplayMode(.large)
        .accessibilityIdentifier("more.view")
    }
}

private struct MoreRow<Destination: View>: View {
    let titleKey: String
    let subtitleKey: String
    let systemImage: String
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: AppSpace._12) {
                Image(systemName: systemImage)
                    .font(.system(size: 22, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .foregroundStyle(AppColors.Semantic.tintPrimary)
                    .background(
                        Circle()
                            .fill(AppColors.Semantic.tintPrimary.opacity(0.12))
                    )
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: AppSpace._4) {
                    Text(LocalizedStringKey(titleKey))
                        .font(AppFont.bodyStandard(.semibold))
                        .foregroundStyle(AppColors.Semantic.textPrimary)

                    Text(LocalizedStringKey(subtitleKey))
                        .font(AppFont.caption2())
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: AppSpace._8)

                Image(systemName: "chevron.right")
                    .font(AppFont.caption2(.semibold))
                    .foregroundStyle(AppColors.Semantic.textSecondary)
            }
            .padding(AppSpace._16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
