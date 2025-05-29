**Sub-task ID**: 1.2
**Sub-task Description**: Ensure folder structure is configured: *Models, ViewModels, Views, Repositories, Persistence, Tests*.

## Problem Statement and Goal

The current Xcode project has a flat file structure typical of a new project template. To maintain clean architecture and follow MVVM patterns with dependency injection, we need to organize the codebase into logical folders that separate concerns and make the code more maintainable as the project grows.

## Relevant Files
- `Todo/Models/` - Directory for Core Data entities and data models
- `Todo/ViewModels/` - Directory for presentation logic and business logic coordination
- `Todo/Views/` - Directory organized by feature areas (FocusBar, TaskList)
- `Todo/Views/FocusBar/` - Components for the always-on-top focus bar
- `Todo/Views/TaskList/` - Components for the task management window
- `Todo/Repositories/` - Directory for data access layer abstractions and implementations
- `Todo/Persistence/` - Directory for Core Data stack and persistence utilities
- Move existing `Persistence.swift` to `Todo/Persistence/PersistenceController.swift`
- Move existing `ContentView.swift` to appropriate Views subfolder (likely TaskList)
- Update Xcode project file to reflect new folder structure

## Inputs & Outputs
**Inputs:**
- Existing flat project structure
- Current `Persistence.swift` and `ContentView.swift` files
- Xcode project file (`Todo.xcodeproj`)

**Outputs:**
- Organized folder structure matching the architecture plan
- Updated Xcode project references
- Renamed files following Swift conventions
- Maintained build integrity

## Sub-task Technical Approach
1. **Create directory structure in Xcode** (not filesystem) using Xcode groups
   - This is important because Xcode manages project organization differently than filesystem
   - Groups in Xcode don't necessarily correspond to filesystem folders
   - Use Xcode's "New Group" feature to create logical organization

2. **Move and rename existing files:**
   - `Persistence.swift` → `Persistence/PersistenceController.swift`
   - `ContentView.swift` → `Views/TaskList/TaskListView.swift` (rename to be more specific)

3. **Create placeholder groups for future files:**
   - Models/ (will contain Core Data entities)
   - ViewModels/ (will contain TaskViewModel, TaskListViewModel)
   - Views/FocusBar/ (will contain focus bar components)
   - Repositories/ (will contain repository protocol and implementations)

4. **Verify build integrity** after reorganization

## Libraries / Imports
- No additional libraries needed for this structural change
- Ensure existing SwiftUI and Core Data imports remain functional

## Edge-Cases and Error Handling
- **Xcode project corruption**: Make sure to work within Xcode when moving files to avoid breaking project references
- **Import path issues**: Verify that file moves don't break any existing imports (minimal risk since we have few files)
- **Build target membership**: Ensure moved files remain properly assigned to build targets

## Testing Strategy & Acceptance Criteria
**Manual Testing:**
- Project builds successfully after reorganization
- All existing functionality remains intact
- Xcode navigator shows clean folder organization

**Acceptance Criteria:**
- [ ] Folder structure matches the architecture outlined in task list
- [ ] All files are properly organized in logical groups
- [ ] `Persistence.swift` is renamed to `PersistenceController.swift` and moved
- [ ] `ContentView.swift` is renamed and moved to appropriate Views subfolder
- [ ] Project builds without errors
- [ ] No broken file references in Xcode project
- [ ] Groups are created for all major architectural components
