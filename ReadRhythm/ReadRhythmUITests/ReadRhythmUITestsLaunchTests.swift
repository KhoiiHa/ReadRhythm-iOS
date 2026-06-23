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

        let tabs: [(identifier: String, fallbackLabels: [String])] = [
            ("tab.library", ["Bibliothek", "Library"]),
            ("tab.discover", ["Entdecken", "Discover"]),
            ("tab.stats", ["Statistiken", "Stats"]),
            ("tab.more", ["Mehr", "More"])
        ]

        for tab in tabs {
            let fallbackDescription = tab.fallbackLabels.joined(separator: ", ")
            var tabButton = tabBar.buttons.matching(identifier: tab.identifier).firstMatch
            if !tabButton.exists {
                for label in tab.fallbackLabels {
                    let localizedButton = tabBar.buttons[label]
                    if localizedButton.exists {
                        tabButton = localizedButton
                        break
                    }
                }
            }
            XCTAssertTrue(
                tabButton.waitForExistence(timeout: 6),
                "Expected tab \(tab.identifier) / \(fallbackDescription) to be present on launch"
            )
        }

        print("🚀 App launched successfully")

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
