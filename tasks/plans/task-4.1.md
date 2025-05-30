**Sub-task ID**: 4.1
**Sub-task Description**: Implement `TaskViewModel` for individual task presentation logic.

## Problem Statement and Goal
The app needs a ViewModel to represent a single task, providing presentation logic and data binding between the Core Data model and SwiftUI views. This ViewModel will expose task properties (title, notes, due date, completion status, etc.), handle updates, and validate user input, ensuring the UI remains in sync with the underlying data.

## Relevant Files
- `ViewModels/TaskViewModel.swift` – Implements the `TaskViewModel` class/struct.
- `Repositories/TaskRepository.swift` – Used for data access (already exists).
- `Tests/TaskViewModelTests.swift` – Unit tests for the ViewModel.

## Inputs & Outputs
**Inputs:**
- A `Task` Core Data object (or its identifier).
- User input for editing task fields (title, notes, due date, completion toggle).

**Outputs:**
- Published properties for SwiftUI binding (title, notes, due date, isCompleted, etc.).
- Methods to update task fields and persist changes via the repository.
- Validation errors (e.g., empty title).

## Sub-task Technical Approach
- Define a `TaskViewModel` class (or struct) conforming to `ObservableObject`.
- Expose `@Published` properties for all editable fields.
- Initialize from a `Task` object; keep properties in sync with Core Data.
- Provide methods to update fields, validate input, and save changes using `TaskRepository`.
- Implement error handling for invalid input and repository failures.
- Add computed properties for presentation (e.g., formatted due date).

## Libraries / Imports
- SwiftUI
- Combine
- Foundation
- (Existing) TaskRepository protocol

## Edge-Cases and Error Handling
- Empty or whitespace-only title: prevent save, show error.
- Invalid date (should not occur via UI, but validate anyway).
- Repository save failure: surface error to UI.
- Task deleted externally: handle gracefully (e.g., disable editing, show message).

## Testing Strategy & Acceptance Criteria
- Unit tests for all property bindings and update methods.
- Tests for validation logic (e.g., empty title, invalid date).
- Tests for error propagation from repository.
- Acceptance criteria:
  - ViewModel correctly reflects and updates task data.
  - Validation prevents invalid saves.
  - Errors are surfaced to the UI layer.
  - All tests pass.
