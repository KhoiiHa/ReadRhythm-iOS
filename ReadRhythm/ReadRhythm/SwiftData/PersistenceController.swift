// MARK: - Persistence Controller / Persistenz-Kontroller
// Kapselt den SwiftData ModelContainer für die gesamte App /
// Encapsulates the SwiftData model container for the entire app.

import SwiftData

@MainActor
enum PersistenceController {
    static let shared: ModelContainer = {
        do {
            let models: [any PersistentModel.Type] = ReadRhythmSchemaV2.models
            let schema = Schema(models)
            let config = ModelConfiguration(schema: schema)
            return try ModelContainer(
                for: schema,
                migrationPlan: ReadRhythmMigrationPlan.self,
                configurations: config
            )
        } catch {
            #if DEBUG
            print("[ReadRhythm][SwiftData] ❌ Failed to create persistent ModelContainer: \(error)")
            print("[ReadRhythm][SwiftData] → Falling back to IN-MEMORY container (no persistence).")
            #endif
            // Fallback: in-memory container, damit die App launchen kann /
            // Fallback: use an in-memory container so the app can still launch.
            let models: [any PersistentModel.Type] = ReadRhythmSchemaV2.models
            let schema = Schema(models)
            let memoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            let fallback = try! ModelContainer(for: schema, configurations: memoryConfig) // try! bewusst, da Test-only / intentional for test-only fallback
            return fallback
        }
    }()
}
