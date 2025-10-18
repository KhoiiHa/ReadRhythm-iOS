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
        }
        .navigationTitle("rr.tab.settings")
        .background(AppColors.Semantic.bgPrimary)
        .tint(AppColors.Semantic.tintPrimary)
        .accessibilityIdentifier("settings.view")
    }
}
