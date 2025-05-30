import XCTest
@testable import Todo

final class CoreDataTaskRepositoryTests: XCTestCase {
    var repository: CoreDataTaskRepository!
    var persistenceController: PersistenceController!

    override func setUp() {
        super.setUp()
        // Use an in-memory store for testing
        persistenceController = PersistenceController(inMemory: true)
        repository = CoreDataTaskRepository(context: persistenceController.container.newBackgroundContext())
    }

    override func tearDown() {
        repository = nil
        persistenceController = nil
        super.tearDown()
    }

    /// Test creating a task and verifying its properties.
    func testCreateTask() async throws {
        let task = try await repository.createTask(title: "Test", notes: "Notes", dueDate: nil)
        XCTAssertEqual(task.title, "Test")
        XCTAssertFalse(task.isCompleted)
    }

    /// Test fetching tasks sorted by due date, with due dates uncorrelated to creation order.
    func testFetchTasksSortedByDueDate() async throws {
        let now = Date()
        let later = now.addingTimeInterval(3600)
        let muchLater = now.addingTimeInterval(7200)
        // Create tasks in a different order than their due dates
        _ = try await repository.createTask(title: "Task 1", notes: nil, dueDate: muchLater)
        _ = try await repository.createTask(title: "Task 2", notes: nil, dueDate: now)
        _ = try await repository.createTask(title: "Task 3", notes: nil, dueDate: later)
        let tasks = try await repository.fetchTasks(sortedBy: .dueDate)
        XCTAssertEqual(tasks.map { $0.title }, ["Task 2", "Task 3", "Task 1"])
    }

    /// Test updating a task's title and verifying the update.
    func testUpdateTask() async throws {
        var task = try await repository.createTask(title: "To Update", notes: nil, dueDate: nil)
        task.title = "Updated"
        let updated = try await repository.updateTask(task)
        XCTAssertEqual(updated.title, "Updated")
    }

    /// Test deleting a single task among several and ensuring only the desired task is deleted.
    func testDeleteTask() async throws {
        let task1 = try await repository.createTask(title: "Task 1", notes: nil, dueDate: nil)
        let task2 = try await repository.createTask(title: "Task 2", notes: nil, dueDate: nil)
        let task3 = try await repository.createTask(title: "Task 3", notes: nil, dueDate: nil)
        try await repository.deleteTask(task2)
        let tasks = try await repository.fetchTasks(sortedBy: .createdAt)
        let titles = tasks.map { $0.title }
        XCTAssertTrue(titles.contains("Task 1"))
        XCTAssertTrue(titles.contains("Task 3"))
        XCTAssertFalse(titles.contains("Task 2"))
        XCTAssertEqual(tasks.count, 2)
    }

    /// Test that creating a task with an empty title throws an error.
    func testCreateTaskWithEmptyTitleThrows() async {
        await XCTAssertThrowsErrorAsync { [self] in
            _ = try await repository.createTask(title: "", notes: nil, dueDate: nil)
        }
    }
}

// Helper for async error assertion
func XCTAssertThrowsErrorAsync(_ expression: @escaping () async throws -> Void) async {
    do {
        try await expression()
        XCTFail("Expected error but got none")
    } catch {
        // Success
    }
}
