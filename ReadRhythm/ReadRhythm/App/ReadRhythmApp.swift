import SwiftUI
import SwiftData

@main
struct ReadRhythmApp: App {
    
    @StateObject private var settings = AppSettingsService.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(settings)
        }
        .modelContainer(for: [BookEntity.self, ReadingSessionEntity.self])
    }
}
