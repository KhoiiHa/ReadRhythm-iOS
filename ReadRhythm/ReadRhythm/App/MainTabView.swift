//
//  MainTabView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 16.10.25.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var settings: AppSettingsService

    var body: some View {
        TabView {
            NavigationStack {
                LibraryView()
            }
            .tabItem { Label(String(localized: "rr.tab.library"), systemImage: "books.vertical") }
            .accessibilityIdentifier("tab.library")

            NavigationStack {
                DiscoverView()
            }
            .tabItem { Label(String(localized: "rr.tab.discover"), systemImage: "sparkles") }
            .accessibilityIdentifier("tab.discover")

            NavigationStack {
                StatsView()
            }
            .tabItem { Label(String(localized: "rr.tab.stats"), systemImage: "chart.bar") }
            .accessibilityIdentifier("tab.stats")

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label(String(localized: "rr.tab.settings"), systemImage: "gearshape") }
            .accessibilityIdentifier("tab.settings")
        }
        .preferredColorScheme(settings.themeMode.colorScheme)
        .accessibilityIdentifier("main.tabview")
        .tint(AppColors.Semantic.tintPrimary)
        .task {
            #if DEBUG
            DataService.shared.seedDemoDataIfNeeded(context)
            #endif
        }
    }
}
