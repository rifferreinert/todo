**Sub-task ID**: 2.1
**Sub-task Description**: Design Core Data model (`Task` entity: title, notes, dueDate, isCompleted, order, createdAt).

## Problem Statement and Goal

We need to design and implement a Core Data model for the Focus To-Do app that will serve as the foundation for all task data persistence. The model must support the core functionality outlined in the PRD while being designed to avoid platform-specific keys that would block future CloudKit sync integration.

The Core Data model needs to represent tasks with all required fields and relationships, following Swift and Core Data best practices.

## Relevant Files
- `Todo/Todo.xcdatamodeld/Todo.xcdatamodel/contents` – Core Data model definition file that will be modified to include the Task entity
- `Todo/Models/Task+CoreDataClass.swift` – Will be generated automatically by Xcode for the Task entity (single file with class codegen)

## Inputs & Outputs

**Inputs:**
- PRD requirements for task data structure
- Core Data best practices
- Future CloudKit compatibility requirements

**Outputs:**
- Complete Core Data model with Task entity
- Properly configured attributes with correct data types
- Validation rules and constraints where appropriate
- Generated NSManagedObject subclass (single file)

## Sub-task Technical Approach

1. **Open Xcode and navigate to the Core Data model**
   - Open `Todo.xcdatamodeld` in Xcode's visual editor
   - This is the proper way to edit Core Data models as it's an XML file typically modified through Xcode UI

2. **Design Task Entity with Required Attributes:**
   - `title`: String, required, non-optional
   - `notes`: String, optional (can be nil for tasks without notes)
   - `dueDate`: Date, optional (tasks don't require due dates)
   - `isCompleted`: Boolean, required, default false
   - `order`: Int32, required (for manual ordering when auto-sort is disabled)
   - `createdAt`: Date, required, default now (for audit trail and potential sorting)
   - `updatedAt`: Date, required (to track last modification time)

3. **Configure Attribute Properties:**
   - Set appropriate default values
   - Configure validation rules (e.g., title must not be empty)
   - Ensure CloudKit-compatible naming (avoid reserved keywords)

4. **Generate NSManagedObject Subclass:**
   - Set codegen to "Class" for the Task entity
   - This will generate a single complete class file
   - Simpler approach for initial development - can be changed to Category/Extension later if custom methods are needed

5. **Validation and Testing Setup:**
   - Ensure the model compiles without errors
   - Verify that generated class is properly created
   - Test basic instantiation in the existing app structure

## Libraries / Imports

- `CoreData` framework (already imported in the project)
- `Foundation` framework for basic data types
- No additional external libraries required for this sub-task

## Edge-Cases and Error Handling

- **Empty titles**: Implement validation to prevent tasks with empty or whitespace-only titles
- **Date handling**: Ensure dueDate can properly handle nil values and different time zones
- **Order conflicts**: Design order system to handle potential conflicts when multiple tasks have the same order value
- **Migration compatibility**: Ensure the initial model design is compatible with future schema migrations
- **CloudKit naming**: Avoid Core Data attribute names that conflict with CloudKit reserved words
- **Large notes**: Consider if there should be a practical limit on notes field length

## Testing Strategy & Acceptance Criteria

**Manual Testing:**
- Open the Core Data model in Xcode and verify all attributes are correctly configured
- Build the project to ensure no compilation errors
- Verify that NSManagedObject subclass is generated correctly

**Acceptance Criteria:**
- [ ] Task entity exists in Core Data model with all 7 required attributes
- [ ] All attributes have correct data types and optionality settings
- [ ] Default values are properly configured where specified
- [ ] Generated NSManagedObject subclass compiles without errors
- [ ] Project builds successfully with the new model
- [ ] Model design follows CloudKit-compatible naming conventions
- [ ] Codegen is set to "Class" for simplicity

**Future Testing (in subsequent sub-tasks):**
- Unit tests will be written to verify CRUD operations work correctly
- Integration tests will validate the model works with the persistence layer
