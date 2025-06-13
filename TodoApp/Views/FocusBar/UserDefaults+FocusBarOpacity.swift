// UserDefaults+FocusBarOpacity.swift
// Utility for reading/writing Focus Bar opacity to UserDefaults

import Foundation

struct FocusBarOpacitySettings {
    static let key = "FocusBarOpacity"
    static let defaultOpacity: Double = 1.0
    static let minOpacity: Double = 0
    static let maxOpacity: Double = 1.0

    /// Reads the opacity value from UserDefaults, clamping to allowed range. Returns default if missing or invalid.
    static func load() -> Double {
        let value = UserDefaults.standard.double(forKey: key)
        if value == 0 {
            // 0 means missing (UserDefaults returns 0 for unset Double)
            return defaultOpacity
        }
        return min(max(value, minOpacity), maxOpacity)
    }

    /// Saves the opacity value to UserDefaults, clamping to allowed range.
    static func save(_ value: Double) {
        let clamped = min(max(value, minOpacity), maxOpacity)
        UserDefaults.standard.set(clamped, forKey: key)
    }
}
