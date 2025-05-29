**Sub-task ID**: 1.3
**Sub-task Description**: Add SwiftLint to the Focus To-Do macOS project for code style consistency

## Problem Statement and Goal

The project needs SwiftLint integration to maintain consistent code style across the codebase. This is essential for a professional Swift application and will help ensure code quality as the project grows. SwiftLint will automatically check Swift code for style violations and enforce best practices.

## Relevant Files
- `.swiftlint.yml` - SwiftLint configuration file with project-specific rules
- `Todo.xcodeproj/project.pbxproj` - Xcode project file (will be modified to add build phase)
- New Build Phase in Xcode - SwiftLint run script phase to be added via Xcode UI

## Inputs & Outputs
**Inputs:**
- Existing Swift source files in the project
- SwiftLint package (to be installed via Homebrew or Swift Package Manager)

**Outputs:**
- Configured SwiftLint with appropriate rules for macOS app development
- Build phase that runs SwiftLint on each build
- Clean codebase with no SwiftLint violations

## Sub-task Technical Approach

1. **Create SwiftLint configuration**: Create a `.swiftlint.yml` file with appropriate rules for the Focus To-Do project
2. **Add build phase via Xcode**: This step requires Xcode UI interaction:
   - Open project in Xcode
   - Add a new "Run Script Phase" to the build phases
   - Configure the script to run SwiftLint
3. **Verify setup**: Run a build to ensure SwiftLint executes correctly
4. **Fix any initial violations**: Address any style issues found in existing code

## Libraries / Imports
- SwiftLint (command-line tool, not a Swift import)
- No additional Swift imports required

## Edge-Cases and Error Handling
- **SwiftLint not installed**: The build script should check if SwiftLint is available and provide clear error message if missing
- **Configuration conflicts**: Use conservative rules initially to avoid overwhelming violations
- **Build performance**: Configure SwiftLint to only check changed files when possible
- **Team compatibility**: Use standard rules that work well across different development environments

## Testing Strategy & Acceptance Criteria

**Testing:**
- Run `swiftlint` command directly to verify installation
- Build the project and confirm SwiftLint runs without errors
- Intentionally introduce a style violation and verify SwiftLint catches it
- Verify build phase only runs SwiftLint on Swift files

**Acceptance Criteria:**
- [ ] SwiftLint is installed and accessible via command line
- [ ] `.swiftlint.yml` configuration file exists with appropriate rules
- [ ] Xcode build phase runs SwiftLint on every build
- [ ] All existing Swift files pass SwiftLint validation
- [ ] Build fails if SwiftLint finds violations (warnings can be allowed initially)
- [ ] SwiftLint configuration follows Apple's Swift style guidelines
