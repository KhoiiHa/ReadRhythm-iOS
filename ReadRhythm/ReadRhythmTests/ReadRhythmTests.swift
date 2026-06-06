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
}
