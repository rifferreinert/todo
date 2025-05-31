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
        XCTAssertEqual(task.notes, "Notes")
        XCTAssertFalse(task.isCompleted)
        XCTAssertNotNil(task.id)
        XCTAssertNotNil(task.createdAt)
        XCTAssertNotNil(task.updatedAt)
    }

    /// Test that creating a task with an empty title throws an error.
    func testCreateTaskWithEmptyTitleThrows() async {
        await XCTAssertThrowsErrorAsync {
            _ = try await repository.createTask(title: "", notes: nil, dueDate: nil)
        }
    }

    /// Test updating a task's title and verifying the update.
    func testUpdateTask() async throws {
        let original = try await repository.createTask(title: "To Update", notes: nil, dueDate: nil)
        let updatedDTO = TaskDTO(
            id: original.id,
            title: "Updated",
            notes: original.notes,
            dueDate: original.dueDate,
            isCompleted: original.isCompleted,
            order: original.order,
            createdAt: original.createdAt,
            updatedAt: Date()
        )
        try await repository.updateTask(updatedDTO)
        let tasks = try await repository.fetchAllActiveTasks()
        XCTAssertTrue(tasks.contains(where: { $0.title == "Updated" }))
    }

    /// Test deleting a single task among several and ensuring only the desired task is deleted.
    func testDeleteTask() async throws {
        let task1 = try await repository.createTask(title: "Task 1", notes: nil, dueDate: nil)
        let task2 = try await repository.createTask(title: "Task 2", notes: nil, dueDate: nil)
        let task3 = try await repository.createTask(title: "Task 3", notes: nil, dueDate: nil)
        try await repository.deleteTask(task2)
        let tasks = try await repository.fetchAllActiveTasks()
        let titles = tasks.map { $0.title }
        XCTAssertTrue(titles.contains("Task 1"))
        XCTAssertTrue(titles.contains("Task 3"))
        XCTAssertFalse(titles.contains("Task 2"))
        XCTAssertEqual(tasks.count, 2)
    }

    /// Test fetching all active and archived tasks.
    func testFetchAllActiveAndArchivedTasks() async throws {
        let active = try await repository.createTask(title: "Active", notes: nil, dueDate: nil)
        let completed = try await repository.createTask(title: "Completed", notes: nil, dueDate: nil)
        _ = try await repository.markTaskComplete(completed)
        let activeTasks = try await repository.fetchAllActiveTasks()
        let archivedTasks = try await repository.fetchAllArchivedTasks()
        XCTAssertTrue(activeTasks.contains(where: { $0.title == "Active" }))
        XCTAssertTrue(archivedTasks.contains(where: { $0.title == "Completed" }))
    }

    /// Test fetching tasks sorted by due date, created date, title, and manual order.
    func testFetchTasksSorted() async throws {
        let now = Date()
        let later = now.addingTimeInterval(3600)
        let muchLater = now.addingTimeInterval(7200)
        let t1 = try await repository.createTask(title: "Task 1", notes: nil, dueDate: muchLater)
        let t2 = try await repository.createTask(title: "Task 2", notes: nil, dueDate: now)
        let t3 = try await repository.createTask(title: "Task 3", notes: nil, dueDate: later)
        // By due date ascending
        let byDueDate = try await repository.fetchTasksSorted(by: .dueDate(ascending: true))
        XCTAssertEqual(byDueDate.map { $0.title }, ["Task 2", "Task 3", "Task 1"])
        // By created date ascending
        let byCreated = try await repository.fetchTasksSorted(by: .createdDate(ascending: true))
        XCTAssertEqual(byCreated.map { $0.title }, [t1.title, t2.title, t3.title])
        // By title ascending
        let byTitle = try await repository.fetchTasksSorted(by: .title(ascending: true))
        XCTAssertEqual(byTitle.map { $0.title }, ["Task 1", "Task 2", "Task 3"])
        // By manual order (default order is creation order: t1, t2, t3)
        var reordered = [t3, t1, t2]
        try await repository.reorderTasks(reordered)
        let byManual = try await repository.fetchTasksSorted(by: .manualOrder)
        XCTAssertEqual(byManual.map { $0.title }, ["Task 3", "Task 1", "Task 2"])
        // Assert the order property is set as expected after reordering
        XCTAssertEqual(byManual[0].order, 0)
        XCTAssertEqual(byManual[1].order, 1)
        XCTAssertEqual(byManual[2].order, 2)
    }

    /// Test marking a task as complete and then as active.
    func testMarkTaskCompleteAndActive() async throws {
        let task = try await repository.createTask(title: "To Complete", notes: nil, dueDate: nil)
        let completed = try await repository.markTaskComplete(task)
        XCTAssertTrue(completed.isCompleted)
        let active = try await repository.markTaskActive(completed)
        XCTAssertFalse(active.isCompleted)
    }

    /// Test reordering tasks and verifying the new order.
    func testReorderTasks() async throws {
        let t1 = try await repository.createTask(title: "A", notes: nil, dueDate: nil)
        let t2 = try await repository.createTask(title: "B", notes: nil, dueDate: nil)
        let t3 = try await repository.createTask(title: "C", notes: nil, dueDate: nil)
        let reordered = [t3, t1, t2]
        try await repository.reorderTasks(reordered)
        let tasks = try await repository.fetchTasksSorted(by: .manualOrder)
        XCTAssertEqual(tasks.map { $0.title }, ["C", "A", "B"])
    }

    /// Test deleting all completed tasks.
    func testDeleteAllCompletedTasks() async throws {
        let t1 = try await repository.createTask(title: "Active", notes: nil, dueDate: nil)
        let t2 = try await repository.createTask(title: "Done", notes: nil, dueDate: nil)
        _ = try await repository.markTaskComplete(t2)
        let deletedCount = try await repository.deleteAllCompletedTasks()
        XCTAssertEqual(deletedCount, 1)
        let archived = try await repository.fetchAllArchivedTasks()
        XCTAssertTrue(archived.isEmpty)
    }

    /// Test getting the count of active and archived tasks.
    func testGetActiveAndArchivedTaskCount() async throws {
        let t1 = try await repository.createTask(title: "Active", notes: nil, dueDate: nil)
        let t2 = try await repository.createTask(title: "Done", notes: nil, dueDate: nil)
        _ = try await repository.markTaskComplete(t2)
        let activeCount = try await repository.getActiveTaskCount()
        let archivedCount = try await repository.getArchivedTaskCount()
        XCTAssertEqual(activeCount, 1)
        XCTAssertEqual(archivedCount, 1)
    }

    /// Test fetching the next focus task (should be the first active task).
    func testFetchNextFocusTask() async throws {
        let t1 = try await repository.createTask(title: "First", notes: nil, dueDate: nil)
        let t2 = try await repository.createTask(title: "Second", notes: nil, dueDate: nil)
        let focus = try await repository.fetchNextFocusTask()
        XCTAssertEqual(focus?.title, "First")
    }

    /// Test updating a non-existent task throws an error.
    func testUpdateNonExistentTaskThrows() async {
        let fake = TaskDTO(
            id: UUID(),
            title: "Fake",
            notes: nil,
            dueDate: nil,
            isCompleted: false,
            order: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        await XCTAssertThrowsErrorAsync {
            try await repository.updateTask(fake)
        }
    }

    /// Test deleting a non-existent task throws an error.
    func testDeleteNonExistentTaskThrows() async {
        let fake = TaskDTO(
            id: UUID(),
            title: "Fake",
            notes: nil,
            dueDate: nil,
            isCompleted: false,
            order: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        await XCTAssertThrowsErrorAsync {
            try await repository.deleteTask(fake)
        }
    }

    /// Test marking a non-existent task as complete throws an error.
    func testMarkNonExistentTaskCompleteThrows() async {
        let fake = TaskDTO(
            id: UUID(),
            title: "Fake",
            notes: nil,
            dueDate: nil,
            isCompleted: false,
            order: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        await XCTAssertThrowsErrorAsync {
            _ = try await repository.markTaskComplete(fake)
        }
    }

    /// Test marking a non-existent task as active throws an error.
    func testMarkNonExistentTaskActiveThrows() async {
        let fake = TaskDTO(
            id: UUID(),
            title: "Fake",
            notes: nil,
            dueDate: nil,
            isCompleted: true,
            order: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        await XCTAssertThrowsErrorAsync {
            _ = try await repository.markTaskActive(fake)
        }
    }

    /// Test reordering with an invalid task throws an error.
    func testReorderWithInvalidTaskThrows() async {
        let t1 = try await repository.createTask(title: "A", notes: nil, dueDate: nil)
        let fake = TaskDTO(
            id: UUID(),
            title: "Fake",
            notes: nil,
            dueDate: nil,
            isCompleted: false,
            order: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        await XCTAssertThrowsErrorAsync {
            try await repository.reorderTasks([t1, fake])
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
