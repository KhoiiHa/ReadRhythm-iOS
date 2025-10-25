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
                StatsView()
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

            // Profil
            NavigationStack {
                ProfileView(context: context)
            }
            .tabItem {
                Label(LocalizedStringKey("rr.tab.profile"), systemImage: "person.circle")
            }
            .accessibilityIdentifier("tab.profile")

            // Einstellungen
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label(LocalizedStringKey("rr.tab.settings"), systemImage: "gearshape")
            }
            .accessibilityIdentifier("tab.settings")
        }
        // Theme / Tint
        .preferredColorScheme(settings.themeMode.colorScheme)
        .tint(AppColors.Semantic.tintPrimary)
        .accessibilityIdentifier("main.tabview")

        // Seed-Daten nur im Debug
        .task {
            #if DEBUG
            // Dependency Injection statt Singleton:
            // Wir erzeugen hier eine lokale Service-Instanz mit dem aktuellen ModelContext.
            let service = DataService(context: context)

            if service.fetchAllBooks().isEmpty {
                service.seedDemoDataIfNeeded()
                print("🌱 [MainTabView] Demo data seeded for empty store.")
            }
            #endif
        }
    }
}
