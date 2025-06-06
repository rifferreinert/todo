**Sub-task ID**: 5.3
**Sub-task Description**: Persist opacity in `UserDefaults`; restore on launch.

## Problem Statement and Goal
The Focus Bar's opacity can be adjusted by the user via a slider. Currently, this setting is not persisted, so the opacity resets to its default value each time the app launches. The goal is to store the user's selected opacity value in `UserDefaults` whenever it changes, and restore this value when the app launches, ensuring a consistent user experience.

## Relevant Files
- `TodoApp/Views/FocusBar/FocusBarView.swift` – SwiftUI view containing the opacity slider and logic for updating opacity.
- `TodoApp/Views/FocusBar/FocusBarWindow.swift` – Manages the NSWindow displaying the bar; may need to apply the restored opacity.

## Inputs & Outputs
- **Input:** User adjusts the opacity slider (value between 0.2 and 1.0).
- **Output:**
  - The new opacity value is saved to `UserDefaults` under a well-defined key (e.g., `FocusBarOpacity`).
  - On app launch, the opacity value is read from `UserDefaults` and applied to the Focus Bar. If no value is present, use the default (e.g., 0.8).

## Sub-task Technical Approach
1. Define a constant key for the opacity value in `UserDefaults`.
2. In `FocusBarView`, update the code so that whenever the slider changes, the new value is saved to `UserDefaults`.
3. On initialization of the Focus Bar (in `FocusBarWindow`), read the opacity value from `UserDefaults` and use it as the initial value for the slider and the bar's opacity.
4. Ensure the UI updates immediately when the value changes.
5. Validate that the value is within the allowed range (0.2–1.0) before applying.

## Libraries / Imports
- Foundation (`UserDefaults`)
- SwiftUI

## Edge-Cases and Error Handling
- If the value in `UserDefaults` is missing or out of range, fall back to the default (1.0).
- If saving to `UserDefaults` fails (rare), log an error but do not crash.
- Ensure that rapid slider changes do not cause performance issues (debounce if needed, but not required for this simple use case).

## Testing Strategy & Acceptance Criteria
- **Unit tests**: Test reading and writing the opacity value to `UserDefaults`, including edge cases (missing, out-of-range values).
- **UI tests**: Adjust the slider, relaunch the app, and verify that the opacity is restored.
- **Acceptance Criteria:**
  - Changing the slider updates the bar's opacity and persists the value.
  - Relaunching the app restores the last-used opacity.
  - Out-of-range or missing values revert to the default without crashing.
  - No regressions in Focus Bar functionality.
