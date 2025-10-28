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
        XCTAssertTrue(tabBar.waitForExistence(timeout: 6), "Expected tab bar to be present on launch")

        let tabs: [(identifier: String, fallbackLabel: String)] = [
            ("tab.library", "Bibliothek"),
            ("tab.discover", "Entdecken"),
            ("tab.stats", "Statistiken"),
            ("tab.profile", "Profil")
        ]

        for tab in tabs {
            var tabButton = tabBar.buttons.matching(identifier: tab.identifier).firstMatch
            if !tabButton.exists {
                tabButton = tabBar.buttons[tab.fallbackLabel]
            }
            XCTAssertTrue(
                tabButton.waitForExistence(timeout: 6),
                "Expected tab \(tab.identifier) / \(tab.fallbackLabel) to be present on launch"
            )
        }

        print("🚀 App launched successfully")

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
