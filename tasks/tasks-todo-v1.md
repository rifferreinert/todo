# Task List

## Relevant Files

- `TodoApp.swift` – App entry point, sets up windows & DI.
- `TodoApp/Persistence/PersistenceController.swift` – Core Data stack singleton.
- `TodoApp/Repositories/TaskRepository.swift` – Protocol for CRUD access with async/await and error handling.
- `TodoApp/Repositories/CoreDataTaskRepository.swift` – Core Data implementation.
- `TodoApp/ViewModels/TaskViewModel.swift` – One task's presentation logic.
- `TodoApp/ViewModels/TaskListViewModel.swift` – List-level logic & sorting.
- `TodoApp/Views/FocusBar/FocusBarWindow.swift` – NSWindow wrapper (always-on-top).
- `TodoApp/Views/FocusBar/FocusBarView.swift` – SwiftUI bar UI.
- `TodoApp/Views/TaskList/TaskListWindow.swift` – Editing window host.
- `TodoApp/Views/TaskList/TaskListView.swift` – SwiftUI list UI.
- `TodoApp/Resources/Assets.xcassets` – SF Symbols & colour sets.
- `TodoTests/CoreDataTaskRepositoryTests.swift` – Unit tests for repository.
- `TodoTests/TaskViewModelTests.swift` – Unit tests for task ViewModel.
- `TodoTests/TaskListViewModelTests.swift` – Unit tests for task list ViewModel.
- `TodoTests/TodoTests.swift` – Main test suite entry point.
- `TodoTests/TaskRepositoryTests.swift` – Tests for TaskRepository protocol.
- `TodoUITests/FocusBarViewTests.swift` – UI tests for bar behaviour.
- `TodoUITests/TaskListViewTests.swift` – UI tests for task window.
- `.swiftlint.yml` – SwiftLint configuration for code style consistency.
- `scripts/lint.sh` – Manual SwiftLint execution script.
- `.git/hooks/pre-commit` – Git hook to run SwiftLint before commits.

### Notes

- Place each `*.test.swift` file in the matching `Tests/` group.
- Run `xcodebuild test -scheme FocusTodo` to execute all tests.
- SwiftLint is configured for code-style consistency:
  - Run `swiftlint` from project root to check all files
  - Run `./scripts/lint.sh` for detailed output with help
  - Git pre-commit hook automatically runs SwiftLint
  - Due to App Sandbox restrictions, SwiftLint runs via command line instead of Xcode build phase

## Tasks

- [x] 1.0 Project Setup & Core Architecture
  - [x] 1.1 Enable App Sandbox & file-access entitlements.
  - [x] 1.2 Ensure folder structure is configured: *Models, ViewModels, Views, Repositories, Persistence, Tests*.
  - [x] 1.3 Add SwiftLint

- [x] 2.0 Data Model & Core Data Setup
  - [x] 2.1 Design Core Data model (`Task` entity: title, notes, dueDate, isCompleted, order, createdAt, updatedAt).
  - [x] 2.2 Generate NSManagedObject subclasses (using automatic class generation).
  - [x] 2.3 Implement `PersistenceController` singleton.
  - [x] 2.4 Define `TaskRepository` protocol for dependency injection.

- [x] 3.0 Data Persistence Layer
  - [x] 3.1 Implement `CoreDataTaskRepository` (CRUD, fetch sorted).
  - [x] 3.2 Write unit tests validating CRUD behaviour and data persistence.
  - [x] 3.3 Stub lightweight migration strategy for future schema changes.

- [x] 4.0 ViewModels & Business Logic
  - [x] 4.1 Implement `TaskViewModel` for individual task presentation logic.
  - [x] 4.2 Implement `TaskListViewModel` for list-level logic & sorting.
  - [ ] 4.3 Unit tests for ViewModels (sorting logic, completion flow, edge cases).

- [ ] 5.0 Always-On-Top Focus Bar
  - [ ] 5.1 Create `FocusBarWindow` using `NSWindow.Level.statusBar`.
  - [ ] 5.2 Build `FocusBarView` with task title, opacity slider (20–100 %).
  - [ ] 5.3 Persist opacity in `UserDefaults`; restore on launch.
  - [ ] 5.4 Add ellipsis truncation & fade animation on task change.
  - [ ] 5.5 Mirror bar across all virtual desktops.
  - [ ] 5.6 Provide VoiceOver labels and dynamic-type support.
  - [ ] 5.7 UI tests: bar visibility, opacity persistence, title update.

- [ ] 6.0 Task Management Window
  - [ ] 6.1 Launch resizable `TaskListWindow` from menu/bar action.
  - [ ] 6.2 Display list with inline add, delete, edit (title, notes, dueDate).
  - [ ] 6.3 Implement drag-and-drop reorder overriding auto-sort.
  - [ ] 6.4 Add global "Toggle Notes" visibility button.
  - [ ] 6.5 Provide segmented control to switch between *Active* and *Archived*.
  - [ ] 6.6 Ensure Dark/Light mode & accessibility compatibility.
  - [ ] 6.7 UI tests covering CRUD, toggle notes, and segmentation.

- [ ] 7.0 Task Ordering, Completion & Archive
  - [ ] 7.1 Implement auto-sort flag (default = on) stored in `UserDefaults`.
  - [ ] 7.2 Update list when flag toggles; fallback to manual order when off.
  - [ ] 7.3 On completion, move task to *Archived* and select next focus task.
  - [ ] 7.4 Handle tasks without due dates per spec (bottom of dated list).
  - [ ] 7.5 Unit tests: sorting logic, completion flow, edge cases.
