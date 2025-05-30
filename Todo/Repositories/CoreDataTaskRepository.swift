import Foundation
import CoreData

/// Sorting options for fetching tasks.
enum TaskSortOption {
    case dueDate
    case createdAt
}

/// A struct representing a Task for use outside Core Data.
struct TaskModel: Identifiable, Equatable {
    let id: NSManagedObjectID
    var title: String
    var notes: String?
    var dueDate: Date?
    var isCompleted: Bool
    var order: Int32
    var createdAt: Date
    var updatedAt: Date
}

/// Repository for CRUD operations on Task entities using Core Data.
final class CoreDataTaskRepository {
    private let context: NSManagedObjectContext

    /// Initialize with a Core Data context.
    /// - Parameter context: The NSManagedObjectContext to use (should be background for fetches).
    init(context: NSManagedObjectContext) {
        self.context = context
    }

    /// Create a new task.
    /// - Parameters:
    ///   - title: The task title (must not be empty).
    ///   - notes: Optional notes.
    ///   - dueDate: Optional due date.
    /// - Returns: The created TaskModel.
    func createTask(title: String, notes: String?, dueDate: Date?) async throws -> TaskModel {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NSError(domain: "TaskRepository", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Title must not be empty"])
        }
        return try await context.perform {
            let task = Task(context: self.context)
            task.title = title
            task.notes = notes
            task.dueDate = dueDate
            task.isCompleted = false
            task.order = 0
            task.createdAt = Date()
            task.updatedAt = Date()
            try self.context.save()
            return TaskModel(
                id: task.objectID,
                title: task.title ?? "",
                notes: task.notes,
                dueDate: task.dueDate,
                isCompleted: task.isCompleted,
                order: task.order,
                createdAt: task.createdAt ?? Date(),
                updatedAt: task.updatedAt ?? Date()
            )
        }
    }

    /// Fetch all tasks, sorted by the given option.
    /// - Parameter sortedBy: The sorting option.
    /// - Returns: An array of TaskModel.
    func fetchTasks(sortedBy: TaskSortOption) async throws -> [TaskModel] {
        return try await context.perform {
            let request: NSFetchRequest<Task> = Task.fetchRequest()
            switch sortedBy {
            case .dueDate:
                request.sortDescriptors = [
                    NSSortDescriptor(key: "dueDate", ascending: true),
                    NSSortDescriptor(key: "order", ascending: true)
                ]
            case .createdAt:
                request.sortDescriptors = [
                    NSSortDescriptor(key: "createdAt", ascending: true)
                ]
            }
            let results = try self.context.fetch(request)
            return results.map { task in
                TaskModel(
                    id: task.objectID,
                    title: task.title ?? "",
                    notes: task.notes,
                    dueDate: task.dueDate,
                    isCompleted: task.isCompleted,
                    order: task.order,
                    createdAt: task.createdAt ?? Date(),
                    updatedAt: task.updatedAt ?? Date()
                )
            }
        }
    }

    /// Update a task.
    /// - Parameter model: The TaskModel to update.
    /// - Returns: The updated TaskModel.
    func updateTask(_ model: TaskModel) async throws -> TaskModel {
        return try await context.perform {
            guard let task = try self.context.existingObject(with: model.id) as? Task else {
                throw NSError(domain: "TaskRepository", code: 2,
                              userInfo: [NSLocalizedDescriptionKey: "Task not found"])
            }
            task.title = model.title
            task.notes = model.notes
            task.dueDate = model.dueDate
            task.isCompleted = model.isCompleted
            task.order = model.order
            task.updatedAt = Date()
            try self.context.save()
            return TaskModel(
                id: task.objectID,
                title: task.title ?? "",
                notes: task.notes,
                dueDate: task.dueDate,
                isCompleted: task.isCompleted,
                order: task.order,
                createdAt: task.createdAt ?? Date(),
                updatedAt: task.updatedAt ?? Date()
            )
        }
    }

    /// Delete a task.
    /// - Parameter model: The TaskModel to delete.
    func deleteTask(_ model: TaskModel) async throws {
        try await context.perform {
            guard let task = try self.context.existingObject(with: model.id) as? Task else {
                throw NSError(domain: "TaskRepository", code: 3,
                              userInfo: [NSLocalizedDescriptionKey: "Task not found"])
            }
            self.context.delete(task)
            try self.context.save()
        }
    }
}
