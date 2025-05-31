import Foundation
import CoreData

final class CoreDataTaskRepository: TaskRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Mapping Helpers
    private func mapToDTO(_ task: Task) -> TaskDTO {
        TaskDTO(
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

    // MARK: - CRUD Operations
    func createTask(title: String, notes: String?, dueDate: Date?) async throws -> TaskDTO {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TaskRepositoryError.invalidTaskData("Title must not be empty")
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
            do {
                try self.context.save()
            } catch {
                throw TaskRepositoryError.persistenceFailure(error.localizedDescription)
            }
            return self.mapToDTO(task)
        }
    }

    func updateTask(_ taskDTO: TaskDTO) async throws {
        let task = try await fetchManaged(taskDTO.id)
        return try await context.perform {
            task.title = taskDTO.title
            task.notes = taskDTO.notes
            task.dueDate = taskDTO.dueDate
            task.isCompleted = taskDTO.isCompleted
            task.order = taskDTO.order
            task.updatedAt = Date()
            do {
                try self.context.save()
            } catch {
                throw TaskRepositoryError.persistenceFailure(error.localizedDescription)
            }
        }
    }

    func deleteTask(_ taskDTO: TaskDTO) async throws {
        let task = try await fetchManaged(taskDTO.id)
        return try await context.perform {
            self.context.delete(task)
            do {
                try self.context.save()
            } catch {
                throw TaskRepositoryError.persistenceFailure(error.localizedDescription)
            }
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
                return results.map(self.mapToDTO)
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
                return results.map(self.mapToDTO)
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
                return results.map(self.mapToDTO)
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
        let task = try await fetchManaged(taskDTO.id)
        return try await context.perform {
            task.isCompleted = true
            task.updatedAt = Date()
            do {
                try self.context.save()
            } catch {
                throw TaskRepositoryError.persistenceFailure(error.localizedDescription)
            }
            return self.mapToDTO(task)
        }
    }

    func markTaskActive(_ taskDTO: TaskDTO) async throws -> TaskDTO {
        let task = try await fetchManaged(taskDTO.id)
        return try await context.perform {
            task.isCompleted = false
            task.updatedAt = Date()
            do {
                try self.context.save()
            } catch {
                throw TaskRepositoryError.persistenceFailure(error.localizedDescription)
            }
            return self.mapToDTO(task)
        }
    }

    func reorderTasks(_ tasks: [TaskDTO]) async throws {
        return try await context.perform {
            for (index, dto) in tasks.enumerated() {
                let task = try self.context.existingObject(with: dto.id as! NSManagedObjectID) as? Task
                if let task = task {
                    task.order = Int32(index)
                } else {
                    throw TaskRepositoryError.taskNotFound
                }
            }
            do {
                try self.context.save()
            } catch {
                throw TaskRepositoryError.persistenceFailure(error.localizedDescription)
            }
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
