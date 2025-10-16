import SwiftUI
import SwiftData

@main
struct ReadRhythmApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [BookEntity.self, ReadingSessionEntity.self])
    }
}


