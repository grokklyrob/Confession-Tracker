import XCTest

final class PrayerFlowTests: UITestCase {
    private var prayerText: XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'O my God, I am heartily sorry'")).firstMatch
    }

    func testPrayerShowsActAndSource() {
        launch(seed: "empty")
        openPrayerTab()
        XCTAssertTrue(prayerText.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Traditional; public domain."].exists)
        XCTAssertFalse(app.staticTexts["Step 1: Before You Go In"].exists)
        prayerText.press(forDuration: 1.0)
        XCTAssertTrue(app.menuItems["Copy"].waitForExistence(timeout: 3))
    }

    func testTextSizeIsSharedAndPersists() {
        launch(seed: "empty")
        openPrayerTab()
        let before = prayerText.frame.height
        openGuideTab()
        chooseTextSize("Extra Large")
        openPrayerTab()
        let after = prayerText.frame.height
        XCTAssertGreaterThan(after, before)
        openTextSizeMenu()
        XCTAssertTrue(app.buttons["Extra Large"].isSelected)
        app.terminate()
        launch(reset: false)
        openGuideTab()
        openTextSizeMenu()
        XCTAssertTrue(app.buttons["Extra Large"].isSelected)
        openPrayerTab()
        openTextSizeMenu()
        XCTAssertTrue(app.buttons["Extra Large"].isSelected)
    }

    private func openPrayerTab() {
        let tab = app.tabBars.buttons["Act of Contrition"].exists
            ? app.tabBars.buttons["Act of Contrition"]
            : app.tabBars.buttons["Prayer"]
        tab.tap()
    }

    private func openGuideTab() {
        app.tabBars.buttons["Guide"].tap()
    }

    private func openTextSizeMenu() {
        app.buttons["Text Size"].tap()
    }

    private func chooseTextSize(_ name: String) {
        openTextSizeMenu()
        app.buttons[name].tap()
    }
}
