import SwiftUI
import SwiftData

@main
struct ReadRhythmApp: App {
    var body: some Scene {
        WindowGroup {
            RootPlaceholderView()
        }
        .modelContainer(for: [BookEntity.self, ReadingSessionEntity.self])
    }
}

private struct RootPlaceholderView: View {
    var body: some View {
        Text("ReadRhythm startet 🎧📚")
            .padding()
    }
}
