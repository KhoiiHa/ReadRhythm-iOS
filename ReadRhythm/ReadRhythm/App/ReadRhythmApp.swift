// MARK: - App-Einstiegspunkt / App Entry Point
// Kapselt das Scene-Setup und hängt den zentralen PersistenceController an /
// Encapsulates the scene setup and attaches the shared persistence controller.
import SwiftUI
import SwiftData

enum AppAppearance: String, CaseIterable {
    case system, light, dark
}

/// Zentraler SwiftData-Zugriffspunkt für alle Feature-Module /
/// Central SwiftData access point for all feature modules.
/// Ein einziger Container liefert konsistente Daten für Discover & Library /
/// A single container keeps Discover & Library in sync.
@main
struct ReadRhythmApp: App {

    // Verwaltet globale UI-Präferenzen / Manages global UI preferences
    @StateObject private var settings = AppSettingsService.shared
    @AppStorage("themeMode") private var themeRaw: String = AppThemeMode.system.rawValue
    // Übersetzt die gespeicherte Theme-Wahl in eine tatsächliche Appearance /
    // Translates the stored theme choice into an actual appearance option
    private var resolvedAppearance: AppAppearance {
        (AppThemeMode(rawValue: themeRaw) ?? .system).asAppearance
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(settings)
                .applyPreferredColorScheme(resolvedAppearance)
        }
        // Zentralisiert den ModelContainer für jede Szene /
        // Centralizes the model container for every scene instance.
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
