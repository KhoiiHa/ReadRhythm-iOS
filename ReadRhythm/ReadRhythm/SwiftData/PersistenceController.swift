//
//  PersistenceController.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 24.10.25.
//

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
            // Fallback: in-memory container so the app can launch instead of crashing.
            let models: [any PersistentModel.Type] = ReadRhythmSchemaV2.models
            let schema = Schema(models)
            let memoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            let fallback = try! ModelContainer(for: schema, configurations: memoryConfig)
            return fallback
        }
    }()
}
