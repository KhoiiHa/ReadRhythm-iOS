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

        assertTabExists(in: tabBar, identifier: "tab.library", fallbackLabels: ["Bibliothek", "Library"])
        assertTabExists(in: tabBar, identifier: "tab.discover", fallbackLabels: ["Entdecken", "Discover"])
        assertTabExists(in: tabBar, identifier: "tab.stats", fallbackLabels: ["Statistiken", "Stats"])
        assertTabExists(in: tabBar, identifier: "tab.more", fallbackLabels: ["Mehr", "More"])
    }

    // MARK: - Focus Mode

    @MainActor
    func testFocusMode_StartsAndStopsTimer() throws {
        let app = launchApp()

        tapTab(app, identifier: "tab.goals", fallbackLabels: ["Ziele", "Goals"])

        let goalsScreen = element(in: app, identifier: "Goals.Screen")
        waitForExistence(of: goalsScreen)

        let focusLink = element(
            in: app,
            identifiers: ["Goals.FocusLink", "Goals.FocusLink.Label", "Lese-Fokus", "Reading Focus"]
        )
        waitForExistence(of: focusLink)
        focusLink.tap()

        let focusScreen = element(in: app, identifier: "Focus.Screen")
        waitForExistence(of: focusScreen)

        let startButton = element(in: app, identifiers: ["Focus.StartResume", "focus.startButton", "Start"])
        waitForExistence(of: startButton)

        let finishButton = element(in: app, identifiers: ["Focus.Finish", "Focus.Stop", "focus.stopButton", "Fertig", "Stop"])
        waitForExistence(of: finishButton)

        startButton.tap()
        waitForEnabledState(of: startButton, shouldBeEnabled: false)

        finishButton.tap()
        waitForEnabledState(of: startButton, shouldBeEnabled: true)

        navigateBack(app)
    }

    // MARK: - Audiobook Light

    @MainActor
    func testAudiobookLight_PlaysAndSavesSession() throws {
        let app = launchApp()

        let initialHistoryCount = historyRowCount(in: app)

        openProfileFromMore(in: app)

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

        tapTab(app, identifier: "tab.stats", fallbackLabels: ["Statistiken", "Stats"])

        let statsView = element(in: app, identifier: "stats.view")
        waitForExistence(of: statsView)

        let statsContent = element(in: app, matchingAnyIdentifier: ["stats.chart", "stats.emptyState"])
        waitForExistence(of: statsContent)

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

        openProfileFromMore(in: app)

        let metricsContainer = element(in: app, identifier: "Profile.Metrics")
        waitForExistence(of: metricsContainer)

        let insightsLink = app.buttons["Profile.InsightsLink"]
        waitForExistence(of: insightsLink)
        insightsLink.tap()

        let insightsScreen = element(in: app, identifier: "Insights.Screen")
        waitForExistence(of: insightsScreen)

        navigateBack(app)

        let historyLink = app.buttons["Profile.HistoryLink"]
        waitForExistence(of: historyLink)
        historyLink.tap()

        let historyScreen = element(in: app, identifier: "History.Root")
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
    private func tapTab(_ app: XCUIApplication, identifier: String, fallbackLabels: [String]) {
        let tabBar = app.tabBars.firstMatch
        waitForExistence(of: tabBar)

        var tabButton = tabBar.buttons.matching(identifier: identifier).firstMatch
        if !tabButton.isHittable {
            for label in fallbackLabels {
                let localizedButton = tabBar.buttons[label]
                if localizedButton.exists && localizedButton.isHittable {
                    tabButton = localizedButton
                    break
                }
            }
        }
        if !tabButton.exists {
            for label in fallbackLabels {
                let localizedButton = tabBar.buttons[label]
                if localizedButton.exists {
                    tabButton = localizedButton
                    break
                }
            }
        }
        waitForExistence(of: tabButton)
        tabButton.tap()
    }

    @MainActor
    private func openProfileFromMore(in app: XCUIApplication) {
        tapTab(app, identifier: "tab.more", fallbackLabels: ["Mehr", "More"])

        let moreView = element(in: app, identifier: "more.view")
        waitForExistence(of: moreView)

        if element(in: app, identifier: "Profile.Metrics").exists {
            return
        }

        let profileLink = button(in: app, identifiers: ["more.row.rr.tab.profile", "Profil", "Profile"])
        waitForExistence(of: profileLink)
        profileLink.tap()
    }

    @MainActor
    private func assertTabExists(in tabBar: XCUIElement, identifier: String, fallbackLabels: [String]) {
        var tabButton = tabBar.buttons.matching(identifier: identifier).firstMatch
        if !tabButton.exists {
            for label in fallbackLabels {
                let localizedButton = tabBar.buttons[label]
                if localizedButton.exists {
                    tabButton = localizedButton
                    break
                }
            }
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
        openProfileFromMore(in: app)

        let historyLink = app.buttons["Profile.HistoryLink"]
        waitForExistence(of: historyLink)
        historyLink.tap()

        let historyScreen = element(in: app, identifier: "History.Root")
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

    @MainActor
    private func element(in app: XCUIApplication, identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    @MainActor
    private func element(in app: XCUIApplication, identifiers: [String]) -> XCUIElement {
        for identifier in identifiers {
            let predicate = NSPredicate(
                format: "identifier == %@ OR label == %@",
                identifier,
                identifier
            )
            let match = app.descendants(matching: .any).matching(predicate).firstMatch
            if match.exists {
                return match
            }
        }
        return app.descendants(matching: .any).matching(identifier: identifiers.first ?? "").firstMatch
    }

    @MainActor
    private func element(in app: XCUIApplication, matchingAnyIdentifier identifiers: [String]) -> XCUIElement {
        let predicate = NSPredicate(format: "identifier IN %@", identifiers)
        return app.descendants(matching: .any).matching(predicate).firstMatch
    }
}
