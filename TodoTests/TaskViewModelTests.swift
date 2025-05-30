import XCTest
import Combine
@testable import Todo

/// Unit tests for TaskViewModel presentation logic and validation.
final class TaskViewModelTests: XCTestCase {
    var cancellables: Set<AnyCancellable> = []
    fileprivate var mockRepository: MockTaskRepository!
    fileprivate var sampleTask: Task!

    override func setUp() {
        super.setUp()
        mockRepository = MockTaskRepository()
        // Use Core Data Task entity for sampleTask
        let context = PersistenceController.preview.container.viewContext
        let task = Task(context: context)
        task.title = "Sample Task"
        task.notes = "Some notes"
        task.dueDate = Date().addingTimeInterval(3600)
        task.isCompleted = false
        task.order = 0
        task.createdAt = Date()
        task.updatedAt = Date()
        sampleTask = task
    }

    override func tearDown() {
        cancellables.removeAll()
        mockRepository = nil
        sampleTask = nil
        super.tearDown()
    }

    func testInitialValuesReflectTask() {
        let vm = TaskViewModel(task: sampleTask, repository: mockRepository)
        XCTAssertEqual(vm.title, sampleTask.title)
        XCTAssertEqual(vm.notes, sampleTask.notes)
        XCTAssertEqual(vm.dueDate, sampleTask.dueDate)
        XCTAssertEqual(vm.isCompleted, sampleTask.isCompleted)
    }

    func testUpdateTitlePersistsAndPublishes() async throws {
        let vm = TaskViewModel(task: sampleTask, repository: mockRepository)
        let newTitle = "Updated Title"
        try await vm.updateTitle(newTitle)
        XCTAssertEqual(vm.title, newTitle)
        XCTAssertEqual(mockRepository.lastSavedTask?.title, newTitle)
    }

    func testUpdateWithEmptyTitleThrowsValidationError() async {
        let vm = TaskViewModel(task: sampleTask, repository: mockRepository)
        await XCTAssertThrowsErrorAsync(try await vm.updateTitle("   ")) { error in
            guard let err = error as? TaskViewModel.ValidationError else { return XCTFail() }
            XCTAssertEqual(err, .emptyTitle)
        }
    }

    func testUpdateDueDatePersists() async throws {
        let vm = TaskViewModel(task: sampleTask, repository: mockRepository)
        let newDate = Date().addingTimeInterval(7200)
        try await vm.updateDueDate(newDate)
        XCTAssertEqual(vm.dueDate, newDate)
        XCTAssertEqual(mockRepository.lastSavedTask?.dueDate, newDate)
    }

    func testRepositorySaveFailureSurfacesError() async {
        let vm = TaskViewModel(task: sampleTask, repository: mockRepository)
        mockRepository.shouldFail = true
        await XCTAssertThrowsErrorAsync(try await vm.updateTitle("New Title")) { error in
            XCTAssertTrue(error is MockTaskRepository.MockError)
        }
    }

    @MainActor
    func testTaskDeletedExternallyDisablesEditing() {
        let vm = TaskViewModel(task: sampleTask, repository: mockRepository)
        vm.handleTaskDeleted()
        XCTAssertTrue(vm.isEditingDisabled)
    }
}

// MARK: - Helpers

fileprivate class MockTaskRepository: TaskRepository {
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

// Async throws helper for XCTest
func XCTAssertThrowsErrorAsync<T>(_ expression: @autoclosure @escaping () async throws -> T, _ message: @escaping (Error) -> Void) async {
    do {
        _ = try await expression()
        XCTFail("Expected error but got success")
    } catch {
        message(error)
    }
}
