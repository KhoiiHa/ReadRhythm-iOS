import XCTest
@testable import ReadRhythm

@MainActor
final class AppFormatterTests: XCTestCase {
    func testHistoryRowText_WhenReading_ThenUsesReadingTemplate() {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 2024, month: 6, day: 18)
        let date = calendar.date(from: components)!

        let expectedDay = AppFormatter.weekdayFormatter.string(from: date)
        let expected = String(
            format: NSLocalizedString("history.row.reading", comment: ""),
            12,
            expectedDay
        )

        let result = AppFormatter.historyRowText(minutes: 12, medium: "reading", date: date)
        XCTAssertEqual(result, expected)
    }

    func testHistoryRowText_WhenListening_ThenUsesListeningTemplate() {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 2024, month: 6, day: 19)
        let date = calendar.date(from: components)!

        let expectedDay = AppFormatter.weekdayFormatter.string(from: date)
        let expected = String(
            format: NSLocalizedString("history.row.listening", comment: ""),
            20,
            expectedDay
        )

        let result = AppFormatter.historyRowText(minutes: 20, medium: "listening", date: date)
        XCTAssertEqual(result, expected)
    }

    func testHistoryAccessibilityLabel_WhenReading_ThenUsesShortDateTemplate() {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 2024, month: 6, day: 20)
        let date = calendar.date(from: components)!

        let formattedDate = AppFormatter.shortDateFormatter.string(from: date)
        let expected = String(
            format: NSLocalizedString("accessibility.history.reading", comment: ""),
            30,
            formattedDate
        )

        let result = AppFormatter.historyAccessibilityLabel(minutes: 30, medium: "reading", date: date)
        XCTAssertEqual(result, expected)
    }
}
