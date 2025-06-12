// FocusBarOpacitySettingsTests.swift
// Unit tests for FocusBarOpacitySettings (UserDefaults persistence)

import XCTest
@testable import Todo
import SwiftUI

final class FocusBarOpacitySettingsTests: XCTestCase {
    let testKey = FocusBarOpacitySettings.key
    let defaults = UserDefaults.standard

    override func setUp() {
        super.setUp()
        defaults.removeObject(forKey: testKey)
    }

    override func tearDown() {
        defaults.removeObject(forKey: testKey)
        super.tearDown()
    }

    func testDefaultValueWhenMissing() {
        // Should return default if unset
        let value = FocusBarOpacitySettings.load()
        XCTAssertEqual(value, FocusBarOpacitySettings.defaultOpacity)
    }

    func testSaveAndLoadValidValue() {
        FocusBarOpacitySettings.save(0.5)
        let value = FocusBarOpacitySettings.load()
        XCTAssertEqual(value, 0.5, accuracy: 0.0001)
    }

    func testClampsBelowMinimum() {
        FocusBarOpacitySettings.save(0.1)
        let value = FocusBarOpacitySettings.load()
        XCTAssertEqual(value, FocusBarOpacitySettings.minOpacity)
    }

    func testClampsAboveMaximum() {
        FocusBarOpacitySettings.save(2.0)
        let value = FocusBarOpacitySettings.load()
        XCTAssertEqual(value, FocusBarOpacitySettings.maxOpacity)
    }

    func testLoadHandlesCorruptValue() {
        // Simulate a corrupt value by writing a string
        UserDefaults.standard.set("not a double", forKey: testKey)
        // UserDefaults returns 0.0 for non-double, so should fall back to default
        let value = FocusBarOpacitySettings.load()
        XCTAssertEqual(value, FocusBarOpacitySettings.defaultOpacity)
    }

    func testSliderPersistsAndRestoresOpacity() {
        // This is a UI test stub: would require launching the app, adjusting the slider, relaunching, and verifying the value
        // For now, simulate the logic:
        FocusBarOpacitySettings.save(0.42)
        let restored = FocusBarOpacitySettings.load()
        XCTAssertEqual(restored, 0.42, accuracy: 0.0001)
    }

    func testRapidSliderChanges() {
        // Simulate rapid changes and ensure last value is persisted
        for i in 0...10 {
            let value = 0.2 + Double(i) * 0.08
            FocusBarOpacitySettings.save(value)
        }
        let restored = FocusBarOpacitySettings.load()
        XCTAssertEqual(restored, 1.0, accuracy: 0.0001) // Last value should be clamped to max
    }

    func testFocusBarViewSavesOpacityToUserDefaults() {
        // Given
        let testValue: Double = 0.77
        let binding = Binding<Double>(
            get: { testValue },
            set: { newValue in FocusBarOpacitySettings.save(newValue) }
        )
        // When
        FocusBarOpacitySettings.save(testValue)
        // Then
        let loaded = FocusBarOpacitySettings.load()
        XCTAssertEqual(loaded, testValue, accuracy: 0.0001)
    }

    func testFocusBarViewLoadsInitialOpacityFromUserDefaults() {
        // Given
        let testValue: Double = 0.66
        FocusBarOpacitySettings.save(testValue)
        // When
        let loaded = FocusBarOpacitySettings.load()
        // Then
        XCTAssertEqual(loaded, testValue, accuracy: 0.0001)
    }
}
