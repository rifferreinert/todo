**Sub-task ID**: 3.1
**Sub-task Description**: Implement `CoreDataTaskRepository` (CRUD, fetch sorted)

## Problem Statement and Goal
The app needs a data persistence layer that provides robust, testable CRUD (Create, Read, Update, Delete) operations for tasks, as well as efficient sorted fetching. This will be achieved by implementing the `CoreDataTaskRepository` class, which conforms to the `TaskRepository` protocol and interacts with Core Data for all task-related storage and retrieval.

## Relevant Files
- `Repositories/CoreDataTaskRepository.swift`: Implements the repository, providing async/await CRUD and sorted fetch methods.
- `Persistence/PersistenceController.swift`: Used for Core Data stack access (already exists).
- `Repositories/TaskRepository.swift`: Protocol definition (already exists).
- `Todo.xcdatamodeld/`: Core Data model (already exists).

## Inputs & Outputs
- **Inputs:**
  - Task data (title, notes, dueDate, isCompleted, order, createdAt, updatedAt)
  - CRUD method parameters (e.g., task ID, filter/sort options)
- **Outputs:**
  - Task objects (as model structs or managed objects)
  - Errors (thrown on failure)

## Sub-task Technical Approach
- Implement `CoreDataTaskRepository` as a class conforming to `TaskRepository`.
- Use dependency injection for the Core Data context (via `PersistenceController`).
- Provide async/await methods for:
  - Creating a new task
  - Fetching all tasks (with sorting by due date and/or manual order)
  - Updating a task
  - Deleting a task
- Implement error handling for Core Data failures.
- Ensure all fetches are performed on a background context to avoid UI blocking.
- Map between Core Data entities and Swift model structs if needed.

## Libraries / Imports
- `CoreData`
- `Foundation`

## Edge-Cases and Error Handling
- Handle Core Data save failures (throw errors, log, and propagate to caller).
- Validate required fields (e.g., title must not be empty).
- Handle fetch requests that return no results gracefully.
- Ensure thread safety by using the correct context.
- Handle migration errors (stub for now).

## Testing Strategy & Acceptance Criteria
- Unit tests in `Tests/CoreDataTaskRepositoryTests.swift` for all CRUD methods and sorted fetches.
- Tests should cover success and failure cases (e.g., invalid input, Core Data errors).
- Acceptance criteria:
  - All CRUD operations work as expected and persist data.
  - Fetch returns tasks in correct order (by due date, then manual order).
  - All tests pass and error cases are handled gracefully.
