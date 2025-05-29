# Rule: Generate a detailed plan for a sub-task based on the provided task description.

## Goal

Generate a detailed plan for a sub-task based on the provided task description. This helps in breaking down larger tasks into manageable parts, ensuring clarity and focus on specific objectives.

## Process
1. **Read the Task Description**: Understand the overall task and its objectives.
2. **Analyze the sub-task requirements**: Identify the specific goals, inputs, outputs, and technical approach needed for the sub-task.
3. **Generate a Markdown file**: Create a structured plan in Markdown format that includes all necessary sections. Inform the user: "I have generated a detailed plan for the sub-task. You can find it here `tasks/plans/task-<task-id>.md`."

## Sub Task Plan Structure

The generated markdown file should follow this structure:
```markdown
**Sub-task ID**: A unique identifier for the sub-task.
**Sub-task Description**: A brief description of the sub-task.

## Problem Statement and Goal

## Relevant Files
- `path/to/potential/file1.ts` - Brief description of why this file is relevant (e.g., Contains the main component for this feature).
- `path/to/file1.test.ts` - Unit tests for `file1.ts`.
- `path/to/another/file.tsx` - Brief description (e.g., API route handler for data submission).
- `path/to/another/file.test.tsx` - Unit tests for `another/file.tsx`.
- `lib/utils/helpers.ts` - Brief description (e.g., Utility functions needed for calculations).
- `lib/utils/helpers.test.ts` - Unit tests for `helpers.ts`.

## Inputs & Outputs
Describe the expected inputs and outputs for the sub-task, including any data structures or formats.

## Sub-task Technical Approach
High level plan including key steps, algorithms, data structures, and any libraries or frameworks to be used.

## Libraries / Imports
List any libraries or modules that will be imported or used in this sub-task.

## Edge-Cases and Error Handling
- Bullet the tricky edge-cases that need to be handled, and how they will be addressed.
- Describe how errors will be handled, including any fallback mechanisms or user notifications.

## Testing Strategy & Acceptance Criteria
- Describe how the sub-task will be tested, including unit tests, integration tests, and manual testing.
- Define the acceptance criteria that must be met for the sub-task to be considered complete.
```

## Output

*   **Format:** Markdown (`.md`)
*   **Location:** `tasks/plans`
*   **File Name:** `task-<task-id>.md`