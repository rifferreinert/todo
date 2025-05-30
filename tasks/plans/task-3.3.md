**Sub-task ID**: 3.3
**Sub-task Description**: Stub lightweight migration strategy for future schema changes in Core Data.

## Problem Statement and Goal

Prepare the Core Data stack to support lightweight migrations, so that future changes to the data model (e.g., adding fields) do not break existing user data. The goal is to ensure forward compatibility and smooth upgrades.

## Relevant Files
- `Persistence/PersistenceController.swift` – Core Data stack configuration, where migration options are set.
- `Todo.xcdatamodeld/` – Core Data model; no changes required for a stub, but referenced for context.

## Inputs & Outputs
- **Inputs:**
  - Core Data model version(s)
  - Persistent store coordinator options
- **Outputs:**
  - Persistent store is configured to allow lightweight migration
  - No migration errors on app launch after model changes (future-proofing)

## Sub-task Technical Approach
- Update the persistent store setup in `PersistenceController.swift` to include migration options:
  - `NSMigratePersistentStoresAutomaticallyOption: true`
  - `NSInferMappingModelAutomaticallyOption: true`
- Add comments explaining the purpose and how to extend for future migrations.
- No actual migration is performed now; this is a stub for future schema changes.

## Libraries / Imports
- CoreData

## Edge-Cases and Error Handling
- If migration fails, log the error and fail gracefully (e.g., do not crash, but surface error for debugging).
- Ensure that the migration options do not interfere with in-memory stores used for testing.

## Testing Strategy & Acceptance Criteria
- **Manual test:** Confirm that the app launches and persists data as before.
- **Acceptance criteria:**
  - Migration options are present in the persistent store setup.
  - No regression in data persistence or test suite.
  - Comments document the migration strategy for future developers.
