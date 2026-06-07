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
