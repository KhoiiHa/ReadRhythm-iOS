import XCTest
import SwiftData
@testable import ReadRhythm

@MainActor
final class ReadRhythmTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        container = try TestModelContainer.makeInMemory()
        context = ModelContext(container)
    }

    override func tearDownWithError() throws {
        context = nil
        container = nil
    }

    func testSaveGoal_WhenNoActiveGoal_ThenCreatesActiveGoal() throws {
        let viewModel = ReadingGoalsViewModel(context: context, statsService: .shared)

        let didSave = viewModel.saveGoal(targetMinutes: 45)

        XCTAssertTrue(didSave)
        XCTAssertEqual(viewModel.activeGoal?.targetMinutes, 45)
        XCTAssertEqual(viewModel.activeGoal?.period, .daily)
        XCTAssertFalse(viewModel.isEditing)

        let fetched = try context.fetch(ReadingGoalEntity.activeGoalFetchDescriptor)
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.targetMinutes, 45)
    }

    func testSaveGoal_WhenNoActiveGoalAndTargetTooLow_ThenClampsAndPersists() throws {
        let viewModel = ReadingGoalsViewModel(context: context, statsService: .shared)

        let didSave = viewModel.saveGoal(targetMinutes: 1, period: .weekly)

        XCTAssertTrue(didSave)
        XCTAssertEqual(viewModel.activeGoal?.targetMinutes, 5)
        XCTAssertEqual(viewModel.activeGoal?.period, .weekly)
    }

    func testGoalsProgress_WhenNoActiveGoalButSessionExists_ThenShowsActivityWithoutProgress() throws {
        let repository = LocalSessionRepository(context: context)
        try repository.saveSession(book: nil, minutes: 25, date: Date(), medium: "reading")

        let viewModel = ReadingGoalsViewModel(context: context, statsService: .shared)
        viewModel.calculateProgress()

        XCTAssertNil(viewModel.activeGoal)
        XCTAssertEqual(viewModel.totalMinutes, 25)
        XCTAssertEqual(viewModel.progress, 0)
        XCTAssertEqual(viewModel.streakCount, 1)
    }

    func testGoalsProgress_WhenDailyGoalExists_ThenUsesSavedSessionMinutes() throws {
        let repository = LocalSessionRepository(context: context)
        let viewModel = ReadingGoalsViewModel(context: context, statsService: .shared)

        XCTAssertTrue(viewModel.saveGoal(targetMinutes: 50, period: .daily))
        try repository.saveSession(book: nil, minutes: 25, date: Date(), medium: "reading")

        viewModel.calculateProgress()

        XCTAssertEqual(viewModel.totalMinutes, 25)
        XCTAssertEqual(viewModel.progress, 0.5, accuracy: 0.001)
        XCTAssertEqual(viewModel.streakCount, 1)
    }

    func testDiscoverSearch_WhenRepositoryInjected_ThenUsesInjectedResults() async throws {
        let remote = makeRemoteBook(id: "remote-1", title: "Injected Result")
        let searchRepository = StubBookSearchRepository(result: .success([remote]))
        let viewModel = DiscoverViewModel(
            repository: LocalBookRepository(context: context),
            bookSearchRepository: searchRepository
        )

        viewModel.searchQuery = "habits"
        viewModel.applySearch()

        try await waitUntil { viewModel.isLoading == false }

        XCTAssertEqual(searchRepository.receivedQueries, ["habits"])
        XCTAssertEqual(viewModel.results, [remote])
        XCTAssertNil(viewModel.errorMessage)
    }

    func testDiscoverSearch_WhenNewSearchStarts_ThenOlderResultDoesNotOverwrite() async throws {
        let oldRemote = makeRemoteBook(id: "old-result", title: "Old Result")
        let newRemote = makeRemoteBook(id: "new-result", title: "New Result")
        let searchRepository = DelayedBookSearchRepository(responses: [
            "old": .init(delayNanoseconds: 120_000_000, books: [oldRemote]),
            "new": .init(delayNanoseconds: 10_000_000, books: [newRemote])
        ])
        let viewModel = DiscoverViewModel(
            repository: LocalBookRepository(context: context),
            bookSearchRepository: searchRepository
        )

        viewModel.searchQuery = "old"
        viewModel.applySearch()
        try await waitUntil { searchRepository.receivedQueries.contains("old") }

        viewModel.searchQuery = "new"
        viewModel.applySearch()
        try await waitUntil { viewModel.results == [newRemote] }

        try await Task.sleep(nanoseconds: 150_000_000)

        XCTAssertEqual(searchRepository.receivedQueries, ["old", "new"])
        XCTAssertEqual(viewModel.results, [newRemote])
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testDiscoverSearch_WhenRepositoryThrows_ThenShowsGenericErrorAndClearsResults() async throws {
        let initialRemote = makeRemoteBook(id: "initial-result", title: "Initial Result")
        let searchRepository = StubBookSearchRepository(result: .failure(StubSearchError.failed))
        let viewModel = DiscoverViewModel(
            repository: LocalBookRepository(context: context),
            bookSearchRepository: searchRepository
        )
        viewModel.results = [initialRemote]

        viewModel.searchQuery = "broken"
        viewModel.applySearch()

        try await waitUntil { viewModel.isLoading == false }

        XCTAssertEqual(searchRepository.receivedQueries, ["broken"])
        XCTAssertTrue(viewModel.results.isEmpty)
        XCTAssertEqual(viewModel.errorMessage, "error.network.generic")
    }

    func testAddToLibrary_WhenSameRemoteBookAddedTwice_ThenSecondCallIsDuplicate() {
        let viewModel = DiscoverViewModel(repository: LocalBookRepository(context: context))
        let remote = makeRemoteBook(id: "remote-duplicate", title: "Duplicate Book")

        let firstResult = viewModel.addToLibrary(from: remote)
        let secondResult = viewModel.addToLibrary(from: remote)

        XCTAssertEqual(firstResult, .added)
        XCTAssertEqual(secondResult, .alreadyExists)
        XCTAssertEqual(viewModel.allBooks.count, 1)
        XCTAssertEqual(viewModel.toastText, "toast.duplicate")
    }

    func testBookDetailAddSession_WhenMinutesPositive_ThenPersistsLinkedSession() throws {
        let book = try makeLocalBook()
        let viewModel = BookDetailViewModel()
        let date = Date(timeIntervalSince1970: 1_800)

        viewModel.bind(context: context)
        let didSave = viewModel.addSession(for: book, minutes: 25, date: date)

        let sessions = try context.fetch(FetchDescriptor<ReadingSessionEntity>())
        XCTAssertTrue(didSave)
        XCTAssertEqual(sessions.count, 1)
        XCTAssertEqual(sessions.first?.book?.sourceID, book.sourceID)
        XCTAssertEqual(sessions.first?.minutes, 25)
        XCTAssertEqual(sessions.first?.medium, "reading")
        XCTAssertEqual(viewModel.toastMessageKey, "toast.sessionSaved")
        XCTAssertNil(viewModel.errorMessageKey)
    }

    func testBookDetailAddSession_WhenMinutesInvalid_ThenDoesNotPersist() throws {
        let book = try makeLocalBook()
        let viewModel = BookDetailViewModel()

        viewModel.bind(context: context)
        let didSave = viewModel.addSession(for: book, minutes: 0, date: Date())

        let sessions = try context.fetch(FetchDescriptor<ReadingSessionEntity>())
        XCTAssertFalse(didSave)
        XCTAssertTrue(sessions.isEmpty)
        XCTAssertNil(viewModel.toastMessageKey)
        XCTAssertNotNil(viewModel.errorMessageKey)
    }

    func testReadingHistory_WhenSessionsExist_ThenGroupsAndSortsByDate() throws {
        let repository = LocalSessionRepository(context: context)
        let book = try makeLocalBook()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayMorning = calendar.date(byAdding: .hour, value: 9, to: today)!
        let todayEvening = calendar.date(byAdding: .hour, value: 20, to: today)!
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        try repository.saveSession(book: book, minutes: 15, date: yesterday, medium: "reading")
        try repository.saveSession(book: book, minutes: 20, date: todayMorning, medium: "reading")
        try repository.saveSession(book: book, minutes: 30, date: todayEvening, medium: "listening")

        let viewModel = ReadingHistoryViewModel(context: context)
        let displaySections = viewModel.displaySections()

        XCTAssertEqual(displaySections.count, 2)
        XCTAssertTrue(calendar.isDate(displaySections[0].date, inSameDayAs: today))
        XCTAssertTrue(calendar.isDate(displaySections[1].date, inSameDayAs: yesterday))
        XCTAssertEqual(displaySections[0].rows.map(\.subtitleText), ["Detail Flow Book", "Detail Flow Book"])
        XCTAssertEqual(displaySections[0].rows.map(\.iconSystemName), ["headphones", "book"])
        XCTAssertEqual(displaySections[0].rows.map(\.id), viewModel.sections[0].items.map(\.id))
        XCTAssertEqual(displaySections[1].rows.first?.iconSystemName, "book")
    }

    func testStatsViewModel_WhenSessionSaved_ThenRefreshShowsAggregatedData() throws {
        let repository = LocalSessionRepository(context: context)
        let viewModel = StatsViewModel(
            sessionRepository: repository,
            statsService: .shared
        )

        XCTAssertFalse(viewModel.hasData())

        try repository.saveSession(book: nil, minutes: 25, date: Date(), medium: "reading")
        viewModel.refreshFromRepositoryContext(days: 7)

        XCTAssertTrue(viewModel.hasData())
        XCTAssertEqual(viewModel.totalMinutes, 25)
        XCTAssertEqual(viewModel.totalReadingMinutes, 25)
        XCTAssertEqual(viewModel.totalListeningMinutes, 0)
        XCTAssertEqual(viewModel.combinedTotalMinutes, 25)
        XCTAssertEqual(viewModel.currentStreak, 1)
    }

    func testStatsViewModel_WhenAllTimeSelected_ThenIncludesSessionsOutsideChartWindow() throws {
        let repository = LocalSessionRepository(context: context)
        let viewModel = StatsViewModel(
            sessionRepository: repository,
            statsService: .shared
        )
        let oldDate = Calendar.current.date(byAdding: .day, value: -180, to: Date())!

        try repository.saveSession(book: nil, minutes: 45, date: oldDate, medium: "reading")
        try repository.saveSession(book: nil, minutes: 20, date: Date(), medium: "listening")

        viewModel.refreshFromRepositoryContext(days: Int.max)

        XCTAssertTrue(viewModel.hasData())
        XCTAssertEqual(viewModel.totalMinutes, 65)
        XCTAssertEqual(viewModel.totalReadingMinutes, 45)
        XCTAssertEqual(viewModel.totalListeningMinutes, 20)
        XCTAssertEqual(viewModel.combinedTotalMinutes, 65)
    }

    private func makeRemoteBook(id: String, title: String) -> RemoteBook {
        RemoteBook(
            id: id,
            title: title,
            subtitle: nil,
            authors: ["Test Author"],
            publisher: nil,
            publishedDate: nil,
            pageCount: nil,
            language: nil,
            infoLink: nil,
            categories: [],
            description: nil,
            thumbnailURL: nil,
            previewLink: nil
        )
    }

    private func makeLocalBook() throws -> BookEntity {
        try LocalBookRepository(context: context).add(
            title: "Detail Flow Book",
            author: "Test Author",
            subtitle: nil,
            publisher: nil,
            publishedDate: nil,
            pageCount: nil,
            language: nil,
            categories: [],
            descriptionText: nil,
            thumbnailURL: nil,
            infoLink: nil,
            previewLink: nil,
            sourceID: UUID().uuidString,
            source: "Test"
        )
    }

    private func waitUntil(
        timeoutNanoseconds: UInt64 = 1_000_000_000,
        condition: @escaping @MainActor () -> Bool
    ) async throws {
        let stepNanoseconds: UInt64 = 10_000_000
        var waitedNanoseconds: UInt64 = 0

        while condition() == false {
            if waitedNanoseconds >= timeoutNanoseconds {
                XCTFail("Timed out waiting for condition")
                return
            }
            try await Task.sleep(nanoseconds: stepNanoseconds)
            waitedNanoseconds += stepNanoseconds
        }
    }
}

private enum StubSearchError: Error {
    case failed
}

@MainActor
private final class StubBookSearchRepository: BookSearchRepositoryProtocol {
    private let result: Result<[RemoteBook], Error>
    private(set) var receivedQueries: [String] = []

    init(result: Result<[RemoteBook], Error>) {
        self.result = result
    }

    func search(query: String?, category: DiscoverCategory?, maxResults: Int) async throws -> [RemoteBook] {
        receivedQueries.append(query ?? "")
        return try result.get()
    }
}

@MainActor
private final class DelayedBookSearchRepository: BookSearchRepositoryProtocol {
    struct Response {
        let delayNanoseconds: UInt64
        let books: [RemoteBook]
    }

    private let responses: [String: Response]
    private(set) var receivedQueries: [String] = []

    init(responses: [String: Response]) {
        self.responses = responses
    }

    func search(query: String?, category: DiscoverCategory?, maxResults: Int) async throws -> [RemoteBook] {
        let key = query ?? ""
        receivedQueries.append(key)

        let response = responses[key] ?? Response(delayNanoseconds: 0, books: [])
        try await Task.sleep(nanoseconds: response.delayNanoseconds)
        return response.books
    }
}
