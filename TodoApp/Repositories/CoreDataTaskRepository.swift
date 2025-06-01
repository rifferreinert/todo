import Foundation
import CoreData

final class CoreDataTaskRepository: TaskRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Mapping Helpers
    private func mapToDTO(_ task: Task) throws -> TaskDTO {
        guard let uuid = task.id else {
            throw TaskRepositoryError.persistenceFailure("Task entity missing UUID id")
        }
        return TaskDTO(
            id: uuid,
            title: task.title ?? "",
            notes: task.notes,
            dueDate: task.dueDate,
            isCompleted: task.isCompleted,
            order: task.order,
            createdAt: task.createdAt ?? Date(),
            updatedAt: task.updatedAt ?? Date()
        )
    }

    private func fetchManaged(_ id: AnyHashable) async throws -> Task {
        guard let objectID = id as? NSManagedObjectID else {
            throw TaskRepositoryError.persistenceFailure("Invalid objectID type")
        }
        return try await context.perform {
            guard let task = try self.context.existingObject(with: objectID) as? Task else {
                throw TaskRepositoryError.taskNotFound
            }
            return task
        }
    }

    // Replace fetchManaged to use UUID
    private func fetchManaged(by uuid: UUID) async throws -> Task {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
        request.fetchLimit = 1
        return try await context.perform {
            guard let task = try self.context.fetch(request).first else {
                throw TaskRepositoryError.taskNotFound
            }
            return task
        }
    }

    // MARK: - CRUD Operations
    func createTask(title: String, notes: String?, dueDate: Date?) async throws -> TaskDTO {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TaskRepositoryError.invalidTaskData("Title must not be empty")
        }
        return try await context.perform {
            let task = Task(context: self.context)
            task.id = UUID()
            task.title = title
            task.notes = notes
            task.dueDate = dueDate
            task.isCompleted = false
            task.order = 0
            task.createdAt = Date()
            task.updatedAt = Date()
            do {
                try self.context.save()
            } catch {
                throw TaskRepositoryError.persistenceFailure(error.localizedDescription)
            }
            return try self.mapToDTO(task)
        }
    }

    func updateTask(_ task: TaskDTO) async throws {
        let managed = try await fetchManaged(by: task.id)
        managed.title = task.title
        managed.notes = task.notes
        managed.dueDate = task.dueDate
        managed.isCompleted = task.isCompleted
        managed.order = task.order
        managed.updatedAt = Date() // Always set updatedAt to now
        try await context.perform {
            try self.context.save()
        }
    }

    func deleteTask(_ task: TaskDTO) async throws {
        let managed = try await fetchManaged(by: task.id)
        context.delete(managed)
        try await context.perform {
            try self.context.save()
        }
    }

    // MARK: - Query Operations
    func fetchAllActiveTasks() async throws -> [TaskDTO] {
        return try await context.perform {
            let request: NSFetchRequest<Task> = Task.fetchRequest()
            request.predicate = NSPredicate(format: "isCompleted == NO")
            request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
            do {
                let results = try self.context.fetch(request)
                return try results.map { try self.mapToDTO($0) }
            } catch {
                throw TaskRepositoryError.persistenceFailure(error.localizedDescription)
            }
        }
    }

    func fetchAllArchivedTasks() async throws -> [TaskDTO] {
        return try await context.perform {
            let request: NSFetchRequest<Task> = Task.fetchRequest()
            request.predicate = NSPredicate(format: "isCompleted == YES")
            request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
            do {
                let results = try self.context.fetch(request)
                return try results.map { try self.mapToDTO($0) }
            } catch {
                throw TaskRepositoryError.persistenceFailure(error.localizedDescription)
            }
        }
    }

    func fetchTasksSorted(by sortOrder: TaskSortOrder) async throws -> [TaskDTO] {
        return try await context.perform {
            let request: NSFetchRequest<Task> = Task.fetchRequest()
            switch sortOrder {
            case .dueDate(let ascending):
                request.sortDescriptors = [
                    NSSortDescriptor(key: "dueDate", ascending: ascending),
                    NSSortDescriptor(key: "order", ascending: true)
                ]
            case .createdDate(let ascending):
                request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: ascending)]
            case .title(let ascending):
                request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: ascending)]
            case .manualOrder:
                request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
            }
            do {
                let results = try self.context.fetch(request)
                return try results.map { try self.mapToDTO($0) }
            } catch {
                throw TaskRepositoryError.persistenceFailure(error.localizedDescription)
            }
        }
    }

    func fetchNextFocusTask() async throws -> TaskDTO? {
        let activeTasks = try await fetchAllActiveTasks()
        return activeTasks.first
    }

    // MARK: - Task State Operations
    func markTaskComplete(_ taskDTO: TaskDTO) async throws -> TaskDTO {
        let managed = try await fetchManaged(by: taskDTO.id)
        managed.isCompleted = true
        managed.updatedAt = Date()
        try await context.perform {
            try self.context.save()
        }
        return try mapToDTO(managed)
    }

    func markTaskActive(_ taskDTO: TaskDTO) async throws -> TaskDTO {
        let managed = try await fetchManaged(by: taskDTO.id)
        managed.isCompleted = false
        managed.updatedAt = Date()
        try await context.perform {
            try self.context.save()
        }
        return try mapToDTO(managed)
    }

    func reorderTasks(_ tasks: [TaskDTO]) async throws {
        for (index, dto) in tasks.enumerated() {
            let managed = try await fetchManaged(by: dto.id)
            managed.order = Int32(index)
        }
        try await context.perform {
            try self.context.save()
        }
    }

    // MARK: - Batch Operations
    func deleteAllCompletedTasks() async throws -> Int {
        return try await context.perform {
            let request: NSFetchRequest<Task> = Task.fetchRequest()
            request.predicate = NSPredicate(format: "isCompleted == YES")
            do {
                let results = try self.context.fetch(request)
                for task in results {
                    self.context.delete(task)
                }
                try self.context.save()
                return results.count
            } catch {
                throw TaskRepositoryError.persistenceFailure(error.localizedDescription)
            }
        }
    }

    func getActiveTaskCount() async throws -> Int {
        return try await context.perform {
            let request: NSFetchRequest<Task> = Task.fetchRequest()
            request.predicate = NSPredicate(format: "isCompleted == NO")
            do {
                return try self.context.count(for: request)
            } catch {
                throw TaskRepositoryError.persistenceFailure(error.localizedDescription)
            }
        }
    }

    func getArchivedTaskCount() async throws -> Int {
        return try await context.perform {
            let request: NSFetchRequest<Task> = Task.fetchRequest()
            request.predicate = NSPredicate(format: "isCompleted == YES")
            do {
                return try self.context.count(for: request)
            } catch {
                throw TaskRepositoryError.persistenceFailure(error.localizedDescription)
            }
        }
    }
}
