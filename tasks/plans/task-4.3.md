**Sub-task ID**: 4.3
**Sub-task Description**: Add missing unit tests for ViewModels (sorting logic, completion flow, edge cases) based on gap analysis.

---

## Problem Statement and Goal

While the existing unit tests for `TaskViewModel` and `TaskListViewModel` cover most core scenarios, several important edge cases and PRD requirements are not yet tested. The goal is to ensure robust, comprehensive test coverage for all ViewModel logic, especially around sorting modes, completion, notes, and error handling.

---

## Relevant Files

- [`TodoTests/TaskListViewModelTests.swift`](TodoTests/TaskListViewModelTests.swift )
  *Add new tests for sort mode toggling, drag-and-drop, tie-breaking, segment switching, and notes visibility if applicable.*

- [`TodoTests/TaskViewModelTests.swift`](TodoTests/TaskViewModelTests.swift )
  *Add new tests for updating notes, marking complete, toggling completion, and error handling on all update methods.*

---

## Inputs & Outputs

**Inputs:**
- Mocked task data (with/without due dates, identical due dates, completed/incomplete)
- Mock repository with configurable behaviors

**Outputs:**
- New or updated test cases that assert correct ViewModel behavior for all scenarios
- Clear error reporting and state validation in edge cases

---

## Sub-task Technical Approach

1. **TaskListViewModelTests.swift**
   - Add tests for toggling between auto-sort/manual sort and persisting the mode.
   - Add tests for drag-and-drop reordering when auto-sort is off.
   - Add tests for tie-breaking when tasks have identical due dates.
   - Add tests for switching between *Active* and *Archived* segments.
   - Add tests for notes visibility toggle if ViewModel manages this.

2. **TaskViewModelTests.swift**
   - Add test for updating notes field.
   - Add test for marking a task as completed from the ViewModel.
   - Add test for toggling completion state (if supported).
   - Add test for updating multiple fields in succession.
   - Add tests for error handling on due date and notes update.

3. **General**
   - Use TDD: write tests first, confirm with user, then implement missing logic if needed.
   - Ensure all new tests are incremental and reversible.

---

## Libraries / Imports

- `XCTest`
- `Combine`
- `@testable import Todo`

---

## Edge-Cases and Error Handling

- Switching sort modes with no tasks, or only undated tasks.
- Drag-and-drop with only one or zero tasks.
- Tasks with identical due dates (ensure stable sort).
- Switching segments when all tasks are archived or none are archived.
- Updating notes to empty or nil.
- Marking already-completed tasks as complete again.
- Repository failures on all update methods.

---

## Testing Strategy & Acceptance Criteria

- **Testing:**
  - Add new unit tests for each identified gap.
  - Use mock data and repository to simulate all edge cases.
  - Run all tests and ensure they pass before merging.

- **Acceptance Criteria:**
  - All new tests pass.
  - All PRD requirements for ViewModel logic are covered by at least one test.
  - No unhandled edge cases remain for sorting, completion, or notes logic.
  - Code and tests are clear, readable, and follow project conventions.

---

I have generated a detailed plan for the sub-task. You can find it here:
`tasks/plans/task-4.3.md`

Would you like to review or suggest changes to this plan, or should I proceed to write the new tests as described?
