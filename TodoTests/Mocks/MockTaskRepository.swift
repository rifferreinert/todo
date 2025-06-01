import Foundation
@testable import Todo

/// A mock implementation of TaskRepository for unit testing.
final class MockTaskRepository: TaskRepository {
    struct MockError: Error {}
    var shouldFail = false
    var lastSavedTask: TaskDTO?

    func createTask(title: String, notes: String?, dueDate: Date?) async throws -> TaskDTO {
        if shouldFail { throw MockError() }
        let task = TaskDTO(
            id: UUID(),
            title: title,
            notes: notes,
            dueDate: dueDate,
            isCompleted: false,
            order: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        lastSavedTask = task
        return task
    }
    func updateTask(_ task: TaskDTO) async throws {
        if shouldFail { throw MockError() }
        lastSavedTask = task
    }
    func deleteTask(_ task: TaskDTO) async throws { }
    func fetchAllActiveTasks() async throws -> [TaskDTO] { return [] }
    func fetchAllArchivedTasks() async throws -> [TaskDTO] { return [] }
    func fetchTasksSorted(by sortOrder: TaskSortOrder) async throws -> [TaskDTO] { return [] }
    func fetchNextFocusTask() async throws -> TaskDTO? { return nil }
    func markTaskComplete(_ task: TaskDTO) async throws -> TaskDTO { return task }
    func markTaskActive(_ task: TaskDTO) async throws -> TaskDTO { return task }
    func reorderTasks(_ tasks: [TaskDTO]) async throws { }
    func deleteAllCompletedTasks() async throws -> Int { return 0 }
    func getActiveTaskCount() async throws -> Int { return 0 }
    func getArchivedTaskCount() async throws -> Int { return 0 }
}
