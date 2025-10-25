//
//  AppCoordinator.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 15.10.25.
//

import SwiftUI

/// Verantwortlich für die Initialisierung der Hauptfeatures
/// und Navigation zwischen Screens. Noch minimal, aber
/// zeigt geplante Erweiterbarkeit im App-Flow.
@MainActor
final class AppCoordinator: ObservableObject {

    // Beispiel: Einstiegspunkt für Feature-Start
    @Published var selectedTab: Tab = .library

    enum Tab {
        case library, discover, stats, goals, profile
    }

    func open(_ tab: Tab) {
        selectedTab = tab
        #if DEBUG
        print("[AppCoordinator] switched to tab:", tab)
        #endif
    }
}
