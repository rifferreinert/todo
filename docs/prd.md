content = """# Focus To-Do macOS App – Product Requirements Document

## 1. Introduction / Overview
Knowledge workers often lose focus when juggling many small tasks across multiple apps and browser tabs. "**Focus To-Do**" is a lightweight macOS application that keeps the **single, highest-priority unfinished task** visible at the very top of the screen at all times. By surfacing just one next action in an unobtrusive, always-on-top bar, the app gently guides users back to what matters whenever they drift.

## 2. Goals
| ID | Goal | Metric |
|----|------|--------|
| G-1 | Help users stay focused on the most important task | ≥ 1 launch per working day (7-day rolling average) |
| G-2 | Reduce context-switching friction (time to check next task) | Median time to view current focus ≤ 1 s |
| G-3 | Provide a distraction-free task manager | ≥ 4★ average rating in first three months on Mac App Store |

## 3. User Stories
| As a… | I want to… | So that… |
|-------|-----------|----------|
| Knowledge worker | quickly see my current priority task at the top of the screen | I can refocus after an interruption |
| Knowledge worker | create a new task with an optional due date and notes | I can capture work as it arises |
| Knowledge worker | hide or reveal task notes | I can declutter the list when I only need high-level items |
| Knowledge worker | reorder tasks manually | I can set a priority that differs from due-date order |
| Knowledge worker | mark a task complete | the next task automatically becomes my focus |
| Knowledge worker | review completed tasks later | I have a record of what I finished |

## 4. Functional Requirements
1. **Task CRUD** – The system **must** let users *create, read, update, delete* tasks with these fields:
   * Title (required, plain text)
   * Notes (optional, rich text)
   * Due date (optional, date only)
2. **Notes toggle** – Users **must** be able to toggle note visibility for *all* tasks with a single control (e.g., \"Hide notes\").
3. **Auto-sorting** – When enabled (default), tasks **must** auto-sort by ascending due date; tasks without due dates appear below dated tasks. Manual drag-and-drop re-ordering overrides sort until re-enabled.
4. **Completion & archive**
   1. When a task is marked complete, it **must** move to an *Archived* list hidden by default.
   2. The next highest-priority unfinished task **must** populate the always-on-top bar.
5. **Always-on-top bar**
   * Fixed height ≤ 28 pt; width equals screen width; anchored topmost on all virtual desktops.
   * Displays the current focus task title (ellipsized if necessary) and an opacity slider.
   * Opacity range 20 % – 100 %. Changes persist between launches.
6. **Editing window** – A separate resizable SwiftUI window opened from the bar:
   * List of tasks with inline controls to add, delete, reorder, toggle notes visibility, and edit fields.
   * Archived tasks accessible via a segmented control or secondary tab.
7. **Data persistence** – All task data **must** be stored locally using Core Data (SQLite backend). Data model design **must** avoid platform-specific keys or APIs that would block future CloudKit sync.
8. **Dark/Light mode** – UI **must** adopt system appearance automatically and respect Accessibility font scaling.
9. **Platform & startup**
   * Runs on macOS 15.0+ (Sonoma successor).
   * Does **not** auto-launch at login unless the user enables it later (future enhancement).

## 5. Non-Goals (Out of Scope)
* Cloud sync or user accounts
* Import/export or backup features
* Recurring tasks, subtasks, tagging, projects, or collaboration
* Notifications or reminders
* Global hotkeys or quick-add shortcuts
* Auto-hide/collapse bar resizing
* Support for > 200 concurrent tasks (no pagination/virtual scrolling in v1)

## 6. Design Considerations
* **Visual style:** Follow Apple Human Interface Guidelines; use SF Symbols; minimal chrome; translucent background (`.ultraThinMaterial`) for bar at 80 % opacity by default.
* **Animation:** Subtle fade when task focus changes to avoid distraction.
* **Accessibility:** VoiceOver labels for all controls; high-contrast compatibility.

## 7. Technical Considerations
* **Swift 6.1 + SwiftUI**
* **App Sandbox** enabled; store Core Data in `~/Library/Containers/...`
* **NSWindow.Level.statusBar** (or higher) to pin bar above all other windows.
* MVVM architecture with a `TaskRepository` protocol to enable future CloudKit implementation via dependency injection.

## 8. Success Metrics
* **Daily Active Users (DAU):** 70 % of installs opening the app at least once per workday (Mon–Fri) after 30 days.
* **Retention (Day 30):** ≥ 50 %.
* **Focus interaction rate:** ≥ 5 bar visibility checks per user per day (proxy for refocus events).

## 9. Open Questions
1. Should tasks without due dates default to bottom or top when auto-sort is enabled?
2. How should the app behave on multi-monitor setups—mirror the bar on each display or choose the main display only?
3. Are there privacy/security requirements (e.g., encrypt local DB) for enterprise distribution?
4. Is there a preferred icon style or branding asset set?
"""


