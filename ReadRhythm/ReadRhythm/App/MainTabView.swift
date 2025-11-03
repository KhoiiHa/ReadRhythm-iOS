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

    var body: some View {
        TabView {
            // Bibliothek
            NavigationStack {
                LibraryView()
            }
            .tabItem {
                Label(LocalizedStringKey("rr.tab.library"), systemImage: "books.vertical")
            }
            .accessibilityIdentifier("tab.library")

            // Entdecken
            NavigationStack {
                DiscoverView()
            }
            .tabItem {
                Label(LocalizedStringKey("rr.tab.discover"), systemImage: "sparkles")
            }
            .accessibilityIdentifier("tab.discover")

            // Statistiken
            NavigationStack {
                StatsView(context: context)
            }
            .tabItem {
                Label(LocalizedStringKey("rr.tab.stats"), systemImage: "chart.bar")
            }
            .accessibilityIdentifier("tab.stats")

            // Ziele
            NavigationStack {
                ReadingGoalsView(context: context)
            }
            .tabItem {
                Label(LocalizedStringKey("rr.tab.goals"), systemImage: "target")
            }
            .accessibilityIdentifier("tab.goals")

            // More
            NavigationStack {
                MoreView()
            }
            .tabItem {
                Label("More", systemImage: "ellipsis")
            }
            .accessibilityIdentifier("tab.more")
        }
        // Theme / Tint
        .preferredColorScheme(settings.themeMode.colorScheme)
        .tint(AppColors.Semantic.tintPrimary)
        .background(AppColors.Semantic.bgScreen)
        .accessibilityIdentifier("main.tabview")
    }
}
