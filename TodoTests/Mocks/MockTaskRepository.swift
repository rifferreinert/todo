import Foundation
@testable import Todo

/// A mock implementation of TaskRepository for unit testing.
final class MockTaskRepository: TaskRepository {
    struct MockError: Error {}
    var shouldFail = false
    var lastSavedTask: Task?

    func createTask(title: String, notes: String?, dueDate: Date?) async throws -> Task {
        if shouldFail { throw MockError() }
        let context = PersistenceController.preview.container.viewContext
        let task = Task(context: context)
        task.title = title
        task.notes = notes
        task.dueDate = dueDate
        task.isCompleted = false
        task.order = 0
        task.createdAt = Date()
        task.updatedAt = Date()
        lastSavedTask = task
        return task
    }
    func updateTask(_ task: Task) async throws {
        if shouldFail { throw MockError() }
        lastSavedTask = task
    }
    func deleteTask(_ task: Task) async throws { }
    func fetchAllActiveTasks() async throws -> [Task] { return [] }
    func fetchAllArchivedTasks() async throws -> [Task] { return [] }
    func fetchTasksSorted(by sortOrder: TaskSortOrder) async throws -> [Task] { return [] }
    func fetchNextFocusTask() async throws -> Task? { return nil }
    func markTaskComplete(_ task: Task) async throws -> Task { return task }
    func markTaskActive(_ task: Task) async throws -> Task { return task }
    func reorderTasks(_ tasks: [Task]) async throws { }
    func deleteAllCompletedTasks() async throws -> Int { return 0 }
    func getActiveTaskCount() async throws -> Int { return 0 }
    func getArchivedTaskCount() async throws -> Int { return 0 }
}
