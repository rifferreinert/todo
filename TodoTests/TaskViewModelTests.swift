import XCTest
import Combine
@testable import Todo

/// Unit tests for TaskViewModel presentation logic and validation.
final class TaskViewModelTests: XCTestCase {
    var cancellables: Set<AnyCancellable> = []
    var mockRepository: MockTaskRepository!
    var sampleTask: Task!

    override func setUp() {
        super.setUp()
        mockRepository = MockTaskRepository()
        sampleTask = Task(
            id: UUID(),
            title: "Sample Task",
            notes: "Some notes",
            dueDate: Date().addingTimeInterval(3600),
            isCompleted: false,
            order: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
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

    func testTaskDeletedExternallyDisablesEditing() {
        let vm = TaskViewModel(task: sampleTask, repository: mockRepository)
        vm.handleTaskDeleted()
        XCTAssertTrue(vm.isEditingDisabled)
    }
}

// MARK: - Helpers

private class MockTaskRepository: TaskRepository {
    struct MockError: Error {}
    var shouldFail = false
    var lastSavedTask: Task?

    func save(_ task: Task) async throws {
        if shouldFail { throw MockError() }
        lastSavedTask = task
    }
    // ...other protocol methods as needed...
}

private struct Task: Equatable {
    let id: UUID
    var title: String
    var notes: String?
    var dueDate: Date?
    var isCompleted: Bool
    var order: Int
    var createdAt: Date
    var updatedAt: Date
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
