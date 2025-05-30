**Sub-task ID**: 2.4
**Sub-task Description**: Define `TaskRepository` protocol for dependency injection

## Problem Statement and Goal

We need to create an abstraction layer between our ViewModels and the data persistence implementation. This will allow us to inject different implementations (like a mock repository for testing or a future CloudKit repository) without changing the business logic code. The protocol should define all CRUD operations and queries needed by the app.

## Relevant Files
- `Repositories/TaskRepository.swift` - Protocol definition with all required CRUD and query methods
- `Todo.xcdatamodeld/Todo.xcdatamodel/contents` - Core Data model (Task entity with "class" codegen - generates class automatically at build time)

## Inputs & Outputs
**Inputs:**
- Understanding of required CRUD operations from PRD
- Knowledge of Core Data Task entity structure
- Future CloudKit compatibility requirements

**Outputs:**
- `TaskRepository` protocol with comprehensive method signatures
- Clear documentation for each method's purpose and parameters
- Protocol designed for dependency injection pattern

## Sub-task Technical Approach
1. **Analyze requirements**: Review PRD and existing Core Data model to understand all needed operations
2. **Design protocol methods**:
   - Basic CRUD: create, read, update, delete tasks
   - Queries: fetch all active tasks, fetch archived tasks, fetch sorted tasks
   - Specific operations: mark task complete, reorder tasks, toggle completion status
3. **Use Swift protocols with associated types if needed** for generic repository pattern
4. **Design async/await pattern** for future-proofing with CloudKit
5. **Include error handling** through Result types or throws
6. **Document each method** with clear parameter descriptions and expected behavior

Key methods to include:
- `createTask(title: String, notes: String?, dueDate: Date?) async throws -> Task`
- `fetchAllActiveTasks() async throws -> [Task]`
- `fetchAllArchivedTasks() async throws -> [Task]`
- `fetchTasksSorted(by: TaskSortOrder) async throws -> [Task]`
- `updateTask(_ task: Task) async throws`
- `deleteTask(_ task: Task) async throws`
- `markTaskComplete(_ task: Task) async throws`
- `reorderTasks(_ tasks: [Task]) async throws`

## Libraries / Imports
- `Foundation` - For basic Swift types like Date, String
- No Core Data imports needed in the protocol itself (it will be abstracted away)
- Task entity reference will be through the auto-generated class at build time

## Edge-Cases and Error Handling
- **Invalid task data**: Protocol should define what constitutes valid task data
- **Persistence failures**: Methods should throw appropriate errors that can be handled by ViewModels
- **Concurrent access**: Protocol should be designed to handle concurrent operations safely
- **Empty results**: Methods should handle cases where no tasks exist gracefully
- **Future compatibility**: Protocol design should not tie us to Core Data specifics

Error handling approach:
- Use `throws` for methods that can fail
- Define custom error types for different failure scenarios
- Ensure all async operations are properly marked
- Document expected error conditions for each method

## Testing Strategy & Acceptance Criteria
**Testing Strategy:**
- Create mock implementation of TaskRepository for unit testing ViewModels
- Test protocol compliance in future CoreDataTaskRepository implementation
- Verify that protocol methods cover all use cases from PRD
- Ensure that all methods are properly tested for expected behavior

**Acceptance Criteria:**
- [ ] TaskRepository protocol is defined with all required CRUD operations
- [ ] All methods are properly documented with parameter descriptions
- [ ] Protocol uses async/await pattern for future CloudKit compatibility
- [ ] Error handling is clearly defined for all operations
- [ ] Protocol does not expose Core Data specific types
- [ ] Mock implementation can be easily created for testing
- [ ] Protocol supports all task management features from PRD (sorting, completion, archiving)
