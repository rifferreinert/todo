import Foundation
@testable import Todo

/// A mock implementation of TaskRepository for unit testing.
final class MockTaskRepository: TaskRepository {
    struct MockError: Error {}
    var shouldFail = false
    /// The last saved task, stored as a MockTask for test inspection.
    private var lastSavedTask: MockTask?
    // In-memory storage for tasks as MockTask
    var tasks: [MockTask] = []

    /// Returns the last saved task as a TaskDTO, or nil if none.
    var lastSavedTaskDTO: TaskDTO? {
        lastSavedTask?.toDTO()
    }

    func createTask(title: String, notes: String?, dueDate: Date?) async throws -> TaskDTO {
        if shouldFail { throw MockError() }
        let mock = MockTask(
            id: UUID(),
            title: title,
            notes: notes,
            dueDate: dueDate,
            isCompleted: false,
            order: tasks.count,
            createdAt: Date(),
            updatedAt: Date()
        )
        tasks.append(mock)
        lastSavedTask = mock
        return mock.toDTO()
    }
    func updateTask(_ task: TaskDTO) async throws {
        if shouldFail { throw MockError() }
        if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
            let mock = MockTask(from: task)
            tasks[idx] = mock
            lastSavedTask = mock
        }
    }
    func deleteTask(_ task: TaskDTO) async throws {
        if shouldFail { throw MockError() }
        tasks.removeAll { $0.id == task.id }
    }
    func fetchAllActiveTasks() async throws -> [TaskDTO] {
        if shouldFail { throw MockError() }
        return tasks.filter { !$0.isCompleted }.map { $0.toDTO() }
    }
    func fetchAllArchivedTasks() async throws -> [TaskDTO] {
        if shouldFail { throw MockError() }
        return tasks.filter { $0.isCompleted }.map { $0.toDTO() }
    }
    func fetchTasksSorted(by sortOrder: TaskSortOrder) async throws -> [TaskDTO] {
        if shouldFail { throw MockError() }
        let sorted: [MockTask]
        switch sortOrder {
        case .manualOrder:
            sorted = tasks.sorted { $0.order < $1.order }
        case .dueDate(let ascending):
            sorted = tasks.sorted {
                switch ($0.dueDate, $1.dueDate) {
                case let (d0?, d1?): return ascending ? d0 < d1 : d0 > d1
                case (nil, _?): return false
                case (_?, nil): return true
                case (nil, nil): return ascending ? $0.order < $1.order : $0.order > $1.order
                }
            }
        case .createdDate(let ascending):
            sorted = tasks.sorted { ascending ? $0.createdAt < $1.createdAt : $0.createdAt > $1.createdAt }
        case .title(let ascending):
            sorted = tasks.sorted { ascending ? $0.title < $1.title : $0.title > $1.title }
        }
        return sorted.map { $0.toDTO() }
    }
    func fetchNextFocusTask() async throws -> TaskDTO? {
        if shouldFail { throw MockError() }
        return tasks.filter { !$0.isCompleted }.sorted { $0.order < $1.order }.first?.toDTO()
    }
    func markTaskComplete(_ task: TaskDTO) async throws -> TaskDTO {
        if shouldFail { throw MockError() }
        if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
            var completed = tasks[idx]
            completed.isCompleted = true
            tasks[idx] = completed
            return completed.toDTO()
        }
        throw MockError()
    }
    func markTaskActive(_ task: TaskDTO) async throws -> TaskDTO {
        if shouldFail { throw MockError() }
        if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
            var active = tasks[idx]
            active.isCompleted = false
            tasks[idx] = active
            return active.toDTO()
        }
        throw MockError()
    }
    func reorderTasks(_ newOrder: [TaskDTO]) async throws {
        if shouldFail { throw MockError() }
        for (idx, task) in newOrder.enumerated() {
            if let i = tasks.firstIndex(where: { $0.id == task.id }) {
                var updated = tasks[i]
                updated.order = idx
                tasks[i] = updated
            }
        }
        // Re-sort tasks array to match new order
        tasks.sort { $0.order < $1.order }
    }
    func deleteAllCompletedTasks() async throws -> Int {
        if shouldFail { throw MockError() }
        let before = tasks.count
        tasks.removeAll { $0.isCompleted }
        return before - tasks.count
    }
    func getActiveTaskCount() async throws -> Int {
        if shouldFail { throw MockError() }
        return tasks.filter { !$0.isCompleted }.count
    }
    func getArchivedTaskCount() async throws -> Int {
        if shouldFail { throw MockError() }
        return tasks.filter { $0.isCompleted }.count
    }
}

// MARK: - MockTask <-> TaskDTO conversion helpers

private extension MockTask {
    init(from dto: TaskDTO) {
        self.id = dto.id
        self.title = dto.title
        self.notes = dto.notes
        self.dueDate = dto.dueDate
        self.isCompleted = dto.isCompleted
        self.order = Int(dto.order)
        self.createdAt = dto.createdAt
        self.updatedAt = dto.updatedAt
    }
    func toDTO() -> TaskDTO {
        TaskDTO(
            id: id,
            title: title,
            notes: notes,
            dueDate: dueDate,
            isCompleted: isCompleted,
            order: Int32(order),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - Test Helper for Setting Tasks

extension MockTaskRepository {
    /// Sets the internal tasks array from an array of TaskDTOs (for test setup convenience).
    func setTasks(from dtos: [TaskDTO]) {
        self.tasks = dtos.map { MockTask(from: $0) }
    }
}
