//
//  SettingsView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 15.10.25.
//

import SwiftUI

/// Kontext → Warum → Wie
/// - Kontext: Globale Darstellung steuern (System/Hell/Dunkel) über AppSettingsService.
/// - Warum: App-weite Umschaltung ohne Geräteeinstellungen; portfolio-tauglich und testbar.
/// - Wie: Picker bindet an `settings.themeMode`; Root (MainTabView/ReadRhythmApp) liest `.preferredColorScheme`.
struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettingsService
    @Environment(\.modelContext) private var context

    var body: some View {
        Form {
            // MARK: - Theme Mode

            Section {
                Picker("settings.theme.title", selection: $settings.themeMode) {
                    ForEach(AppThemeMode.allCases) { mode in
                        Text(mode.localizedTitleKey)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("settings.theme.picker")
            } header: {
                Text("settings.appearance.section")
                    .font(AppFont.caption2())
                    .foregroundStyle(AppColors.Semantic.textSecondary)
            }

            // MARK: - Theme Preview

            Section {
                VStack(alignment: .leading, spacing: AppSpace._12) {
                    Text("settings.preview.section")
                        .font(AppFont.headingS())
                        .foregroundStyle(AppColors.Semantic.textPrimary)

                    HStack(spacing: AppSpace._12) {
                        RoundedRectangle(cornerRadius: AppRadius.m)
                            .fill(AppColors.Semantic.bgScreen)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text("A")
                                    .font(AppFont.headingM())
                                    .foregroundStyle(AppColors.Semantic.textPrimary)
                            )
                            .accessibilityIdentifier("settings.preview.tile.primary")

                        RoundedRectangle(cornerRadius: AppRadius.m)
                            .fill(AppColors.Semantic.bgCard)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text("B")
                                    .font(AppFont.headingM())
                                    .foregroundStyle(AppColors.Semantic.textSecondary)
                            )
                            .accessibilityIdentifier("settings.preview.tile.secondary")

                        RoundedRectangle(cornerRadius: AppRadius.m)
                            .fill(AppColors.Semantic.tintPrimary)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "star.fill")
                                    .foregroundStyle(AppColors.Semantic.textInverse)
                            )
                            .accessibilityIdentifier("settings.preview.tile.tint")
                    }
                    .padding(.vertical, AppSpace._4)
                }
                .padding(.vertical, AppSpace._8)
            } header: {
                Text("settings.preview.section")
                    .font(AppFont.caption2())
                    .foregroundStyle(AppColors.Semantic.textSecondary)
            }

            // MARK: - Debug

#if DEBUG
            Section {
                Button(role: .destructive) {
                    DataService.resetDemoData(context)
                } label: {
                    Label {
                        Text(String(localized: "settings.debug.resetData"))
                            .font(AppFont.bodyStandard())
                    } icon: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                .accessibilityIdentifier("settings.debug.resetData")
            } header: {
                Text("Debug")
                    .font(AppFont.caption2())
                    .foregroundStyle(AppColors.Semantic.textSecondary)
            }
#endif
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .listRowBackground(AppColors.Semantic.bgCard)
        .background(AppColors.Semantic.bgScreen.ignoresSafeArea())
        .navigationTitle(Text("rr.tab.settings"))
        .navigationBarTitleDisplayMode(.inline)
        .tint(AppColors.Semantic.tintPrimary)
        .accessibilityIdentifier("settings.view")
    }
}
