import SwiftData
import Foundation
@testable import ReadRhythm

enum TestModelContainer {
    @MainActor
    static func makeInMemory() throws -> ModelContainer {
        let models: [any PersistentModel.Type] = ReadRhythmSchemaV2.models
        let schema = Schema(models)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: schema,
            migrationPlan: ReadRhythmMigrationPlan.self,
            configurations: configuration
        )
    }
}
