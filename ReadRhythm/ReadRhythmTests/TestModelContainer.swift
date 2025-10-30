import SwiftData
import Foundation
@testable import ReadRhythm

enum TestModelContainer {
    @MainActor
    static func makeInMemory() throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: ReadRhythmSchemaV2.self,
            configurations: configuration,
            migrationPlan: ReadRhythmMigrationPlan.self
        )
    }
}
