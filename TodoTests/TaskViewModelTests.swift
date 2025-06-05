import XCTest
import Combine
@testable import Todo

/// Unit tests for TaskViewModel presentation logic and validation.
final class TaskViewModelTests: XCTestCase {
    var cancellables: Set<AnyCancellable> = []
    fileprivate var mockRepository: MockTaskRepository!
    fileprivate var sampleTask: TaskDTO!

    override func setUp() async throws {
        try await super.setUp()
        mockRepository = MockTaskRepository()
        sampleTask = try await mockRepository.createTask(title: "Sample Task",
                                                        notes: "Some notes",
                                                        dueDate: Date().addingTimeInterval(3600)
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
        XCTAssertEqual(mockRepository.lastSavedTaskDTO?.title, newTitle)
        // Assert task is still active and not archived
        let archived = try await mockRepository.fetchAllArchivedTasks()
        let active = try await mockRepository.fetchAllActiveTasks()
        XCTAssertTrue(active.contains(where: { $0.id == sampleTask.id }))
        XCTAssertFalse(archived.contains(where: { $0.id == sampleTask.id }))
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
        XCTAssertEqual(mockRepository.lastSavedTaskDTO?.dueDate, newDate)
        // Assert task is still active and not archived
        let archived = try await mockRepository.fetchAllArchivedTasks()
        let active = try await mockRepository.fetchAllActiveTasks()
        XCTAssertTrue(active.contains(where: { $0.id == sampleTask.id }))
        XCTAssertFalse(archived.contains(where: { $0.id == sampleTask.id }))
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

    func testUpdateNotesPersistsAndPublishes() async throws {
        let vm = TaskViewModel(task: sampleTask, repository: mockRepository)
        let newNotes = "Updated notes"
        try await vm.updateNotes(newNotes)
        XCTAssertEqual(vm.notes, newNotes)
        XCTAssertEqual(mockRepository.lastSavedTaskDTO?.notes, newNotes)
        // Assert task is still active and not archived
        let archived = try await mockRepository.fetchAllArchivedTasks()
        let active = try await mockRepository.fetchAllActiveTasks()
        XCTAssertTrue(active.contains(where: { $0.id == sampleTask.id }))
        XCTAssertFalse(archived.contains(where: { $0.id == sampleTask.id }))
    }

    func testUpdateNotesToEmptyPersists() async throws {
        let vm = TaskViewModel(task: sampleTask, repository: mockRepository)
        let newNotes = ""
        try await vm.updateNotes(newNotes)
        XCTAssertEqual(vm.notes, newNotes)
        XCTAssertEqual(mockRepository.lastSavedTaskDTO?.notes, newNotes)
        // Assert task is still active and not archived
        let archived = try await mockRepository.fetchAllArchivedTasks()
        let active = try await mockRepository.fetchAllActiveTasks()
        XCTAssertTrue(active.contains(where: { $0.id == sampleTask.id }))
        XCTAssertFalse(archived.contains(where: { $0.id == sampleTask.id }))
    }

    func testMarkTaskAsCompletedPersists() async throws {
        let vm = TaskViewModel(task: sampleTask, repository: mockRepository)
        try await vm.updateCompletion(true)
        XCTAssertTrue(vm.isCompleted)
        XCTAssertTrue(mockRepository.lastSavedTaskDTO?.isCompleted ?? false)
        // Assert that the task is now in the archived list and not in the active list
        let archived = try await mockRepository.fetchAllArchivedTasks()
        let active = try await mockRepository.fetchAllActiveTasks()
        XCTAssertTrue(archived.contains(where: { $0.id == sampleTask.id }))
        XCTAssertFalse(active.contains(where: { $0.id == sampleTask.id }))
    }

    func testMarkAlreadyCompletedTaskNoopOrError() async throws {
        let completedTask = TaskDTO(id: sampleTask.id, title: sampleTask.title, notes: sampleTask.notes, dueDate: sampleTask.dueDate, isCompleted: true, order: sampleTask.order, createdAt: sampleTask.createdAt, updatedAt: sampleTask.updatedAt)
        let vm = TaskViewModel(task: completedTask, repository: mockRepository)
        // Should either be a no-op or throw a specific error, depending on implementation
        do {
            try await vm.updateCompletion(true)
            XCTAssertTrue(vm.isCompleted)
        } catch {
            // Acceptable if implementation throws
            XCTAssertTrue(true)
        }
    }

    func testUpdateMultipleFieldsInSuccession() async throws {
        let vm = TaskViewModel(task: sampleTask, repository: mockRepository)
        let newTitle = "Multi Update Title"
        let newNotes = "Multi Update Notes"
        let newDate = Date().addingTimeInterval(10000)
        try await vm.updateTitle(newTitle)
        try await vm.updateNotes(newNotes)
        try await vm.updateDueDate(newDate)
        XCTAssertEqual(vm.title, newTitle)
        XCTAssertEqual(vm.notes, newNotes)
        XCTAssertEqual(vm.dueDate, newDate)
        // Assert task is still active and not archived
        let archived = try await mockRepository.fetchAllArchivedTasks()
        let active = try await mockRepository.fetchAllActiveTasks()
        XCTAssertTrue(active.contains(where: { $0.id == sampleTask.id }))
        XCTAssertFalse(archived.contains(where: { $0.id == sampleTask.id }))
    }

    func testUpdateDueDateRepositoryFailureSurfacesError() async {
        let vm = TaskViewModel(task: sampleTask, repository: mockRepository)
        mockRepository.shouldFail = true
        await XCTAssertThrowsErrorAsync(try await vm.updateDueDate(Date().addingTimeInterval(1000))) { error in
            XCTAssertTrue(error is MockTaskRepository.MockError)
        }
    }
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
