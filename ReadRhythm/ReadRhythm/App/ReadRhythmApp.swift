import SwiftUI
import SwiftData

enum AppAppearance: String, CaseIterable {
    case system, light, dark
}

/// Gemeinsamer SwiftData-Einstieg für die App.
/// Wir nutzen ab jetzt einen einzigen persistenten Container (`PersistenceController.shared`)
/// der ALLE @Model-Typen kennt (BookEntity, ReadingSessionEntity, ReadingGoalEntity, DiscoverFeedItem usw.).
/// Dadurch teilen sich Discover (Speichern aus API) und Library (Anzeige via @Query)
/// denselben Store und wir vermeiden den "no such table: ZBOOKENTITY"-Crash.
@main
struct ReadRhythmApp: App {

    @StateObject private var settings = AppSettingsService.shared
    @AppStorage("themeMode") private var themeRaw: String = AppThemeMode.system.rawValue
    private var resolvedAppearance: AppAppearance {
        (AppThemeMode(rawValue: themeRaw) ?? .system).asAppearance
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(settings)
                .applyPreferredColorScheme(resolvedAppearance)
        }
        // WICHTIG:
        // Statt einen eigenen Container lokal zu bauen (makeSafeContainer / default.store-Recovery)
        // hängen wir hier die zentrale PersistenceController.shared an.
        // -> Alle Screens & Repositories laufen auf demselben ModelContainer.
        .modelContainer(PersistenceController.shared)
    }
}

private extension View {
    @ViewBuilder
    func applyPreferredColorScheme(_ appearance: AppAppearance) -> some View {
        switch appearance {
        case .system:
            self
        case .light:
            self.preferredColorScheme(.light)
        case .dark:
            self.preferredColorScheme(.dark)
        }
    }
}
