import Foundation
import SwiftData

/// Erstes Persistenzschema (App Version 1): Minimaler Satz an Buchmetadaten.
enum ReadRhythmSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            BookEntity.self,
            ReadingSessionEntity.self,
            DiscoverFeedItem.self,
            ReadingGoalEntity.self
        ]
    }

    @Model
    final class BookEntity {
        @Attribute(.unique) var sourceID: String
        var title: String
        var author: String
        var thumbnailURL: String?
        var source: String
        var dateAdded: Date

        init(
            sourceID: String,
            title: String,
            author: String,
            thumbnailURL: String?,
            source: String,
            dateAdded: Date = .now
        ) {
            self.sourceID = sourceID
            self.title = title
            self.author = author
            self.thumbnailURL = thumbnailURL
            self.source = source
            self.dateAdded = dateAdded
        }
    }

    @Model
    final class ReadingSessionEntity {
        @Attribute(.unique) var id: UUID
        var date: Date
        var minutes: Int
        var medium: String
        @Relationship(deleteRule: .cascade) var book: BookEntity?

        init(
            id: UUID = UUID(),
            date: Date,
            minutes: Int,
            book: BookEntity?,
            medium: String = "reading"
        ) {
            self.id = id
            self.date = date
            self.minutes = minutes
            self.book = book
            self.medium = medium
        }
    }
}

/// Zweite Schema-Version: erweitert BookEntity um reichhaltige Metadaten.
enum ReadRhythmSchemaV2: VersionedSchema {
    static let versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            BookEntity.self,
            ReadingSessionEntity.self,
            DiscoverFeedItem.self,
            ReadingGoalEntity.self
        ]
    }
}

/// Migrationsplan von V1 → V2. Wir erweitern BookEntity nur um optionale Felder,
/// daher genügt eine Lightweight-Migration.
enum ReadRhythmMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [ReadRhythmSchemaV1.self, ReadRhythmSchemaV2.self]
    }

    static var migrationStages: [MigrationStage] {
        [
            .lightweight(
                fromVersion: ReadRhythmSchemaV1.self,
                toVersion: ReadRhythmSchemaV2.self
            )
        ]
    }
}
