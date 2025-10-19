//
//  MainTabView.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 16.10.25.
//
//  Refactor/Portfolio Polish:
//  - Klare Theme-Anbindung über AppSettingsService
//  - Einheitliche NavigationStack-Struktur je Tab
//  - Seed-Check nur im DEBUG-Modus
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    // MARK: - Environment
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var settings: AppSettingsService

    // MARK: - Body
    var body: some View {
        TabView {
            NavigationStack {
                LibraryView()
            }
            .tabItem {
                Label(String(localized: "rr.tab.library"), systemImage: "books.vertical")
            }
            .accessibilityIdentifier("tab.library")

            NavigationStack {
                DiscoverView()
            }
            .tabItem {
                Label(String(localized: "rr.tab.discover"), systemImage: "sparkles")
            }
            .accessibilityIdentifier("tab.discover")

            NavigationStack {
                StatsView()
            }
            .tabItem {
                Label(String(localized: "rr.tab.stats"), systemImage: "chart.bar")
            }
            .accessibilityIdentifier("tab.stats")

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label(String(localized: "rr.tab.settings"), systemImage: "gearshape")
            }
            .accessibilityIdentifier("tab.settings")
        }
        // MARK: - Theme & Global Appearance
        .preferredColorScheme(settings.themeMode.colorScheme)
        .tint(AppColors.Semantic.tintPrimary)
        .accessibilityIdentifier("main.tabview")
        .navigationTitle(Text("rr.tab.settings"))
        .navigationBarTitleDisplayMode(.inline)

        // MARK: - Seed Demo Data (DEBUG)
        .task {
            #if DEBUG
            if DataService.shared.hasAnyBooks(in: context) == false {
                DataService.shared.seedDemoDataIfNeeded(context)
                print("🌱 [MainTabView] Demo data seeded for empty store.")
            }
            #endif
        }
    }
}
