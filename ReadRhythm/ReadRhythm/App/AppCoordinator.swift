// MARK: - Navigations-Koordinator / Navigation Coordinator
// Lenkt Tab-Wechsel und bildet den Kern für spätere Flow-Logik /
// Directs tab changes and forms the basis for future flow logic.

import SwiftUI

/// Hält den zentralen Navigationszustand der App /
/// Holds the app's central navigation state.
@MainActor
final class AppCoordinator: ObservableObject {

    // Geteilter Tab-Zustand für das TabView / Shared tab state for the TabView
    @Published var selectedTab: Tab = .library

    enum Tab {
        case library, discover, stats, goals, profile
    }

    // Ermöglicht gezielte Navigation z. B. aus Deep Links /
    // Enables targeted navigation, e.g. from deep links
    func open(_ tab: Tab) {
        selectedTab = tab
        #if DEBUG
        print("[AppCoordinator] switched to tab:", tab)
        #endif
    }
}
