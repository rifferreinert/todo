**Sub-task ID**: 5.2
**Sub-task Description**: Build `FocusBarView` with task title, opacity slider (20–100 %).

## Problem Statement and Goal
The FocusBarView is the always-on-top bar that displays the current focus task's title and provides an opacity slider (20–100%). The goal is to implement a SwiftUI view that:
- Shows the current focus task's title, truncating with ellipsis if too long.
- Includes a slider to adjust the bar's opacity between 20% and 100%.
- Ensures the UI is visually appealing, accessible, and responsive.

## Relevant Files
- `TodoApp/Views/FocusBar/FocusBarView.swift`: Implements the SwiftUI view for the focus bar.
- `TodoApp/ViewModels/TaskListViewModel.swift`: Supplies the current focus task's title.
- `TodoApp/Resources/Assets.xcassets`: May be updated for icons or color assets if needed.
- `TodoUITests/FocusBarViewTests.swift`: UI tests for the FocusBarView.

## Inputs & Outputs
- **Inputs:**
  - Current focus task (title as String, from ViewModel)
  - Current opacity value (Double, 0.2–1.0)
  - User interaction with the slider
- **Outputs:**
  - Updated opacity value (propagated to parent or persisted later)
  - UI updates reflecting the current task and opacity

## Sub-task Technical Approach
- Create a SwiftUI view (`FocusBarView`) with:
  - A horizontal layout: task title (Text) and an opacity slider (Slider).
  - The title should use `.truncationMode(.tail)` and `.lineLimit(1)` for ellipsis.
  - The slider should range from 0.2 to 1.0, labeled with an icon (e.g., SF Symbol for "opacity").
  - The view's background should use `.ultraThinMaterial` with the selected opacity.
  - Bindings for the opacity value and task title from the ViewModel.
  - Accessibility modifiers for VoiceOver.
- Ensure the view is previewable in Xcode Previews.

## Libraries / Imports
- SwiftUI
- (Optionally) Combine (for bindings, if needed)
- SF Symbols (for slider icon)

## Edge-Cases and Error Handling
- Task title is empty or nil: display placeholder or hide.
- Title is too long: ensure truncation with ellipsis.
- Opacity slider is set to minimum or maximum: clamp values to 0.2–1.0.
- Rapid changes to opacity: debounce updates if needed (for persistence, handled in later sub-task).
- Accessibility: ensure all controls are labeled and usable with VoiceOver.

## Testing Strategy & Acceptance Criteria
- **Unit/UI Tests:**
  - Title displays correctly and truncates with ellipsis if too long.
  - Slider adjusts opacity between 0.2 and 1.0.
  - View updates when the focus task changes.
  - Accessibility labels are present for all controls.
- **Manual Testing:**
  - Visual inspection in light/dark mode.
  - Test with VoiceOver enabled.
- **Acceptance Criteria:**
  - FocusBarView displays the current task title and an opacity slider.
  - Opacity changes update the bar's appearance in real time.
  - UI is accessible and visually consistent with the PRD.
  - All tests pass.

## Relationship to FocusBarWindow.swift

The implementation of `FocusBarView` will be integrated with the existing `FocusBarWindow.swift` as follows:

- **FocusBarWindow.swift** is responsible for creating and configuring the always-on-top window using AppKit (`NSWindow`). It acts as a bridge between AppKit (window management) and SwiftUI (UI rendering). It does not contain any UI logic itself.
- **FocusBarView.swift** (this sub-task) will define the actual SwiftUI view that displays the current focus task’s title and the opacity slider. All UI logic, bindings, and accessibility features will live here.
- The window controller in `FocusBarWindow.swift` embeds a SwiftUI view as its content. Currently, it uses a placeholder view, but once `FocusBarView` is implemented, the window controller will be updated to use `FocusBarView` instead.
- This separation ensures that window management and UI logic are decoupled: `FocusBarWindowController` manages the window, while `FocusBarView` manages the UI and user interaction.

**Summary of roles:**
- `FocusBarWindowController` (in `FocusBarWindow.swift`): Handles window creation and hosts a SwiftUI view.
- `FocusBarView` (to be implemented): Handles all UI, state, and user interaction for the focus bar.
