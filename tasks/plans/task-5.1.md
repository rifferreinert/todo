**Sub-task ID**: 5.1
**Sub-task Description**: Create `FocusBarWindow` using `NSWindow.Level.statusBar`.

## Problem Statement and Goal

The app must display an always-on-top bar at the top of the screen, visible across all virtual desktops, showing the current focus task. This requires a custom window that uses `NSWindow.Level.statusBar` (or higher) to ensure the bar stays above all other windows, is non-activating, and is visually unobtrusive per the PRD. The implementation should use SwiftUI for the UI as much as possible, only dropping to AppKit for window-level configuration.

## Relevant Files
- `TodoApp/Views/FocusBar/FocusBarWindow.swift` – Implements the always-on-top window logic, bridging SwiftUI and AppKit.
- `TodoApp/Views/FocusBar/FocusBarView.swift` – SwiftUI view for the bar UI (to be implemented in a later sub-task).
- `TodoApp.swift` – App entry point; will be updated to launch the FocusBarWindow at startup if needed.

## Inputs & Outputs
- **Inputs:**
  - The current focus task (title, possibly notes, but for this sub-task, just the title).
  - Window configuration parameters (height, width, level, appearance).
- **Outputs:**
  - A visible, always-on-top window at the top of the screen, spanning the full width, with fixed height (≤ 28 pt).

## Sub-task Technical Approach
- Use SwiftUI for the bar's content and layout, keeping all UI logic in SwiftUI.
- Create a `FocusBarWindow` type that bridges SwiftUI and AppKit:
  - Use an `NSWindow` subclass or wrapper to set the window level to `.statusBar`.
  - Use `NSHostingController` to embed the SwiftUI view in the window's contentView.
  - Configure the window to:
    - Anchor to the top of the main screen, spanning its width.
    - Set fixed height (≤ 28 pt) and disable resizing.
    - Make window non-activating (does not steal focus when clicked).
    - Use `.ultraThinMaterial` for background (per PRD, 80% opacity default).
    - Ensure window is visible on all virtual desktops (Spaces).
- Expose a method to update the displayed task title.
- Add comments explaining key decisions, especially around window level and activation policy.
- Keep all business logic and state in SwiftUI view models; the AppKit layer should only handle window configuration.

## Libraries / Imports
- `SwiftUI` (for UI and view models)
- `AppKit` (for NSWindow, NSScreen, NSHostingController)

## Edge-Cases and Error Handling
- Handle multi-monitor setups: for this sub-task, default to main display only (see PRD open questions).
- If window creation fails, log error and fail gracefully (do not crash app).
- If window is already present, avoid creating duplicates.

## Testing Strategy & Acceptance Criteria
- **Unit/Integration Tests:**
  - Test window appears at correct position and level.
  - Test window does not steal focus.
  - Test window is visible on all Spaces (if possible to automate).
- **Manual Testing:**
  - Build and run app; verify bar appears at top, above all windows, and does not interfere with normal app usage.
  - Check that window does not appear on secondary monitors (for now).
- **Acceptance Criteria:**
  - Focus bar window appears at top of main screen, always on top, with correct size and appearance.
  - Window does not interfere with user input/focus for other apps.
  - No crashes or duplicate windows on repeated launches.

---

### SwiftUI-First, AppKit-Only-When-Necessary Implementation Notes
- **UI:** All UI (task title, background, layout) should be implemented in SwiftUI (`FocusBarView`).
- **Window Management:** Use a minimal AppKit wrapper (`FocusBarWindow`) to:
  - Create an `NSWindow` with `.statusBar` level.
  - Embed a `NSHostingController` with the SwiftUI view.
  - Set window style to borderless, non-activating, and transparent.
  - Set collection behavior to `.canJoinAllSpaces` for visibility across virtual desktops.
- **Idiomatic Swift:**
  - Keep window logic in a dedicated type (e.g., `FocusBarWindowController`).
  - Use dependency injection to provide the SwiftUI view model to the bar.
  - Avoid putting business logic in AppKit layer; keep it in SwiftUI.
- **Why this approach:**
  - Maximizes SwiftUI usage for maintainability and testability.
  - AppKit is only used for window configuration that SwiftUI cannot handle (level, activation, Spaces).
  - This pattern is recommended by Apple for custom always-on-top overlays in SwiftUI apps.
