import XCTest
import SwiftData
@testable import ReadRhythm

@MainActor
final class LocalSessionRepositoryTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!
    private var repository: LocalSessionRepository!

    override func setUpWithError() throws {
        container = try TestModelContainer.makeInMemory()
        context = ModelContext(container)
        repository = LocalSessionRepository(context: context)
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
        repository = nil
    }

    func testSaveSession_WhenMinutesPositive_ThenPersistsEntity() throws {
        let saved = try repository.saveSession(
            book: nil,
            minutes: 25,
            date: Date(),
            medium: "reading"
        )

        let descriptor = FetchDescriptor<ReadingSessionEntity>()
        let fetched = try context.fetch(descriptor)

        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.id, saved.id)
        XCTAssertEqual(fetched.first?.minutes, 25)
    }

    func testSaveSession_WhenSamePayloadTwice_ThenProducesUniqueIdentifiers() throws {
        let first = try repository.saveSession(book: nil, minutes: 10, date: Date(), medium: "reading")
        let second = try repository.saveSession(book: nil, minutes: 10, date: Date(), medium: "reading")

        XCTAssertNotEqual(first.id, second.id)

        let descriptor = FetchDescriptor<ReadingSessionEntity>()
        let fetched = try context.fetch(descriptor)
        XCTAssertEqual(Set(fetched.map(\.id)).count, 2)
    }

    func testSaveSession_WhenDuplicateIdentifierInserted_ThenContextRejects() throws {
        let first = try repository.saveSession(book: nil, minutes: 12, date: Date(), medium: "reading")

        let duplicate = ReadingSessionEntity(
            id: first.id,
            date: Date(),
            minutes: 20,
            book: nil,
            medium: "reading"
        )

        let descriptor = FetchDescriptor<ReadingSessionEntity>()
        let countBefore = try context.fetch(descriptor).count

        context.insert(duplicate)
        _ = try? context.save()

        let countAfter = try context.fetch(descriptor).count
        XCTAssertEqual(countAfter, countBefore)
    }

    func testDeleteSession_WhenCalled_RemovesEntityFromStore() throws {
        let session = try repository.saveSession(book: nil, minutes: 18, date: Date(), medium: "reading")

        try repository.deleteSession(session)

        let descriptor = FetchDescriptor<ReadingSessionEntity>()
        let fetched = try context.fetch(descriptor)
        XCTAssertTrue(fetched.isEmpty)
    }
}
