import XCTest

class UITestCase: XCTestCase {
    var app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @discardableResult
    func launch(seed: String = "empty", reset: Bool = true, extraArguments: [String] = []) -> XCUIApplication {
        app = XCUIApplication()
        app.launchArguments = [
            "-uiTesting",
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US",
        ]
        if reset {
            app.launchArguments.append("-resetState")
            app.launchArguments.append(contentsOf: ["-seed", seed])
        }
        app.launchArguments.append(contentsOf: extraArguments)
        app.launch()
        return app
    }

    func entryCount() -> Int {
        let element = app.descendants(matching: .any)["entryCount"]
        guard element.waitForExistence(timeout: 5) else { return -1 }
        let value = element.value as? String ?? ""
        return Int(value) ?? -1
    }

    func historyRows() -> XCUIElementQuery {
        app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'history.'"))
    }

    func openNewConfession() {
        let button = app.buttons["Log Confession Now"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        button.tap()
        XCTAssertTrue(app.navigationBars["New Confession"].waitForExistence(timeout: 5))
    }

    func penanceField() -> XCUIElement {
        let field = app.textFields["Penance received (optional)"]
        if field.exists { return field }
        let view = app.textViews["Penance received (optional)"]
        XCTAssertTrue(view.waitForExistence(timeout: 5))
        return view
    }

    func tapDialogButton(_ name: String, title: String) {
        let sheet = app.sheets[title]
        if sheet.waitForExistence(timeout: 2) {
            sheet.buttons[name].tap()
            return
        }
        let alert = app.alerts[title]
        XCTAssertTrue(alert.waitForExistence(timeout: 2))
        alert.buttons[name].tap()
    }

    func saveNewConfession() {
        app.buttons["Save"].tap()
        XCTAssertTrue(app.navigationBars["Confessions"].waitForExistence(timeout: 5))
    }

    /// Moves the compact date picker back by whole months, then taps the target day if it is visible.
    func shiftOpenDatePicker(monthsBack: Int, day: Int) {
        let picker = app.datePickers.firstMatch
        XCTAssertTrue(picker.waitForExistence(timeout: 3))
        picker.tap()
        for _ in 0..<monthsBack {
            let previous = previousMonthButton()
            XCTAssertTrue(previous.waitForExistence(timeout: 2))
            previous.tap()
        }
        let dayButton = app.buttons[String(day)].firstMatch
        if dayButton.exists {
            dayButton.tap()
        }
    }

    private func previousMonthButton() -> XCUIElement {
        let labels = ["Previous Month", "Previous month", "Go to previous month"]
        for label in labels {
            let button = app.buttons[label]
            if button.exists { return button }
        }
        return app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'previous'")).firstMatch
    }
}
