// FocusBarWindowUITests.swift
// UI tests for FocusBarWindow appearance and basic properties

import XCTest

final class FocusBarWindowUITests: XCTestCase {
//    func testFocusBarWindowIsVisibleOnLaunch() {
//        let app = XCUIApplication()
//        app.launch()
//        // Look for the placeholder text in the bar
//        let focusBarText = app.staticTexts["Preview Focus Task"]
//        XCTAssertTrue(focusBarText.waitForExistence(timeout: 2), "Focus Bar should be visible with placeholder text on launch")
//    }

    func testNoMainWindowIsPresent() {
        let app = XCUIApplication()
        app.launch()
        // There should be only one window (the focus bar)
        XCTAssertEqual(app.windows.count, 1, "Only the Focus Bar window should be present on launch")
    }
}
