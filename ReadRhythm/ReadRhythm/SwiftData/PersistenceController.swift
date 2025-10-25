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
            return try ModelContainer(
                for: BookEntity.self,
                    ReadingSessionEntity.self,
                    DiscoverFeedItem.self,
                    ReadingGoalEntity.self
            )
        } catch {
            fatalError("Failed to create shared ModelContainer: \(error.localizedDescription)")
        }
    }()
}
