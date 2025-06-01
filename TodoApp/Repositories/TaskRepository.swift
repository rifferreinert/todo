//
//  TaskRepository.swift
//  Todo
//
//  Created by Ben Xia-Reinert on 5/29/25.
//

import Foundation

// MARK: - Task Repository Errors

/// Errors that can occur during task repository operations
enum TaskRepositoryError: Error, LocalizedError {
    case invalidTaskData(String)
    case taskNotFound
    case persistenceFailure(String)
    case concurrentAccessError
    case validationError(String)

    var errorDescription: String? {
        switch self {
        case .invalidTaskData(let message):
            return "Invalid task data: \(message)"
        case .taskNotFound:
            return "The requested task could not be found"
        case .persistenceFailure(let message):
            return "Failed to save or retrieve data: \(message)"
        case .concurrentAccessError:
            return "Another operation is in progress"
        case .validationError(let message):
            return "Validation failed: \(message)"
        }
    }
}

// MARK: - Task Sorting Options

/// Defines the available sorting options for tasks
enum TaskSortOrder {
    case dueDate(ascending: Bool)
    case createdDate(ascending: Bool)
    case title(ascending: Bool)
    case manualOrder
}

// MARK: - Task Repository Protocol

/// Protocol defining the interface for task data persistence operations.
/// This abstraction allows for different implementations (Core Data, CloudKit, etc.)
/// while keeping the business logic independent of the persistence layer.
protocol TaskRepository {
    // MARK: - Basic CRUD Operations

    /// Creates a new task with the specified properties
    /// - Parameters:
    ///   - title: The task title (required, must not be empty)
    ///   - notes: Optional notes for the task
    ///   - dueDate: Optional due date for the task
    /// - Returns: The newly created task DTO
    /// - Throws: `TaskRepositoryError.invalidTaskData` if title is empty
    ///           `TaskRepositoryError.persistenceFailure` if save operation fails
    func createTask(title: String, notes: String?, dueDate: Date?) async throws -> TaskDTO

    /// Updates an existing task with new values
    /// - Parameter task: The task DTO to update with modified properties
    /// - Throws: `TaskRepositoryError.taskNotFound` if task doesn't exist
    ///           `TaskRepositoryError.persistenceFailure` if save operation fails
    func updateTask(_ task: TaskDTO) async throws

    /// Deletes a task from the repository
    /// - Parameter task: The task DTO to delete
    /// - Throws: `TaskRepositoryError.taskNotFound` if task doesn't exist
    ///           `TaskRepositoryError.persistenceFailure` if delete operation fails
    func deleteTask(_ task: TaskDTO) async throws

    // MARK: - Query Operations

    /// Fetches all active (non-completed) tasks
    /// - Returns: Array of active task DTOs, empty array if none exist
    /// - Throws: `TaskRepositoryError.persistenceFailure` if fetch operation fails
    func fetchAllActiveTasks() async throws -> [TaskDTO]

    /// Fetches all archived (completed) tasks
    /// - Returns: Array of archived task DTOs, empty array if none exist
    /// - Throws: `TaskRepositoryError.persistenceFailure` if fetch operation fails
    func fetchAllArchivedTasks() async throws -> [TaskDTO]

    /// Fetches tasks sorted according to the specified order
    /// - Parameter sortOrder: The sorting criteria to apply
    /// - Returns: Array of task DTOs sorted by the specified criteria
    /// - Throws: `TaskRepositoryError.persistenceFailure` if fetch operation fails
    func fetchTasksSorted(by sortOrder: TaskSortOrder) async throws -> [TaskDTO]

    /// Fetches the highest priority active task (for focus bar display)
    /// - Returns: The next task DTO to focus on, nil if no active tasks exist
    /// - Throws: `TaskRepositoryError.persistenceFailure` if fetch operation fails
    func fetchNextFocusTask() async throws -> TaskDTO?

    // MARK: - Task State Operations

    /// Marks a task as completed and moves it to archived state
    /// - Parameter task: The task DTO to mark as complete
    /// - Returns: The updated task DTO in completed state
    /// - Throws: `TaskRepositoryError.taskNotFound` if task doesn't exist
    ///           `TaskRepositoryError.persistenceFailure` if save operation fails
    func markTaskComplete(_ task: TaskDTO) async throws -> TaskDTO

    /// Marks a completed task as active (unarchive)
    /// - Parameter task: The task DTO to mark as active
    /// - Returns: The updated task DTO in active state
    /// - Throws: `TaskRepositoryError.taskNotFound` if task doesn't exist
    ///           `TaskRepositoryError.persistenceFailure` if save operation fails
    func markTaskActive(_ task: TaskDTO) async throws -> TaskDTO

    /// Updates the manual ordering of tasks
    /// - Parameter tasks: Array of task DTOs in the desired order
    /// - Throws: `TaskRepositoryError.persistenceFailure` if save operation fails
    ///           `TaskRepositoryError.validationError` if tasks array is invalid
    func reorderTasks(_ tasks: [TaskDTO]) async throws

    // MARK: - Batch Operations

    /// Deletes all completed tasks (permanent cleanup)
    /// - Returns: Number of tasks deleted
    /// - Throws: `TaskRepositoryError.persistenceFailure` if delete operation fails
    func deleteAllCompletedTasks() async throws -> Int

    /// Gets the total count of active tasks
    /// - Returns: Number of active tasks
    /// - Throws: `TaskRepositoryError.persistenceFailure` if count operation fails
    func getActiveTaskCount() async throws -> Int

    /// Gets the total count of archived tasks
    /// - Returns: Number of archived tasks
    /// - Throws: `TaskRepositoryError.persistenceFailure` if count operation fails
    func getArchivedTaskCount() async throws -> Int
}

// MARK: - Repository Protocol Extensions

extension TaskRepository {
    /// Convenience method to create a simple task with just a title
    /// - Parameter title: The task title
    /// - Returns: The newly created task DTO
    /// - Throws: Same errors as `createTask(title:notes:dueDate:)`
    func createSimpleTask(title: String) async throws -> TaskDTO {
        return try await createTask(title: title, notes: nil, dueDate: nil)
    }

    /// Convenience method to check if any active tasks exist
    /// - Returns: true if there are active tasks, false otherwise
    /// - Throws: Same errors as `getActiveTaskCount()`
    func hasActiveTasks() async throws -> Bool {
        return try await getActiveTaskCount() > 0
    }

    /// Convenience method to check if any archived tasks exist
    /// - Returns: true if there are archived tasks, false otherwise
    /// - Throws: Same errors as `getArchivedTaskCount()`
    func hasArchivedTasks() async throws -> Bool {
        return try await getArchivedTaskCount() > 0
    }
}

// MARK: - Task Data Transfer Object (DTO)

/// A data transfer object representing a task, decoupled from Core Data.
/// Use this type for all repository operations and view models.
struct TaskDTO: Identifiable, Equatable {
    /// The unique identifier for the task (UUID, persistence-agnostic)
    let id: UUID
    /// The task title (required, plain text)
    let title: String
    /// Optional notes for the task (plain text)
    let notes: String?
    /// Optional due date for the task
    let dueDate: Date?
    /// Whether the task is completed (archived)
    let isCompleted: Bool
    /// Manual order value for custom sorting
    let order: Int32
    /// The date the task was created
    let createdAt: Date
    /// The date the task was last updated
    let updatedAt: Date
}
