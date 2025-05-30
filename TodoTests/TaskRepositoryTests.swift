//
//  TaskRepositoryTests.swift
//  TodoTests
//
//  Created by Ben Xia-Reinert on 5/29/25.
//

import Testing
import Foundation
@testable import Todo

// MARK: - Mock Task Repository Implementation

/// Mock implementation of TaskRepository for testing
class MockTaskRepository: TaskRepository {

    // Storage for mock data
    private var tasks: [MockTask] = []
    private var nextId: Int = 1

    // Configuration for testing error scenarios
    var shouldFailOnCreate = false
    var shouldFailOnUpdate = false
    var shouldFailOnDelete = false
    var shouldFailOnFetch = false

    // MARK: - Basic CRUD Operations

    func createTask(title: String, notes: String?, dueDate: Date?) async throws -> Task {
        if shouldFailOnCreate {
            throw TaskRepositoryError.persistenceFailure("Mock failure")
        }

        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TaskRepositoryError.invalidTaskData("Title cannot be empty")
        }

        let mockTask = MockTask(
            id: nextId,
            title: title,
            notes: notes,
            dueDate: dueDate,
            isCompleted: false,
            order: Int32(tasks.count),
            createdAt: Date(),
            updatedAt: Date()
        )

        nextId += 1
        tasks.append(mockTask)
        return mockTask
    }

    func updateTask(_ task: Task) async throws {
        if shouldFailOnUpdate {
            throw TaskRepositoryError.persistenceFailure("Mock failure")
        }

        guard let mockTask = task as? MockTask,
              let index = tasks.firstIndex(where: { $0.id == mockTask.id }) else {
            throw TaskRepositoryError.taskNotFound
        }

        tasks[index] = mockTask
        tasks[index].updatedAt = Date()
    }

    func deleteTask(_ task: Task) async throws {
        if shouldFailOnDelete {
            throw TaskRepositoryError.persistenceFailure("Mock failure")
        }

        guard let mockTask = task as? MockTask,
              let index = tasks.firstIndex(where: { $0.id == mockTask.id }) else {
            throw TaskRepositoryError.taskNotFound
        }

        tasks.remove(at: index)
    }

    // MARK: - Query Operations

    func fetchAllActiveTasks() async throws -> [Task] {
        if shouldFailOnFetch {
            throw TaskRepositoryError.persistenceFailure("Mock failure")
        }
        return tasks.filter { !$0.isCompleted }
    }

    func fetchAllArchivedTasks() async throws -> [Task] {
        if shouldFailOnFetch {
            throw TaskRepositoryError.persistenceFailure("Mock failure")
        }
        return tasks.filter { $0.isCompleted }
    }

    func fetchTasksSorted(by sortOrder: TaskSortOrder) async throws -> [Task] {
        if shouldFailOnFetch {
            throw TaskRepositoryError.persistenceFailure("Mock failure")
        }

        switch sortOrder {
        case .dueDate(let ascending):
            return tasks.sorted { lhs, rhs in
                // Tasks with due dates come first, then tasks without
                switch (lhs.dueDate, rhs.dueDate) {
                case (.some(let date1), .some(let date2)):
                    return ascending ? date1 < date2 : date1 > date2
                case (.some, .none):
                    return true
                case (.none, .some):
                    return false
                case (.none, .none):
                    return ascending ? lhs.createdAt < rhs.createdAt : lhs.createdAt > rhs.createdAt
                }
            }
        case .createdDate(let ascending):
            return tasks.sorted { ascending ? $0.createdAt < $1.createdAt : $0.createdAt > $1.createdAt }
        case .title(let ascending):
            return tasks.sorted { ascending ? $0.title < $1.title : $0.title > $1.title }
        case .manualOrder:
            return tasks.sorted { $0.order < $1.order }
        }
    }

    func fetchNextFocusTask() async throws -> Task? {
        if shouldFailOnFetch {
            throw TaskRepositoryError.persistenceFailure("Mock failure")
        }

        let activeTasks = tasks.filter { !$0.isCompleted }
        return try await fetchTasksSorted(by: .dueDate(ascending: true)).first
    }

    // MARK: - Task State Operations

    func markTaskComplete(_ task: Task) async throws -> Task {
        guard let mockTask = task as? MockTask,
              let index = tasks.firstIndex(where: { $0.id == mockTask.id }) else {
            throw TaskRepositoryError.taskNotFound
        }

        tasks[index].isCompleted = true
        tasks[index].updatedAt = Date()
        return tasks[index]
    }

    func markTaskActive(_ task: Task) async throws -> Task {
        guard let mockTask = task as? MockTask,
              let index = tasks.firstIndex(where: { $0.id == mockTask.id }) else {
            throw TaskRepositoryError.taskNotFound
        }

        tasks[index].isCompleted = false
        tasks[index].updatedAt = Date()
        return tasks[index]
    }

    func reorderTasks(_ tasks: [Task]) async throws {
        for (index, task) in tasks.enumerated() {
            guard let mockTask = task as? MockTask,
                  let taskIndex = self.tasks.firstIndex(where: { $0.id == mockTask.id }) else {
                throw TaskRepositoryError.validationError("Invalid task in reorder array")
            }

            self.tasks[taskIndex].order = Int32(index)
            self.tasks[taskIndex].updatedAt = Date()
        }
    }

    // MARK: - Batch Operations

    func deleteAllCompletedTasks() async throws -> Int {
        let completedCount = tasks.filter { $0.isCompleted }.count
        tasks.removeAll { $0.isCompleted }
        return completedCount
    }

    func getActiveTaskCount() async throws -> Int {
        if shouldFailOnFetch {
            throw TaskRepositoryError.persistenceFailure("Mock failure")
        }
        return tasks.filter { !$0.isCompleted }.count
    }

    func getArchivedTaskCount() async throws -> Int {
        if shouldFailOnFetch {
            throw TaskRepositoryError.persistenceFailure("Mock failure")
        }
        return tasks.filter { $0.isCompleted }.count
    }
}

// MARK: - Mock Task Implementation

class MockTask: Task {
    let id: Int
    var title: String
    var notes: String?
    var dueDate: Date?
    var isCompleted: Bool
    var order: Int32
    let createdAt: Date
    var updatedAt: Date

    init(id: Int, title: String, notes: String?, dueDate: Date?, isCompleted: Bool, order: Int32, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.title = title
        self.notes = notes
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.order = order
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Test Suite

struct TaskRepositoryTests {

    // MARK: - Create Task Tests

    @Test func testCreateTaskWithValidData() async throws {
        let repository = MockTaskRepository()

        let task = try await repository.createTask(
            title: "Test Task",
            notes: "Test notes",
            dueDate: Date()
        )

        #expect(task.title == "Test Task")
        #expect(task.notes == "Test notes")
        #expect(task.dueDate != nil)
        #expect(task.isCompleted == false)
    }

    @Test func testCreateTaskWithEmptyTitle() async throws {
        let repository = MockTaskRepository()

        await #expect(throws: TaskRepositoryError.invalidTaskData("Title cannot be empty")) {
            _ = try await repository.createTask(title: "", notes: nil, dueDate: nil)
        }
    }

    @Test func testCreateTaskWithWhitespaceTitle() async throws {
        let repository = MockTaskRepository()

        await #expect(throws: TaskRepositoryError.invalidTaskData("Title cannot be empty")) {
            _ = try await repository.createTask(title: "   ", notes: nil, dueDate: nil)
        }
    }

    @Test func testCreateTaskPersistenceFailure() async throws {
        let repository = MockTaskRepository()
        repository.shouldFailOnCreate = true

        await #expect(throws: TaskRepositoryError.persistenceFailure("Mock failure")) {
            _ = try await repository.createTask(title: "Test", notes: nil, dueDate: nil)
        }
    }

    // MARK: - Update Task Tests

    @Test func testUpdateExistingTask() async throws {
        let repository = MockTaskRepository()
        let task = try await repository.createTask(title: "Original", notes: nil, dueDate: nil)

        if let mockTask = task as? MockTask {
            mockTask.title = "Updated"
            mockTask.notes = "Updated notes"

            try await repository.updateTask(mockTask)

            let activeTasks = try await repository.fetchAllActiveTasks()
            let updatedTask = activeTasks.first { $0.title == "Updated" }
            #expect(updatedTask != nil)
            #expect(updatedTask?.notes == "Updated notes")
        }
    }

    @Test func testUpdateNonExistentTask() async throws {
        let repository = MockTaskRepository()
        let mockTask = MockTask(id: 999, title: "Non-existent", notes: nil, dueDate: nil,
                               isCompleted: false, order: 0, createdAt: Date(), updatedAt: Date())

        await #expect(throws: TaskRepositoryError.taskNotFound) {
            try await repository.updateTask(mockTask)
        }
    }

    // MARK: - Delete Task Tests

    @Test func testDeleteExistingTask() async throws {
        let repository = MockTaskRepository()
        let task = try await repository.createTask(title: "To Delete", notes: nil, dueDate: nil)

        try await repository.deleteTask(task)

        let activeTasks = try await repository.fetchAllActiveTasks()
        #expect(activeTasks.isEmpty)
    }

    @Test func testDeleteNonExistentTask() async throws {
        let repository = MockTaskRepository()
        let mockTask = MockTask(id: 999, title: "Non-existent", notes: nil, dueDate: nil,
                               isCompleted: false, order: 0, createdAt: Date(), updatedAt: Date())

        await #expect(throws: TaskRepositoryError.taskNotFound) {
            try await repository.deleteTask(mockTask)
        }
    }

    // MARK: - Fetch Tasks Tests

    @Test func testFetchAllActiveTasksEmpty() async throws {
        let repository = MockTaskRepository()

        let activeTasks = try await repository.fetchAllActiveTasks()
        #expect(activeTasks.isEmpty)
    }

    @Test func testFetchAllActiveTasksWithData() async throws {
        let repository = MockTaskRepository()

        _ = try await repository.createTask(title: "Active 1", notes: nil, dueDate: nil)
        _ = try await repository.createTask(title: "Active 2", notes: nil, dueDate: nil)

        let activeTasks = try await repository.fetchAllActiveTasks()
        #expect(activeTasks.count == 2)
    }

    @Test func testFetchAllArchivedTasksEmpty() async throws {
        let repository = MockTaskRepository()

        let archivedTasks = try await repository.fetchAllArchivedTasks()
        #expect(archivedTasks.isEmpty)
    }

    @Test func testFetchAllArchivedTasksWithData() async throws {
        let repository = MockTaskRepository()

        let task1 = try await repository.createTask(title: "Task 1", notes: nil, dueDate: nil)
        let task2 = try await repository.createTask(title: "Task 2", notes: nil, dueDate: nil)

        _ = try await repository.markTaskComplete(task1)
        _ = try await repository.markTaskComplete(task2)

        let archivedTasks = try await repository.fetchAllArchivedTasks()
        #expect(archivedTasks.count == 2)
        #expect(archivedTasks.allSatisfy { $0.isCompleted })
    }

    // MARK: - Sorting Tests

    @Test func testFetchTasksSortedByDueDateAscending() async throws {
        let repository = MockTaskRepository()

        let date1 = Date()
        let date2 = Date().addingTimeInterval(86400) // +1 day
        let date3 = Date().addingTimeInterval(172800) // +2 days

        _ = try await repository.createTask(title: "Task 2", notes: nil, dueDate: date2)
        _ = try await repository.createTask(title: "Task 1", notes: nil, dueDate: date1)
        _ = try await repository.createTask(title: "Task 3", notes: nil, dueDate: date3)
        _ = try await repository.createTask(title: "No Due Date", notes: nil, dueDate: nil)

        let sortedTasks = try await repository.fetchTasksSorted(by: .dueDate(ascending: true))

        #expect(sortedTasks.count == 4)
        #expect(sortedTasks[0].title == "Task 1")
        #expect(sortedTasks[1].title == "Task 2")
        #expect(sortedTasks[2].title == "Task 3")
        #expect(sortedTasks[3].title == "No Due Date")
    }

    @Test func testFetchTasksSortedByTitleAscending() async throws {
        let repository = MockTaskRepository()

        _ = try await repository.createTask(title: "Charlie", notes: nil, dueDate: nil)
        _ = try await repository.createTask(title: "Alpha", notes: nil, dueDate: nil)
        _ = try await repository.createTask(title: "Bravo", notes: nil, dueDate: nil)

        let sortedTasks = try await repository.fetchTasksSorted(by: .title(ascending: true))

        #expect(sortedTasks.count == 3)
        #expect(sortedTasks[0].title == "Alpha")
        #expect(sortedTasks[1].title == "Bravo")
        #expect(sortedTasks[2].title == "Charlie")
    }

    // MARK: - Task State Tests

    @Test func testMarkTaskComplete() async throws {
        let repository = MockTaskRepository()
        let task = try await repository.createTask(title: "To Complete", notes: nil, dueDate: nil)

        let completedTask = try await repository.markTaskComplete(task)

        #expect(completedTask.isCompleted == true)

        let activeTasks = try await repository.fetchAllActiveTasks()
        let archivedTasks = try await repository.fetchAllArchivedTasks()

        #expect(activeTasks.isEmpty)
        #expect(archivedTasks.count == 1)
    }

    @Test func testMarkTaskActive() async throws {
        let repository = MockTaskRepository()
        let task = try await repository.createTask(title: "To Reactivate", notes: nil, dueDate: nil)

        _ = try await repository.markTaskComplete(task)
        let reactivatedTask = try await repository.markTaskActive(task)

        #expect(reactivatedTask.isCompleted == false)

        let activeTasks = try await repository.fetchAllActiveTasks()
        let archivedTasks = try await repository.fetchAllArchivedTasks()

        #expect(activeTasks.count == 1)
        #expect(archivedTasks.isEmpty)
    }

    // MARK: - Focus Task Tests

    @Test func testFetchNextFocusTaskEmpty() async throws {
        let repository = MockTaskRepository()

        let focusTask = try await repository.fetchNextFocusTask()
        #expect(focusTask == nil)
    }

    @Test func testFetchNextFocusTaskWithTasks() async throws {
        let repository = MockTaskRepository()

        let date1 = Date()
        let date2 = Date().addingTimeInterval(86400)

        _ = try await repository.createTask(title: "Later Task", notes: nil, dueDate: date2)
        _ = try await repository.createTask(title: "Earlier Task", notes: nil, dueDate: date1)

        let focusTask = try await repository.fetchNextFocusTask()
        #expect(focusTask?.title == "Earlier Task")
    }

    // MARK: - Count Tests

    @Test func testGetActiveTaskCount() async throws {
        let repository = MockTaskRepository()

        _ = try await repository.createTask(title: "Active 1", notes: nil, dueDate: nil)
        _ = try await repository.createTask(title: "Active 2", notes: nil, dueDate: nil)
        let task3 = try await repository.createTask(title: "To Complete", notes: nil, dueDate: nil)

        _ = try await repository.markTaskComplete(task3)

        let activeCount = try await repository.getActiveTaskCount()
        #expect(activeCount == 2)
    }

    @Test func testGetArchivedTaskCount() async throws {
        let repository = MockTaskRepository()

        let task1 = try await repository.createTask(title: "Task 1", notes: nil, dueDate: nil)
        let task2 = try await repository.createTask(title: "Task 2", notes: nil, dueDate: nil)
        _ = try await repository.createTask(title: "Active Task", notes: nil, dueDate: nil)

        _ = try await repository.markTaskComplete(task1)
        _ = try await repository.markTaskComplete(task2)

        let archivedCount = try await repository.getArchivedTaskCount()
        #expect(archivedCount == 2)
    }

    // MARK: - Batch Operations Tests

    @Test func testDeleteAllCompletedTasks() async throws {
        let repository = MockTaskRepository()

        let task1 = try await repository.createTask(title: "Task 1", notes: nil, dueDate: nil)
        let task2 = try await repository.createTask(title: "Task 2", notes: nil, dueDate: nil)
        _ = try await repository.createTask(title: "Active Task", notes: nil, dueDate: nil)

        _ = try await repository.markTaskComplete(task1)
        _ = try await repository.markTaskComplete(task2)

        let deletedCount = try await repository.deleteAllCompletedTasks()

        #expect(deletedCount == 2)
        #expect(try await repository.getArchivedTaskCount() == 0)
        #expect(try await repository.getActiveTaskCount() == 1)
    }

    // MARK: - Extension Method Tests

    @Test func testCreateSimpleTask() async throws {
        let repository = MockTaskRepository()

        let task = try await repository.createSimpleTask(title: "Simple Task")

        #expect(task.title == "Simple Task")
        #expect(task.notes == nil)
        #expect(task.dueDate == nil)
    }

    @Test func testHasActiveTasksTrue() async throws {
        let repository = MockTaskRepository()

        _ = try await repository.createTask(title: "Active Task", notes: nil, dueDate: nil)

        let hasActive = try await repository.hasActiveTasks()
        #expect(hasActive == true)
    }

    @Test func testHasActiveTasksFalse() async throws {
        let repository = MockTaskRepository()

        let hasActive = try await repository.hasActiveTasks()
        #expect(hasActive == false)
    }

    @Test func testHasArchivedTasksTrue() async throws {
        let repository = MockTaskRepository()

        let task = try await repository.createTask(title: "Task", notes: nil, dueDate: nil)
        _ = try await repository.markTaskComplete(task)

        let hasArchived = try await repository.hasArchivedTasks()
        #expect(hasArchived == true)
    }

    @Test func testHasArchivedTasksFalse() async throws {
        let repository = MockTaskRepository()

        let hasArchived = try await repository.hasArchivedTasks()
        #expect(hasArchived == false)
    }
}
