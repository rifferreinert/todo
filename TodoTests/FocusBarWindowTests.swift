// FocusBarWindowTests.swift
// Unit and integration tests for FocusBarWindowController

import XCTest
@testable import Todo

class FocusBarWindowTests: XCTestCase {
    func testFocusBarWindowAppearsAtCorrectPositionAndLevel() {
        let controller = FocusBarWindowController.shared
        guard let window = controller.window else {
            XCTFail("FocusBarWindowController did not create a window")
            return
        }
        // The window should be visible
        XCTAssertTrue(window.isVisible, "Focus bar window should be visible")
        // The window should be at status bar level
        XCTAssertEqual(window.level, .statusBar, "Focus bar window should be at status bar level")
        // The window should span the width of the main display (with menu bar)
        let primaryScreen = NSScreen.screens.first { $0.frame.origin == .zero } ?? NSScreen.main
        XCTAssertEqual(window.frame.width, primaryScreen?.frame.width ?? 800, accuracy: 1.0, "Focus bar window should match main screen width")
        // The window should be just below the menu bar
        let menuBarHeight = NSStatusBar.system.thickness + 1
        let expectedY = (primaryScreen?.frame.maxY ?? 0) - menuBarHeight - window.frame.height
        XCTAssertEqual(window.frame.origin.y, expectedY, accuracy: 1.0, "Focus bar window should be just below the menu bar")
    }

    func testFocusBarWindowIsNonActivating() {
        let controller = FocusBarWindowController.shared
        guard let window = controller.window else {
            XCTFail("FocusBarWindowController did not create a window")
            return
        }
        // The window should not become key or main
        XCTAssertFalse(window.isKeyWindow, "Focus bar window should not be key window")
        XCTAssertFalse(window.isMainWindow, "Focus bar window should not be main window")
    }

    func testNoDuplicateFocusBarWindows() {
        let controller1 = FocusBarWindowController.shared
        let controller2 = FocusBarWindowController.shared
        XCTAssertTrue(controller1 === controller2, "FocusBarWindowController.shared should always return the same instance")
    }
}
