# DTO Refactor Implementation Plan
A step-by-step plan to decouple domain logic from Core Data by introducing a Data Transfer Object (DTO) for tasks.

---

**Sub-task ID**: DTO-1
**Sub-task Description**: Define and introduce `TaskDTO` in `TaskRepository.swift`.

## Problem Statement and Goal
Currently, the repository API methods use the Core Data `Task` NSManagedObject directly, coupling the business logic to the persistence layer. The goal is to introduce a lightweight, immutable DTO (`TaskDTO`) that represents task data and lives in the repository protocol file.

## Relevant Files
- `TaskRepository.swift`: will host the new `TaskDTO` struct and documentation.

## Inputs & Outputs
- Input: Raw task fields (e.g., title, notes, dueDate, isCompleted, order, createdAt, updatedAt).
- Output: A `TaskDTO` instance encapsulating those fields.

## Sub-task Technical Approach
1. In `TaskRepository.swift`, add a new `struct TaskDTO: Identifiable, Equatable { ... }`.
2. Define properties: `id: NSManagedObjectID`, `title: String`, `notes: String?`, `dueDate: Date?`, `isCompleted: Bool`, `order: Int32`, `createdAt: Date`, `updatedAt: Date`.
3. Add docstrings to explain each property and purpose.

## Libraries / Imports
- Foundation

## Edge-Cases and Error Handling
- Validate non-empty `title` in factory methods.
- Ensure default values for optional fields.
- DTO must not throw errors; validation is enforced in repository methods.

## Testing Strategy & Acceptance Criteria
- Unit tests to verify DTO initialization and `Equatable` behavior.
- Acceptance: `TaskDTO` compiles, has all required fields, and can be compared for equality.

---

**Sub-task ID**: DTO-2
**Sub-task Description**: Refactor `TaskRepository` protocol to use `TaskDTO` instead of Core Data `Task`.

## Problem Statement and Goal
Protocol methods currently use the Core Data `Task` class in signatures. This binds the API to the persistence model. We need to update signatures to accept and return `TaskDTO`.

## Relevant Files
- `TaskRepository.swift`: modify method definitions and doc comments.

## Inputs & Outputs
- Inputs: `TaskDTO` instead of `Task` for update, delete, markComplete, markActive, reorderTasks.
- Outputs: `TaskDTO` or `[TaskDTO]` instead of `Task` or `[Task]`.

## Sub-task Technical Approach
1. Change all occurrences of `Task` in method signatures to `TaskDTO`.
2. Update return types of CRUD and query operations to use `TaskDTO`.
3. Adjust doc comments to reference `TaskDTO`.

## Libraries / Imports
- Foundation

## Edge-Cases and Error Handling
- Signature changes only; no new logic.
- Maintain existing error cases in `TaskRepositoryError`.

## Testing Strategy & Acceptance Criteria
- Code compiles without errors.
- Existing tests referencing protocol signatures compile (after mocks are updated).

---

**Sub-task ID**: DTO-3
**Sub-task Description**: Update `CoreDataTaskRepository` to conform to `TaskRepository`, map between Core Data `Task` and `TaskDTO`, and implement all required methods.

## Problem Statement and Goal
The `CoreDataTaskRepository` currently uses an internal `TaskModel` and does not conform to `TaskRepository`. We need to remove `TaskModel`, adopt the `TaskRepository` protocol, map entities to/from `TaskDTO`, and implement all CRUD, query, state, and batch operations as defined in the protocol.

## Relevant Files
- `TodoApp/Repositories/TaskRepository.swift`: contains `TaskDTO` and protocol definitions.
- `TodoApp/Repositories/CoreDataTaskRepository.swift`: to be updated to adopt `TaskRepository` and implement its methods.

## Inputs & Outputs
- Inputs: `TaskDTO` for updates, deletes, state changes, and manual reordering.
- Outputs: `TaskDTO` or collections thereof for create, fetch, mark complete/active, and reorder operations; `Int` for batch delete and counts.

## Sub-task Technical Approach
1. In `CoreDataTaskRepository.swift`, change class declaration to `final class CoreDataTaskRepository: TaskRepository`.
2. Remove the standalone `TaskModel` struct and any `TaskSortOption` if redundant (or map to `TaskSortOrder`).
3. Add `import CoreData` and ensure `TaskRepository` and `TaskDTO` are visible.
4. Define private helpers:
   ```swift
   private func mapToDTO(_ task: Task) -> TaskDTO { ... }
   private func fetchManaged(_ id: NSManagedObjectID) async throws -> Task { ... }
   ```
5. Refactor `createTask(title:notes:dueDate:)`, `updateTask(_:)`, and `deleteTask(_:)` to use `TaskDTO` and helpers.
6. Implement remaining protocol methods:
   - `fetchAllActiveTasks()`, `fetchAllArchivedTasks()`, `fetchTasksSorted(by:)`, `fetchNextFocusTask()`
   - `markTaskComplete(_:)`, `markTaskActive(_:)`, `reorderTasks(_:)`
   - `deleteAllCompletedTasks()`, `getActiveTaskCount()`, `getArchivedTaskCount()`
7. Use appropriate `NSFetchRequest` filters and `NSSortDescriptor`s for queries; map results to `TaskDTO`.
8. Translate Core Data exceptions into `TaskRepositoryError.persistenceFailure` and `TaskRepositoryError.taskNotFound`.

## Libraries / Imports
- Foundation
- CoreData

## Edge-Cases and Error Handling
- Concurrency: wrap context operations inside `context.perform`.
- Handle missing object errors by throwing `TaskRepositoryError.taskNotFound`.
- Validation failures map to `TaskRepositoryError.validationError` or `persistenceFailure`.

## Testing Strategy & Acceptance Criteria
- All methods compile and satisfy `TaskRepository` signature.
- Run `CoreDataTaskRepositoryTests` and ensure all tests pass.
- Validate mapping accuracy by comparing DTO values against managed objects.
---

**Sub-task ID**: DTO-4
**Sub-task Description**: Update mocks and unit tests to use `TaskDTO`.

## Problem Statement and Goal
Mocks and tests currently reference the old `Task` class or `TaskModel`. They must be updated to work with `TaskDTO`.

## Relevant Files
- `TodoTests/Mocks/MockTaskRepository.swift`
- `TodoTests/TaskViewModelTests.swift`
- `TodoTests/CoreDataTaskRepositoryTests.swift` (if it references `TaskModel` directly)

## Inputs & Outputs
- Tests will create and assert on `TaskDTO` instances.

## Sub-task Technical Approach
1. Change mock repository signatures to `TaskDTO`.
2. Update stored properties (e.g., `lastSavedTask: TaskDTO?`).
3. Update test fixtures (`sampleTask`) to use `TaskDTO`.
4. Adjust assertions to compare `TaskDTO` instead of Core Data objects.

## Libraries / Imports
- Foundation
- CoreData (if tests still need to construct managed objects)

## Edge-Cases and Error Handling
- Ensure test data initialization is correct.
- Keep mock errors in sync with `TaskRepositoryError`.

## Testing Strategy & Acceptance Criteria
- All unit tests compile and pass.
- Coverage for view-model tests remains unchanged.

---

**Sub-task ID**: DTO-5
**Sub-task Description**: Update view models and UI to consume `TaskDTO`.

## Problem Statement and Goal
`TaskViewModel`, `TaskListViewModel`, and views currently use Core Data `Task`. They need to be updated to use `TaskDTO`.

## Relevant Files
- `ViewModels/TaskViewModel.swift`
- `ViewModels/TaskListViewModel.swift`
- `Views/TaskList/ContentView.swift` (or similar)

## Inputs & Outputs
- View-models will wrap `TaskDTO` instead of `Task`.
- Views will bind to view-model properties that originate from DTO.

## Sub-task Technical Approach
1. Change stored property types from `Task` to `TaskDTO`.
2. Update initializer and method calls to repository to pass and receive `TaskDTO`.
3. Adjust published properties, computed values, and UI bindings accordingly.

## Libraries / Imports
- SwiftUI
- Foundation

## Edge-Cases and Error Handling
- Preserve UI behavior and state.
- Validate that task updates propagate correctly.

## Testing Strategy & Acceptance Criteria
- Run `TaskViewModelTests` and any UI tests to confirm UI still functions.
- Manual smoke test in simulator: create, update, delete tasks and verify UI reflects DTO data correctly.
