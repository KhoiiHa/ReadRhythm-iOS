import XCTest

final class ReadRhythmUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Tab Bar

    @MainActor
    func testTabBar_DisplaysCoreTabs() throws {
        let app = launchApp()
        let tabBar = app.tabBars.firstMatch
        waitForExistence(of: tabBar)

        assertTabExists(in: tabBar, identifier: "tab.library", fallbackLabel: "Bibliothek")
        assertTabExists(in: tabBar, identifier: "tab.discover", fallbackLabel: "Entdecken")
        assertTabExists(in: tabBar, identifier: "tab.stats", fallbackLabel: "Statistiken")
        assertTabExists(in: tabBar, identifier: "tab.profile", fallbackLabel: "Profil")
    }

    // MARK: - Focus Mode

    @MainActor
    func testFocusMode_StartsAndStopsTimer() throws {
        let app = launchApp()

        let initialHistoryCount = historyRowCount(in: app)

        tapTab(app, identifier: "tab.goals", fallbackLabel: "Ziele")

        let focusLink = app.buttons["Goals.FocusLink"]
        waitForExistence(of: focusLink)
        focusLink.tap()

        let focusScreen = app.otherElements["Focus.Screen"]
        waitForExistence(of: focusScreen)

        // Select the first available book so the session can be persisted.
        let bookPicker = app.buttons["Focus.BookPicker"]
        waitForExistence(of: bookPicker)
        bookPicker.tap()

        let pickerSheet = app.sheets.firstMatch
        waitForExistence(of: pickerSheet)

        let bookPredicate = NSPredicate(format: "identifier BEGINSWITH %@", "Focus.BookPicker.Row.")
        let bookQuery = pickerSheet.descendants(matching: .any).matching(bookPredicate)
        var bookRow = bookQuery.firstMatch
        if bookQuery.count == 0 {
            bookRow = pickerSheet.tables.cells.firstMatch
        }
        waitForExistence(of: bookRow)
        bookRow.tap()
        waitForDisappearance(of: pickerSheet)

        let startButton = button(in: app, identifiers: ["Focus.StartResume", "focus.startButton"])
        waitForExistence(of: startButton)

        let finishButton = button(in: app, identifiers: ["Focus.Finish", "Focus.Stop", "focus.stopButton"])
        waitForExistence(of: finishButton)

        startButton.tap()
        waitForEnabledState(of: startButton, shouldBeEnabled: false)

        finishButton.tap()
        waitForEnabledState(of: startButton, shouldBeEnabled: true)

        navigateBack(app)

        let updatedHistoryCount = historyRowCount(in: app)
        XCTAssertGreaterThan(updatedHistoryCount, initialHistoryCount)
    }

    // MARK: - Audiobook Light

    @MainActor
    func testAudiobookLight_PlaysAndSavesSession() throws {
        let app = launchApp()

        let initialHistoryCount = historyRowCount(in: app)

        tapTab(app, identifier: "tab.profile", fallbackLabel: "Profil")

        let audiobookLink = app.buttons["Profile.AudiobookLightLink"]
        waitForExistence(of: audiobookLink)
        audiobookLink.tap()

        let textEditor = app.textViews["Audio.TextEditor"]
        waitForExistence(of: textEditor)
        textEditor.tap()
        textEditor.typeText("Dies ist ein kurzer Testtext.")

        let playButton = button(in: app, identifiers: ["Audio.Play", "audio.playButton"])
        waitForExistence(of: playButton)

        let stopButton = button(in: app, identifiers: ["Audio.Stop", "audio.stopButton"])
        waitForExistence(of: stopButton)
        playButton.tap()
        waitForEnabledState(of: stopButton, shouldBeEnabled: true)

        stopButton.tap()
        waitForEnabledState(of: stopButton, shouldBeEnabled: false)

        navigateBack(app)

        let updatedHistoryCount = historyRowCount(in: app)
        XCTAssertGreaterThan(updatedHistoryCount, initialHistoryCount)
    }

    // MARK: - Stats View

    @MainActor
    func testStatsView_ChartVisibleAndRangeSwitches() throws {
        let app = launchApp()

        tapTab(app, identifier: "tab.stats", fallbackLabel: "Statistiken")

        let statsView = app.otherElements["stats.view"]
        waitForExistence(of: statsView)

        let chart = app.otherElements["stats.chart"]
        waitForExistence(of: chart)

        let rangePicker = app.segmentedControls["stats.header.rangePicker"]
        if rangePicker.exists {
            for index in 0..<rangePicker.buttons.count {
                let button = rangePicker.buttons.element(boundBy: index)
                waitForExistence(of: button)
                button.tap()
            }
        } else {
            // Fallback: interact with the segmented control buttons directly if identifiers differ.
            let segmentedButtons = app.segmentedControls.firstMatch.buttons
            for index in 0..<segmentedButtons.count {
                let button = segmentedButtons.element(boundBy: index)
                waitForExistence(of: button)
                button.tap()
            }
        }
    }

    // MARK: - Profile View

    @MainActor
    func testProfileView_MetricsVisibleAndLinksNavigable() throws {
        let app = launchApp()

        tapTab(app, identifier: "tab.profile", fallbackLabel: "Profil")

        let metricsContainer = app.otherElements["Profile.Metrics"]
        waitForExistence(of: metricsContainer)

        let monthMinutes = app.otherElements["Profile.Metric.MonthMinutes"]
        let avgPerDay = app.otherElements["Profile.Metric.AvgPerDay"]
        waitForExistence(of: monthMinutes)
        waitForExistence(of: avgPerDay)

        let insightsLink = app.buttons["Profile.InsightsLink"]
        waitForExistence(of: insightsLink)
        insightsLink.tap()

        let insightsScreen = app.otherElements["Insights.Screen"]
        waitForExistence(of: insightsScreen)

        navigateBack(app)

        let historyLink = app.buttons["Profile.HistoryLink"]
        waitForExistence(of: historyLink)
        historyLink.tap()

        let historyScreen = app.otherElements["History.Root"]
        waitForExistence(of: historyScreen)

        navigateBack(app)
    }

    // MARK: - Helpers

    @MainActor
    @discardableResult
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        return app
    }

    @MainActor
    private func waitForExistence(of element: XCUIElement, timeout: TimeInterval = 6) {
        let predicate = NSPredicate(format: "exists == true")
        let expectation = expectation(for: predicate, evaluatedWith: element)
        wait(for: [expectation], timeout: timeout)
    }

    @MainActor
    private func waitForDisappearance(of element: XCUIElement, timeout: TimeInterval = 6) {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = expectation(for: predicate, evaluatedWith: element)
        wait(for: [expectation], timeout: timeout)
    }

    @MainActor
    private func waitForEnabledState(of element: XCUIElement, shouldBeEnabled: Bool, timeout: TimeInterval = 6) {
        let predicate = NSPredicate(format: "isEnabled == %@", NSNumber(value: shouldBeEnabled))
        let expectation = expectation(for: predicate, evaluatedWith: element)
        wait(for: [expectation], timeout: timeout)
    }

    @MainActor
    private func tapTab(_ app: XCUIApplication, identifier: String, fallbackLabel: String) {
        let tabBar = app.tabBars.firstMatch
        waitForExistence(of: tabBar)

        var tabButton = tabBar.buttons.matching(identifier: identifier).firstMatch
        if !tabButton.exists {
            tabButton = tabBar.buttons[fallbackLabel]
        }
        waitForExistence(of: tabButton)
        tabButton.tap()
    }

    @MainActor
    private func assertTabExists(in tabBar: XCUIElement, identifier: String, fallbackLabel: String) {
        var tabButton = tabBar.buttons.matching(identifier: identifier).firstMatch
        if !tabButton.exists {
            tabButton = tabBar.buttons[fallbackLabel]
        }
        waitForExistence(of: tabButton)
        XCTAssertTrue(tabButton.exists)
    }

    @MainActor
    private func navigateBack(_ app: XCUIApplication) {
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        waitForExistence(of: backButton)
        backButton.tap()
    }

    @MainActor
    private func historyRowCount(in app: XCUIApplication) -> Int {
        tapTab(app, identifier: "tab.profile", fallbackLabel: "Profil")

        let historyLink = app.buttons["Profile.HistoryLink"]
        waitForExistence(of: historyLink)
        historyLink.tap()

        let historyScreen = app.otherElements["History.Root"]
        waitForExistence(of: historyScreen)

        let predicate = NSPredicate(format: "identifier BEGINSWITH %@", "History.Row.")
        let rows = app.descendants(matching: .any).matching(predicate)
        let count = rows.count

        navigateBack(app)
        return count
    }

    @MainActor
    private func button(in app: XCUIApplication, identifiers: [String]) -> XCUIElement {
        let predicate = NSPredicate(format: "identifier IN %@", identifiers)
        let query = app.buttons.matching(predicate)
        let match = query.firstMatch
        if match.exists || query.count > 0 {
            return match
        }
        return app.buttons[identifiers.first ?? ""]
    }
}
