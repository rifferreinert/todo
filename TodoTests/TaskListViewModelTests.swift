// TodoTests/TaskListViewModelTests.swift
// Unit tests for TaskListViewModel

import XCTest
import Combine
@testable import Todo

final class TaskListViewModelTests: XCTestCase {
    var viewModel: TaskListViewModel!
    var repository: MockTaskRepository!
    var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        repository = MockTaskRepository()
        viewModel = TaskListViewModel(repository: repository)
    }

    override func tearDown() {
        viewModel = nil
        repository = nil
        cancellables.removeAll()
        super.tearDown()
    }

    /// Test that tasks are sorted by their `order` property by default
    func testTasksAreSortedByOrder() async throws {
        // Arrange
        let now = Date()
        let tasks = [
            TaskDTO(id: UUID(), title: "B", notes: nil, dueDate: nil, isCompleted: false, order: 2, createdAt: now, updatedAt: now),
            TaskDTO(id: UUID(), title: "A", notes: nil, dueDate: nil, isCompleted: false, order: 0, createdAt: now, updatedAt: now),
            TaskDTO(id: UUID(), title: "C", notes: nil, dueDate: nil, isCompleted: false, order: 1, createdAt: now, updatedAt: now)
        ]
        repository.setTasks(from: tasks)
        await viewModel.loadTasks()
        // Act
        let sortedTitles = viewModel.tasks.map { $0.title }
        // Assert
        XCTAssertEqual(sortedTitles, ["A", "C", "B"])
    }

    /// Test auto-sorting by due date (due dates first, ascending; undated last)
    func testAutoSortByDueDate() async throws {
        // Arrange
        let now = Date()
        let later = now.addingTimeInterval(3600)
        let tasks = [
            TaskDTO(id: UUID(), title: "No Due", notes: nil, dueDate: nil, isCompleted: false, order: 0, createdAt: now, updatedAt: now),
            TaskDTO(id: UUID(), title: "Soon", notes: nil, dueDate: now, isCompleted: false, order: 1, createdAt: now, updatedAt: now),
            TaskDTO(id: UUID(), title: "Later", notes: nil, dueDate: later, isCompleted: false, order: 2, createdAt: now, updatedAt: now)
        ]
        repository.setTasks(from: tasks)
        await viewModel.loadTasks()
        // Act
        await viewModel.autoSortByDueDate()
        let sortedTitles = viewModel.tasks.map { $0.title }
        // Assert
        XCTAssertEqual(sortedTitles, ["Soon", "Later", "No Due"])
    }

    /// Test manual reordering updates the `order` property
    func testManualReorderingUpdatesOrder() async throws {
        // Arrange
        let now = Date()
        let tasks = [
            TaskDTO(id: UUID(), title: "A", notes: nil, dueDate: nil, isCompleted: false, order: 0, createdAt: now, updatedAt: now),
            TaskDTO(id: UUID(), title: "B", notes: nil, dueDate: nil, isCompleted: false, order: 1, createdAt: now, updatedAt: now),
            TaskDTO(id: UUID(), title: "C", notes: nil, dueDate: nil, isCompleted: false, order: 2, createdAt: now, updatedAt: now)
        ]
        repository.setTasks(from: tasks)
        await viewModel.loadTasks()
        // Act
        await viewModel.reorderTasks([tasks[2], tasks[0], tasks[1]])
        let newOrder = viewModel.tasks.map { $0.title }
        // Assert
        XCTAssertEqual(newOrder, ["C", "A", "B"])
    }

    /// Test completing a task moves it to archive and updates focus
    func testCompletionMovesTaskToArchiveAndUpdatesFocus() async throws {
        // Arrange
        let now = Date()
        let t1 = TaskDTO(id: UUID(), title: "First", notes: nil, dueDate: nil, isCompleted: false, order: 0, createdAt: now, updatedAt: now)
        let t2 = TaskDTO(id: UUID(), title: "Second", notes: nil, dueDate: nil, isCompleted: false, order: 1, createdAt: now, updatedAt: now)
        repository.setTasks(from: [t1, t2])
        await viewModel.loadTasks()
        // Act
        await viewModel.completeTask(t1)
        // Assert
        XCTAssertTrue(viewModel.archivedTasks.contains(where: { $0.title == "First" }))
        XCTAssertEqual(viewModel.focusTask?.title, "Second")
    }

    /// Test edge case: empty list is handled gracefully
    func testEmptyListHandledGracefully() async throws {
        // Arrange
        repository.setTasks(from: [])
        await viewModel.loadTasks()
        // Assert
        XCTAssertTrue(viewModel.tasks.isEmpty)
        XCTAssertNil(viewModel.focusTask)
    }

    /// Test edge case: all tasks completed
    func testAllTasksCompleted() async throws {
        // Arrange
        let now = Date()
        let t1 = TaskDTO(id: UUID(), title: "Done", notes: nil, dueDate: nil, isCompleted: true, order: 0, createdAt: now, updatedAt: now)
        repository.setTasks(from: [t1])
        await viewModel.loadTasks()
        // Assert
        XCTAssertTrue(viewModel.tasks.isEmpty)
        XCTAssertTrue(viewModel.archivedTasks.contains(where: { $0.title == "Done" }))
        XCTAssertNil(viewModel.focusTask)
    }

    /// Test error handling: repository error is surfaced
    func testRepositoryErrorIsSurfaced() async throws {
        // Arrange
        repository.shouldFail = true
        // Act
        await viewModel.loadTasks()
        // Assert
        XCTAssertNotNil(viewModel.error)
    }

    /// Test that focusTask updates as tasks are completed in order
    func testFocusTaskProgression() async throws {
        // Arrange
        let now = Date()
        let t1 = TaskDTO(id: UUID(), title: "First", notes: nil, dueDate: nil, isCompleted: false, order: 0, createdAt: now, updatedAt: now)
        let t2 = TaskDTO(id: UUID(), title: "Second", notes: nil, dueDate: nil, isCompleted: false, order: 1, createdAt: now, updatedAt: now)
        let t3 = TaskDTO(id: UUID(), title: "Third", notes: nil, dueDate: nil, isCompleted: false, order: 2, createdAt: now, updatedAt: now)
        repository.setTasks(from: [t1, t2, t3])
        await viewModel.loadTasks()
        // Assert initial focus
        XCTAssertEqual(viewModel.focusTask?.title, "First")
        // Complete first task
        await viewModel.completeTask(t1)
        XCTAssertEqual(viewModel.focusTask?.title, "Second")
        // Complete second task
        await viewModel.completeTask(t2)
        XCTAssertEqual(viewModel.focusTask?.title, "Third")
        // Complete third task
        await viewModel.completeTask(t3)
        XCTAssertNil(viewModel.focusTask)
    }
}
