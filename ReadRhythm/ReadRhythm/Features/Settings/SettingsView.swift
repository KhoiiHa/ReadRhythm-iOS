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
            Section {
                Picker("settings.theme.title", selection: $settings.themeMode) {
                    ForEach(AppThemeMode.allCases) { mode in
                        Text(mode.localizedTitleKey).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("settings.theme.picker")
            } header: {
                Text("settings.appearance.section")
            }

            // Theme Preview Section
            Section {
                VStack(alignment: .leading, spacing: AppSpace._12) {
                    Text("settings.preview.section")
                        .font(.headline)
                        .foregroundStyle(AppColors.Semantic.textPrimary)

                    HStack(spacing: AppSpace._12) {
                        RoundedRectangle(cornerRadius: AppRadius.m)
                            .fill(AppColors.Semantic.bgPrimary)
                            .frame(width: 60, height: 60)
                            .overlay(Text("A").font(.title).foregroundStyle(AppColors.Semantic.textPrimary))

                        RoundedRectangle(cornerRadius: AppRadius.m)
                            .fill(AppColors.Semantic.bgSecondary)
                            .frame(width: 60, height: 60)
                            .overlay(Text("B").font(.title).foregroundStyle(AppColors.Semantic.textSecondary))

                        RoundedRectangle(cornerRadius: AppRadius.m)
                            .fill(AppColors.Semantic.tintPrimary)
                            .frame(width: 60, height: 60)
                            .overlay(Image(systemName: "star.fill").foregroundStyle(.white))
                    }
                    .padding(.vertical, AppSpace._4)
                }
                .padding(.vertical, AppSpace._8)
            } header: {
                Text("settings.preview.section")
            }

#if DEBUG
            Section {
                Button(role: .destructive) {
                    DataService.resetDemoData(context)
                } label: {
                    Label(String(localized: "settings.debug.resetData"),
                          systemImage: "arrow.clockwise")
                }
                .accessibilityIdentifier("settings.debug.resetData")
            } header: {
                Text("Debug")
            }
#endif
        }
        .navigationTitle(Text("rr.tab.settings"))
        .navigationBarTitleDisplayMode(.inline)
        .background(AppColors.Semantic.bgPrimary)
        .tint(AppColors.Semantic.tintPrimary)
        .accessibilityIdentifier("settings.view")
    }
}
