**Sub-task ID**: 4.2
**Sub-task Description**: Implement `TaskListViewModel` for list-level logic & sorting.

## Problem Statement and Goal
The app needs a `TaskListViewModel` to manage a collection of tasks, handle sorting (by order integer, with an auto-sort function for due dates), and provide business logic for the task list. This ViewModel will serve as the source of truth for the task list UI, supporting both manual reordering and an auto-sort function that updates the order integers to match due date order. It will coordinate updates when tasks are added, edited, completed, or archived.

## Relevant Files
- `TodoApp/ViewModels/TaskListViewModel.swift`: Implements the ViewModel logic for managing the list of tasks, sorting, and exposing data to the UI.
- `TodoApp/Repositories/TaskRepository.swift`: Used for CRUD operations on tasks (already exists).
- `TodoApp/Repositories/CoreDataTaskRepository.swift`: Core Data implementation for persistence (already exists).
- `TodoApp/ViewModels/TaskViewModel.swift`: Used for representing individual tasks (already exists).
- `TodoTests/TaskListViewModelTests.swift`: Unit tests for TaskListViewModel (sorting, completion, edge cases).

## Inputs & Outputs
- **Inputs:**
  - List of `Task` entities from the repository
  - User actions: add, edit, delete, complete, reorder, invoke auto-sort function
- **Outputs:**
  - Published list of `TaskViewModel` objects for the UI
  - Sorted and/or reordered task list (always by `order` integer)
  - Notifications to the UI when the list changes

## Sub-task Technical Approach
- Implement `TaskListViewModel` as an `ObservableObject`.
- Expose a published array of `TaskViewModel` objects.
- Fetch tasks from the repository and map to `TaskViewModel`.
- Always sort tasks by their `order` integer for display and logic.
- Provide an `autoSortByDueDate()` function that updates the `order` property of each task so that tasks with due dates come first (ascending), followed by those without due dates.
- Provide methods for add, edit, delete, complete, and reorder actions.
- Handle updates when tasks are changed or completed (move to archive, update focus, etc).
- Use dependency injection for the repository.

## Libraries / Imports
- `SwiftUI` (for `ObservableObject`, `@Published`)
- `Combine` (for publishers, if needed)
- `Foundation`

## Edge-Cases and Error Handling
- Tasks with no due date: always appear below those with due dates after auto-sort is invoked.
- Reordering: always allowed by changing the `order` property; manual reordering persists order.
- Task completion: completed tasks move to archive and next focus is selected.
- Repository errors: handle and surface errors to the UI (e.g., show error message or fallback state).
- Empty list: UI should handle gracefully.

## Testing Strategy & Acceptance Criteria
- **Unit tests** for:
  - Sorting logic (by order integer, and after invoking auto-sort function)
  - Completion flow (archiving, next focus selection)
  - Edge cases (empty list, all tasks completed, tasks with/without due dates)
- **Acceptance Criteria:**
  - ViewModel always sorts and exposes tasks by the `order` property
  - The auto-sort function updates the `order` property to match due date order
  - Manual reordering works by updating the `order` property
  - Completion moves tasks to archive and updates focus
  - All business logic is covered by tests
  - Errors are handled gracefully
