import XCTest

final class ReadRhythmUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 4), "Expected tab bar to be present on launch")
        XCTAssertTrue(tabBar.exists)

        let libraryTab = tabBar.buttons.matching(identifier: "tab.library").firstMatch
        XCTAssertTrue(libraryTab.waitForExistence(timeout: 4), "Library tab should be visible on launch")
        XCTAssertTrue(libraryTab.exists)

        print("🚀 App launched successfully")

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
