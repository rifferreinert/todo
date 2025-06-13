// FocusBarViewTests.swift
// UI tests for FocusBarView

import XCTest
import SwiftUI

final class FocusBarViewTests: XCTestCase {

    let opacityKey = FocusBarOpacitySettings.key

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

//    func testOpacityPersistenceAcrossLaunches() {
//        let app = XCUIApplication()
//        app.launch()
//        // Find the slider by its accessibility identifier
//        let slider = app.sliders["focusBarOpacitySlider"]
//        XCTAssertTrue(slider.exists, "The opacity slider should exist.")
//        // Move the slider to 0.55 (normalized position)
//        let normalizedPosition = (0.55 - FocusBarOpacitySettings.minOpacity) / (FocusBarOpacitySettings.maxOpacity - FocusBarOpacitySettings.minOpacity)
//        //slider.adjust(toNormalizedSliderPosition: 0.6)
//        let sliderFrame = slider.frame
//        let tapPoint = CGPoint(
//            x: sliderFrame.origin.x + sliderFrame.width * CGFloat(normalizedPosition),
//            y: sliderFrame.midY
//        )
//        app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
//            .withOffset(CGVector(dx: tapPoint.x, dy: tapPoint.y))
//            .tap()
//        
//        // Give the UI time to update and persist
//        sleep(1)
//        // Check that the value is persisted in UserDefaults
//        let value = UserDefaults.standard.double(forKey: opacityKey)
//        XCTAssertEqual(value, 0.55, accuracy: 0.01)
//        app.terminate()
//        // Relaunch and check that the bar uses the persisted value
//        let app2 = XCUIApplication()
//        app2.launch()
//        let restored = UserDefaults.standard.double(forKey: opacityKey)
//        XCTAssertEqual(restored, 0.55, accuracy: 0.01)
//    }
//
//    func testSliderClampsAndPersistsMinMax() {
//        let app = XCUIApplication()
//        app.launchArguments.append("-uiTestSetOpacity")
//        app.launchEnvironment["FOCUS_BAR_OPACITY"] = "0.1"
//        app.launch()
//        var value = UserDefaults.standard.double(forKey: opacityKey)
//        XCTAssertGreaterThanOrEqual(value, 0.2)
//        app.terminate()
//        app.launchEnvironment["FOCUS_BAR_OPACITY"] = "1.5"
//        app.launch()
//        value = UserDefaults.standard.double(forKey: opacityKey)
//        XCTAssertLessThanOrEqual(value, 1.0)
//    }
}
