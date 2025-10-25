import SwiftUI
import SwiftData

/// Gemeinsamer SwiftData-Einstieg für die App.
/// Wir nutzen ab jetzt einen einzigen persistenten Container (`PersistenceController.shared`)
/// der ALLE @Model-Typen kennt (BookEntity, ReadingSessionEntity, ReadingGoalEntity, DiscoverFeedItem usw.).
/// Dadurch teilen sich Discover (Speichern aus API) und Library (Anzeige via @Query)
/// denselben Store und wir vermeiden den "no such table: ZBOOKENTITY"-Crash.
@main
struct ReadRhythmApp: App {

    @StateObject private var settings = AppSettingsService.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(settings)
        }
        // WICHTIG:
        // Statt einen eigenen Container lokal zu bauen (makeSafeContainer / default.store-Recovery)
        // hängen wir hier die zentrale PersistenceController.shared an.
        // -> Alle Screens & Repositories laufen auf demselben ModelContainer.
        .modelContainer(PersistenceController.shared)
    }
}
