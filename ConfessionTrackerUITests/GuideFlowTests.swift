import XCTest

final class GuideFlowTests: UITestCase {
    func testEmptyGuideUsesPlaceholder() {
        launch(seed: "empty")
        app.tabBars.buttons["Guide"].tap()
        let line = "It has been [time] since my last confession."
        scrollUntil(containing: line)
        XCTAssertTrue(element(containing: "If this is your first confession, say: This is my first confession.").exists)
    }

    func testBlessMeUsesThreeDays() {
        launch(seed: "three")
        app.tabBars.buttons["Guide"].tap()
        let line = "Bless me, Father, for I have sinned. It has been 3 days since my last confession."
        scrollUntil(containing: line)
        let matches = app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS %@", line))
        XCTAssertGreaterThanOrEqual(matches.count, 1)
        XCTAssertEqual(matches.firstMatch.label.components(separatedBy: "It has been").count - 1, 1)
    }

    func testPriestLabelIsOnlyTheDialogue() {
        launch(seed: "empty")
        app.tabBars.buttons["Guide"].tap()
        XCTAssertTrue(app.staticTexts["Step 1: Before You Go In"].waitForExistence(timeout: 5))
        scrollUntil(containing: "Priest: Give thanks to the Lord, for he is good.")
        let priest = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Priest:'"))
        XCTAssertEqual(priest.count, 1)
        XCTAssertEqual(priest.firstMatch.label, "Priest: Give thanks to the Lord, for he is good.")
        scrollUntil(containing: "Step 10: After Confession")
    }

    func testActOfContritionMatchesPrayerTab() {
        launch(seed: "empty")
        let prayerTab = app.tabBars.buttons["Act of Contrition"].exists
            ? app.tabBars.buttons["Act of Contrition"]
            : app.tabBars.buttons["Prayer"]
        prayerTab.tap()
        let prayer = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'O my God, I am heartily sorry'")).firstMatch
        XCTAssertTrue(prayer.waitForExistence(timeout: 5))
        let prayerLabel = prayer.label
        app.tabBars.buttons["Guide"].tap()
        scrollUntil(containing: String(prayerLabel.prefix(40)))
    }

    private func element(containing text: String) -> XCUIElement {
        app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS %@", text)).firstMatch
    }

    private func scrollUntil(containing text: String) {
        let match = element(containing: text)
        var attempts = 0
        while !match.exists && attempts < 16 {
            app.swipeUp()
            attempts += 1
        }
        XCTAssertTrue(match.waitForExistence(timeout: 2), "Missing text: \(text)")
    }

    func testLogThisConfessionSavesOnlyOnSave() {
        launch(seed: "empty")
        app.tabBars.buttons["Guide"].tap()
        let log = app.buttons["Log This Confession"]
        XCTAssertTrue(log.waitForExistence(timeout: 5))
        log.tap()
        XCTAssertTrue(app.navigationBars["New Confession"].waitForExistence(timeout: 5))
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.tabBars.buttons["Guide"].waitForExistence(timeout: 3))
        app.tabBars.buttons["Confessions"].tap()
        XCTAssertEqual(entryCount(), 0)

        app.tabBars.buttons["Guide"].tap()
        app.buttons["Log This Confession"].tap()
        app.buttons["Save"].tap()
        app.tabBars.buttons["Confessions"].tap()
        XCTAssertEqual(entryCount(), 1)
    }
}
