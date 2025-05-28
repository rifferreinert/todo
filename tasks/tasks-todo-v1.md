## Relevant Files

- `FocusTodoApp.swift` – App entry point; sets up windows & DI.
- `Persistence/PersistenceController.swift` – Core Data stack singleton.
- `Models/Task+CoreDataClass.swift` – Generated Core Data entity.
- `Repositories/TaskRepository.swift` – Protocol for CRUD access.
- `Repositories/CoreDataTaskRepository.swift` – Core Data implementation.
- `ViewModels/TaskViewModel.swift` – One task’s presentation logic.
- `ViewModels/TaskListViewModel.swift` – List-level logic & sorting.
- `Views/FocusBar/FocusBarWindow.swift` – NSWindow wrapper (always-on-top).
- `Views/FocusBar/FocusBarView.swift` – SwiftUI bar UI.
- `Views/TaskList/TaskListWindow.swift` – Editing window host.
- `Views/TaskList/TaskListView.swift` – SwiftUI list UI.
- `Resources/Assets.xcassets` – SF Symbols & colour sets.
- `Tests/CoreDataTaskRepositoryTests.swift` – Unit tests for repository.
- `Tests/FocusBarViewTests.swift` – UI tests for bar behaviour.
- `Tests/TaskListViewTests.swift` – UI tests for task window.

### Notes

- Place each `*.test.swift` file in the matching `Tests/` group.
- Run `xcodebuild test -scheme FocusTodo` to execute all tests.
- Use SwiftLint to maintain code-style consistency.

## Tasks

- [ ] 1.0 Project Setup & Core Architecture
  - [ ] 1.1 Enable App Sandbox & file-access entitlements.
  - [ ] 1.2 Ensure folder structure is configured: *Models, ViewModels, Views, Repositories, Persistence, Tests*.
  - [ ] 1.3 Add SwiftLint & CI workflow.
  - [ ] 1.5 Implement `PersistenceController` singleton.
  - [ ] 1.6 Define `TaskRepository` protocol for dependency injection.

- [ ] 2.0 Data Model & Persistence Layer
  - [ ] 2.1 Design Core Data model (`Task` entity: title, notes, dueDate, isCompleted, order, createdAt).
  - [ ] 2.2 Generate NSManagedObject subclasses.
  - [ ] 2.3 Implement `CoreDataTaskRepository` (CRUD, fetch sorted).
  - [ ] 2.4 Write unit tests validating CRUD behaviour and data persistence.
  - [ ] 2.5 Stub lightweight migration strategy for future schema changes.

- [ ] 3.0 Always-On-Top Focus Bar
  - [ ] 3.1 Create `FocusBarWindow` using `NSWindow.Level.statusBar`.
  - [ ] 3.2 Build `FocusBarView` with task title, opacity slider (20–100 %).
  - [ ] 3.3 Persist opacity in `UserDefaults`; restore on launch.
  - [ ] 3.4 Add ellipsis truncation & fade animation on task change.
  - [ ] 3.5 Mirror bar across all virtual desktops.
  - [ ] 3.6 Provide VoiceOver labels and dynamic-type support.
  - [ ] 3.7 UI tests: bar visibility, opacity persistence, title update.

- [ ] 4.0 Task Management Window
  - [ ] 4.1 Launch resizable `TaskListWindow` from menu/bar action.
  - [ ] 4.2 Display list with inline add, delete, edit (title, notes, dueDate).
  - [ ] 4.3 Implement drag-and-drop reorder overriding auto-sort.
  - [ ] 4.4 Add global “Toggle Notes” visibility button.
  - [ ] 4.5 Provide segmented control to switch between *Active* and *Archived*.
  - [ ] 4.6 Ensure Dark/Light mode & accessibility compatibility.
  - [ ] 4.7 UI tests covering CRUD, toggle notes, and segmentation.

- [ ] 5.0 Task Ordering, Completion & Archive
  - [ ] 5.1 Implement auto-sort flag (default = on) stored in `UserDefaults`.
  - [ ] 5.2 Update list when flag toggles; fallback to manual order when off.
  - [ ] 5.3 On completion, move task to *Archived* and select next focus task.
  - [ ] 5.4 Handle tasks without due dates per spec (bottom of dated list).
  - [ ] 5.5 Unit tests: sorting logic, completion flow, edge cases.
