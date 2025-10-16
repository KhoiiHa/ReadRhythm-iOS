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

    var body: some View {
        TabView {
            LibraryView()
                .tabItem { Label("Library", systemImage: "books.vertical") } // TODO: i18n key
                .accessibilityIdentifier("tab.library")

            DiscoverView()
                .tabItem { Label("Discover", systemImage: "sparkles") } // TODO: i18n key
                .accessibilityIdentifier("tab.discover")

            StatsView()
                .tabItem { Label("Stats", systemImage: "chart.bar") } // TODO: i18n key
                .accessibilityIdentifier("tab.stats")

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") } // TODO: i18n key
                .accessibilityIdentifier("tab.settings")
        }
        .accessibilityIdentifier("main.tabview")
        .task {
            #if DEBUG
            DataService.shared.seedDemoDataIfNeeded(context)
            #endif
        }
    }
}
