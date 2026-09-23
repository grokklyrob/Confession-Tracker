import XCTest

final class SettingsFlowTests: UITestCase {
    func testDeleteAllRequiresTwoConfirmations() {
        launch(seed: "three")
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
        app.buttons["Delete All Confessions"].tap()
        tapDialogButton("Cancel", title: "Delete all confessions?")
        app.buttons["Done"].tap()
        XCTAssertEqual(entryCount(), 3)

        app.buttons["Settings"].tap()
        app.buttons["Delete All Confessions"].tap()
        tapDialogButton("Delete All", title: "Delete all confessions?")
        tapDialogButton("Cancel", title: "Are you sure?")
        app.buttons["Done"].tap()
        XCTAssertEqual(entryCount(), 3)

        app.buttons["Settings"].tap()
        app.buttons["Delete All Confessions"].tap()
        tapDialogButton("Delete All", title: "Delete all confessions?")
        tapDialogButton("Delete All", title: "Are you sure?")
        app.buttons["Done"].tap()
        XCTAssertEqual(entryCount(), 0)
        XCTAssertTrue(app.staticTexts["No confessions logged"].exists)
    }

    func testVersionRowMatchesBuildSettings() {
        launch(seed: "empty")
        app.buttons["Settings"].tap()
        let info = Bundle(for: SettingsFlowTests.self).infoDictionary
        let version = info?["ExpectedMarketingVersion"] as? String ?? ""
        let build = info?["ExpectedBuildNumber"] as? String ?? ""
        XCTAssertFalse(version.isEmpty)
        XCTAssertFalse(build.isEmpty)
        XCTAssertTrue(app.staticTexts["\(version) (\(build))"].waitForExistence(timeout: 5))
    }

    func testCorruptStoreKeepsPrayerAndGuideUsable() {
        launch(seed: "empty", extraArguments: ["-corruptStore"])
        XCTAssertTrue(app.staticTexts["Couldn't Open Your Data"].waitForExistence(timeout: 5))
        let prayerTab = app.tabBars.buttons["Act of Contrition"].exists
            ? app.tabBars.buttons["Act of Contrition"]
            : app.tabBars.buttons["Prayer"]
        prayerTab.tap()
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'O my God'")).firstMatch.waitForExistence(timeout: 5))
        app.tabBars.buttons["Guide"].tap()
        XCTAssertTrue(app.staticTexts["Bless me, Father, for I have sinned. It has been [time] since my last confession."].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Log This Confession"].exists)
    }
}
