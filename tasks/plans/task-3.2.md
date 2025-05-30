**Sub-task ID**: 3.2
**Sub-task Description**: Write unit tests validating CRUD behaviour and data persistence for CoreDataTaskRepository.

## Problem Statement and Goal

Ensure that the CoreDataTaskRepository implementation correctly performs Create, Read, Update, and Delete (CRUD) operations and that data persists as expected using Core Data. The goal is to catch regressions and guarantee reliability of the persistence layer.

## Relevant Files
- `Tests/CoreDataTaskRepositoryTests.swift` – Contains unit tests for CoreDataTaskRepository CRUD and persistence logic.
- `Repositories/CoreDataTaskRepository.swift` – The implementation under test.
- `Persistence/PersistenceController.swift` – Provides the Core Data stack for test setup/teardown.

## Inputs & Outputs
- **Inputs:**
  - Test data representing tasks (title, notes, dueDate, isCompleted, order, createdAt, updatedAt).
  - Test Core Data stack (in-memory store for isolation).
- **Outputs:**
  - Assertions verifying correct CRUD behaviour (task creation, retrieval, update, deletion).
  - Verification that data persists across repository calls within the test lifecycle.

## Sub-task Technical Approach
- Use XCTest to structure and run tests.
- Set up an in-memory Core Data stack for isolation and repeatability.
- For each CRUD operation:
  - Create: Insert a new task and verify it exists in the store.
  - Read: Fetch tasks and verify correct data is returned.
  - Update: Modify a task and verify changes persist.
  - Delete: Remove a task and verify it no longer exists.
- Test edge cases (e.g., updating non-existent tasks, deleting already deleted tasks).
- Clean up Core Data context between tests.

## Libraries / Imports
- XCTest
- CoreData
- The app’s model/repository modules

## Edge-Cases and Error Handling
- Attempting to update or delete a task that does not exist.
- Handling Core Data save failures (simulate with invalid data if possible).
- Ensuring no data leaks between tests (test isolation).
- Verifying that required fields (e.g., title) are enforced.

## Testing Strategy & Acceptance Criteria
- **Unit tests**: Cover all CRUD operations and edge cases.
- **Test isolation**: Each test must run independently using an in-memory store.
- **Acceptance criteria:**
  - All CRUD operations are tested and pass.
  - Edge cases are handled gracefully (with errors thrown or handled as per repository contract).
  - No data persists between tests.
  - Tests are readable, well-documented, and follow Swift/XCTest conventions.
