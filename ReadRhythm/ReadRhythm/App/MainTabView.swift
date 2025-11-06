// MARK: - Haupt-Navigation / Main Navigation
// Bündelt alle Feature-Tabs und verbindet sie mit gemeinsamen Services /
// Collects all feature tabs and wires them to shared services.

import SwiftUI
import SwiftData

struct MainTabView: View {
    // MARK: - Environment
    // Kontext für Repository-Aufgaben / Context for repository work
    @Environment(\.modelContext) private var context
    // Globale UI-Einstellungen wie Theme / Global UI settings such as theme
    @EnvironmentObject private var settings: AppSettingsService

    var body: some View {
        // Root-Container für die Modulnavigation / Root container for module navigation
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
        .preferredColorScheme(settings.themeMode.colorScheme) // Synchronisiert App-Theme / Syncs app-wide theme
        .tint(AppColors.Semantic.tintPrimary) // Konsistente Primärfarbe / Consistent primary tint
        .background(AppColors.Semantic.bgScreen) // Einheitlicher Hintergrund / Unified background tone
        .accessibilityIdentifier("main.tabview")
    }
}
