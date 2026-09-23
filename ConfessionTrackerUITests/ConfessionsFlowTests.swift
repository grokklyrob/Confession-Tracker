import XCTest

final class ConfessionsFlowTests: UITestCase {
    func testEmptyStateShowsCopyAndNoHistory() {
        launch(seed: "empty")
        XCTAssertTrue(app.staticTexts["No confessions logged"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Use Log Confession Now to record a confession."].exists)
        XCTAssertEqual(historyRows().count, 0)
        XCTAssertFalse(app.navigationBars["New Confession"].exists)
        XCTAssertEqual(entryCount(), 0)
        XCTAssertTrue(app.buttons["Settings"].exists)
        XCTAssertTrue(app.buttons["New Confession"].exists)
    }

    func testLogConfessionNowSavesOnlyOnSave() {
        launch(seed: "empty")
        openNewConfession()
        XCTAssertEqual(entryCount(), 0)
        saveNewConfession()
        XCTAssertEqual(entryCount(), 1)

        launch(seed: "empty")
        openNewConfession()
        app.buttons["Cancel"].tap()
        XCTAssertFalse(app.navigationBars["New Confession"].waitForExistence(timeout: 1))
        XCTAssertEqual(entryCount(), 0)
    }

    func testFixtureYearsAndIntervals() {
        launch(seed: "three")
        XCTAssertEqual(entryCount(), 3)
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let years = [3, 24, 400].map { offset -> Int in
            let date = calendar.date(byAdding: .day, value: -offset, to: now)!
            return calendar.component(.year, from: date)
        }
        var seen: [Int] = []
        for year in years where !seen.contains(year) {
            seen.append(year)
        }
        let expected = seen.sorted(by: >)
        for year in expected {
            XCTAssertTrue(app.staticTexts[String(year)].waitForExistence(timeout: 3))
        }
        XCTAssertTrue(app.staticTexts["3 weeks after previous"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["12 months after previous"].exists)
        let rows = historyRows()
        XCTAssertEqual(rows.count, 3)
        XCTAssertTrue(rows.element(boundBy: 0).label.contains("3 weeks after previous"))
        XCTAssertTrue(rows.element(boundBy: 1).label.contains("12 months after previous"))
        XCTAssertFalse(rows.element(boundBy: 2).label.contains("after previous"))
    }

    func testHistoryRowsAreNotTruncated() {
        launch(seed: "three")
        let row = historyRows().element(boundBy: 0)
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        XCTAssertFalse(row.label.contains("…"))
        XCTAssertTrue(row.label.contains("3 weeks after previous"))
        XCTAssertLessThanOrEqual(row.frame.maxX, app.windows.firstMatch.frame.maxX + 1)
    }

    func testAddSheetCancelDirtyAndSwipe() {
        launch(seed: "empty")
        openNewConfession()
        app.buttons["Cancel"].tap()
        XCTAssertFalse(app.sheets["Discard changes?"].exists)
        XCTAssertTrue(app.navigationBars["Confessions"].waitForExistence(timeout: 3))

        openNewConfession()
        let field = penanceField()
        field.tap()
        field.typeText("A rosary")
        app.buttons["Cancel"].tap()
        tapDialogButton("Discard Changes", title: "Discard changes?")
        XCTAssertEqual(entryCount(), 0)

        openNewConfession()
        penanceField().tap()
        penanceField().typeText("Still editing")
        let bar = app.navigationBars["New Confession"]
        let start = bar.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 1))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.95))
        start.press(forDuration: 0.05, thenDragTo: end)
        XCTAssertTrue(app.navigationBars["New Confession"].exists)
    }

    func testPenancePasteIsLimited() {
        launch(seed: "empty")
        openNewConfession()
        let pasted = String(repeating: "a", count: 2_500)
        UIPasteboard.general.string = pasted
        let field = penanceField()
        field.tap()
        field.press(forDuration: 1.1)
        if app.menuItems["Paste"].waitForExistence(timeout: 2) {
            app.menuItems["Paste"].tap()
        } else {
            field.typeKey("v", modifierFlags: .command)
        }
        XCTAssertTrue(app.staticTexts["2000 of 2,000 characters"].waitForExistence(timeout: 5))
        let value = (field.value as? String) ?? field.label
        XCTAssertEqual(value.count, 2_000)
        saveNewConfession()
        historyRows().element(boundBy: 0).tap()
        XCTAssertTrue(app.staticTexts[String(repeating: "a", count: 2_000)].waitForExistence(timeout: 5))
    }

    func testSwipeDeleteCancelAndConfirm() {
        launch(seed: "three")
        let row = historyRows().element(boundBy: 0)
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.swipeLeft()
        app.buttons["Delete"].tap()
        tapDialogButton("Cancel", title: "Delete this confession?")
        XCTAssertEqual(entryCount(), 3)

        historyRows().element(boundBy: 0).swipeLeft()
        app.buttons["Delete"].tap()
        tapDialogButton("Delete", title: "Delete this confession?")
        XCTAssertEqual(entryCount(), 2)
    }

    func testPersistenceAcrossRelaunch() {
        launch(seed: "empty")
        openNewConfession()
        penanceField().tap()
        penanceField().typeText("Kept")
        saveNewConfession()
        XCTAssertEqual(entryCount(), 1)
        app.terminate()
        launch(reset: false)
        XCTAssertEqual(entryCount(), 1)
        XCTAssertTrue(app.staticTexts["Kept"].waitForExistence(timeout: 5))
    }

    func testSameDayNoticeStillSaves() {
        launch(seed: "three")
        let before = entryCount()
        openNewConfession()
        shiftOpenDatePicker(monthsBack: 0, day: Calendar.current.component(.day, from: Date().addingTimeInterval(-3 * 86_400)))
        let notice = app.staticTexts["An entry already exists for this day."]
        if !notice.waitForExistence(timeout: 2) {
            shiftOpenDatePicker(monthsBack: 1, day: Calendar.current.component(.day, from: Date().addingTimeInterval(-3 * 86_400)))
        }
        XCTAssertTrue(app.staticTexts["An entry already exists for this day."].waitForExistence(timeout: 3))
        saveNewConfession()
        XCTAssertEqual(entryCount(), before + 1)
    }

    func testEditDateReordersList() {
        launch(seed: "three")
        historyRows().element(boundBy: 0).tap()
        app.buttons["Edit"].tap()
        XCTAssertTrue(app.navigationBars["Edit Confession"].waitForExistence(timeout: 5))
        shiftOpenDatePicker(monthsBack: 14, day: 1)
        app.buttons["Done"].tap()
        XCTAssertTrue(app.navigationBars["Confessions"].waitForExistence(timeout: 5) || app.buttons["Confessions"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.element(boundBy: 0).tap()
        let top = historyRows().element(boundBy: 0)
        XCTAssertTrue(top.waitForExistence(timeout: 5))
        XCTAssertFalse(top.label.contains("Three Hail Marys"))
    }

    func testDetailShowsValuesEditAndDelete() {
        launch(seed: "three")
        historyRows().element(boundBy: 0).tap()
        XCTAssertTrue(app.staticTexts["Date"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Time"].exists)
        XCTAssertTrue(app.staticTexts["Three Hail Marys"].exists)
        app.buttons["Edit"].tap()
        let field = penanceField()
        field.tap()
        field.typeText(" and a psalm")
        app.buttons["Done"].tap()
        XCTAssertTrue(app.staticTexts["Three Hail Marys and a psalm"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Delete Confession"].exists)
        app.buttons["Delete Confession"].tap()
        tapDialogButton("Delete", title: "Delete this confession?")
        XCTAssertTrue(app.navigationBars["Confessions"].waitForExistence(timeout: 5))
        XCTAssertEqual(entryCount(), 2)
    }

    func testRepeatedDetailDeleteDoesNotCrash() {
        launch(seed: "thousand")
        XCTAssertEqual(entryCount(), 1_000)
        for _ in 0..<20 {
            let row = historyRows().element(boundBy: 0)
            XCTAssertTrue(row.waitForExistence(timeout: 5))
            row.tap()
            app.buttons["Delete Confession"].tap()
            tapDialogButton("Delete", title: "Delete this confession?")
            XCTAssertTrue(app.buttons["Log Confession Now"].waitForExistence(timeout: 5))
        }
        XCTAssertEqual(entryCount(), 980)
    }

    func testDatePickerDefaultsNearNow() {
        launch(seed: "empty")
        let started = Date()
        openNewConfession()
        let picker = app.datePickers.firstMatch
        XCTAssertTrue(picker.waitForExistence(timeout: 3))
        let label = picker.label
        XCTAssertFalse(label.isEmpty)
        XCTAssertLessThan(Date().timeIntervalSince(started), 90)
    }
}
