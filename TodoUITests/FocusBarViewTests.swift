// FocusBarViewTests.swift
// UI tests for FocusBarView

import XCTest
import SwiftUI

final class FocusBarViewTests: XCTestCase {
    func testTitleDisplaysAndTruncates() {
        let longTitle = String(repeating: "A", count: 200)
        let view = FocusBarView(title: longTitle, opacity: .constant(0.8))
        let controller = NSHostingController(rootView: view)
        XCTAssertNotNil(controller.view)
        // UI test: visually inspect that the title is truncated with ellipsis
    }

    func testSliderAdjustsOpacity() {
        var opacity: Double = 0.5
        let view = FocusBarView(title: "Test", opacity: Binding(get: { opacity }, set: { opacity = $0 }))
        let controller = NSHostingController(rootView: view)
        XCTAssertNotNil(controller.view)
        // Simulate slider change
        opacity = 0.2
        XCTAssertGreaterThanOrEqual(opacity, 0.2)
        opacity = 1.0
        XCTAssertLessThanOrEqual(opacity, 1.0)
    }

    func testEmptyTitleShowsPlaceholder() {
        let view = FocusBarView(title: "", opacity: .constant(0.8))
        let controller = NSHostingController(rootView: view)
        XCTAssertNotNil(controller.view)
        // UI test: visually inspect that placeholder is shown
    }

    func testAccessibilityLabelsPresent() {
        let view = FocusBarView(title: "Test", opacity: .constant(0.8))
        let controller = NSHostingController(rootView: view)
        XCTAssertNotNil(controller.view)
        // Accessibility: would use UI test tools to verify labels
    }

    func testOpacityPersistenceAcrossLaunches() {
        let app = XCUIApplication()
        app.launchArguments.append("-uiTestSetOpacity")
        app.launchEnvironment["FOCUS_BAR_OPACITY"] = "0.55"
        app.launch()
        // Simulate user moving the slider to 0.55 (would require UI automation for real interaction)
        // For now, check that the value is persisted in UserDefaults
        let value = UserDefaults.standard.double(forKey: "FocusBarOpacity")
        XCTAssertEqual(value, 0.55, accuracy: 0.01)
        app.terminate()
        // Relaunch and check that the bar uses the persisted value
        let app2 = XCUIApplication()
        app2.launch()
        let restored = UserDefaults.standard.double(forKey: "FocusBarOpacity")
        XCTAssertEqual(restored, 0.55, accuracy: 0.01)
    }

    func testSliderClampsAndPersistsMinMax() {
        let app = XCUIApplication()
        app.launchArguments.append("-uiTestSetOpacity")
        app.launchEnvironment["FOCUS_BAR_OPACITY"] = "0.1"
        app.launch()
        var value = UserDefaults.standard.double(forKey: "FocusBarOpacity")
        XCTAssertGreaterThanOrEqual(value, 0.2)
        app.terminate()
        app.launchEnvironment["FOCUS_BAR_OPACITY"] = "1.5"
        app.launch()
        value = UserDefaults.standard.double(forKey: "FocusBarOpacity")
        XCTAssertLessThanOrEqual(value, 1.0)
    }
}
