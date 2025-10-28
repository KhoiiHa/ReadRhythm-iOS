import XCTest
import SwiftData
@testable import ReadRhythm

@MainActor
final class StatsServiceTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!
    private var repository: LocalSessionRepository!
    private var calendar: Calendar!

    override func setUpWithError() throws {
        container = try TestModelContainer.makeInMemory()
        context = ModelContext(container)
        repository = LocalSessionRepository(context: context)
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
        repository = nil
        calendar = nil
    }

    func testFetchDailyStats_WhenMixedMedia_ThenReturnsSeparatedBuckets() throws {
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

        try repository.saveSession(book: nil, minutes: 30, date: twoDaysAgo, medium: "reading")
        try repository.saveSession(book: nil, minutes: 5, date: yesterday, medium: "reading")
        try repository.saveSession(book: nil, minutes: 10, date: yesterday, medium: "listening")
        try repository.saveSession(book: nil, minutes: 15, date: today, medium: "listening")

        let stats = StatsService.shared.fetchDailyStats(context: context, days: 3)

        XCTAssertEqual(stats.count, 3)

        let first = stats[0]
        XCTAssertTrue(calendar.isDate(first.date, inSameDayAs: twoDaysAgo))
        XCTAssertEqual(first.readingMinutes, 30)
        XCTAssertEqual(first.listeningMinutes, 0)

        let second = stats[1]
        XCTAssertTrue(calendar.isDate(second.date, inSameDayAs: yesterday))
        XCTAssertEqual(second.readingMinutes, 5)
        XCTAssertEqual(second.listeningMinutes, 10)

        let third = stats[2]
        XCTAssertTrue(calendar.isDate(third.date, inSameDayAs: today))
        XCTAssertEqual(third.readingMinutes, 0)
        XCTAssertEqual(third.listeningMinutes, 15)
    }

    func testTotalMinutes_WhenWindowProvided_ThenSumsOnlyInsideRange() throws {
        let today = calendar.startOfDay(for: Date())
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        try repository.saveSession(book: nil, minutes: 40, date: threeDaysAgo, medium: "reading")
        try repository.saveSession(book: nil, minutes: 25, date: twoDaysAgo, medium: "reading")
        try repository.saveSession(book: nil, minutes: 15, date: yesterday, medium: "listening")
        try repository.saveSession(book: nil, minutes: 20, date: today, medium: "reading")

        let totalForLastTwoDays = StatsService.shared.totalMinutes(context: context, days: 2)
        XCTAssertEqual(totalForLastTwoDays, 35)

        let totalAllTime = StatsService.shared.totalMinutes(context: context, days: nil)
        XCTAssertEqual(totalAllTime, 100)
    }
}
