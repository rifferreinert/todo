import Foundation
import Combine
import SwiftUI
/// ViewModel for managing a list of tasks, sorting, and business logic.
final class TaskListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var tasks: [TaskViewModel] = []
    @Published private(set) var archivedTasks: [TaskViewModel] = []
    @Published private(set) var focusTask: TaskViewModel?
    @Published var error: Error?

    private let repository: TaskRepository
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(repository: TaskRepository) {
        self.repository = repository
    }

    // MARK: - Public Methods
    /// Loads all tasks from the repository and updates published properties.
    @MainActor
    func loadTasks() async {
        do {
            let active = try await repository.fetchAllActiveTasks()
            let archived = try await repository.fetchAllArchivedTasks()
            setTasks(active: active, archived: archived)
        } catch {
            self.error = error
            self.tasks = []
            self.archivedTasks = []
            self.focusTask = nil
        }
    }

    /// Sorts tasks by due date (ascending), then by order, and updates the repository.
    @MainActor
    func autoSortByDueDate() async {
        do {
            let active = try await repository.fetchAllActiveTasks()
            let sorted = active.sorted {
                if let d0 = $0.dueDate, let d1 = $1.dueDate {
                    if d0 != d1 {
                        return d0 < d1
                    } else {
                        return $0.order < $1.order
                    }
                } else if $0.dueDate == nil && $1.dueDate != nil {
                    return false
                } else if $0.dueDate != nil && $1.dueDate == nil {
                    return true
                } else {
                    return $0.order < $1.order
                }
            }
            // Update order property
            let reordered = sorted.enumerated().map { idx, t in
                TaskDTO(id: t.id, title: t.title, notes: t.notes, dueDate: t.dueDate, isCompleted: t.isCompleted, order: Int32(idx), createdAt: t.createdAt, updatedAt: t.updatedAt)
            }
            try await repository.reorderTasks(reordered)
            await loadTasks()
        } catch {
            self.error = error
        }
    }

    /// Reorders tasks manually and updates the repository.
    @MainActor
    func reorderTasks(_ newOrder: [TaskDTO]) async {
        do {
            try await repository.reorderTasks(newOrder)
            await loadTasks()
        } catch {
            self.error = error
        }
    }

    /// Marks a task as complete, moves it to archive, and updates focus.
    @MainActor
    func completeTask(_ task: TaskDTO) async {
        do {
            _ = try await repository.markTaskComplete(task)
            await loadTasks()
        } catch {
            self.error = error
        }
    }

    // MARK: - Internal Methods
    @MainActor
    private func setTasks(active: [TaskDTO], archived: [TaskDTO]) {
        let activeVMs = active.sorted { $0.order < $1.order }.map { TaskViewModel(task: $0, repository: repository) }
        let archivedVMs = archived.sorted { $0.order < $1.order }.map { TaskViewModel(task: $0, repository: repository) }
        self.tasks = activeVMs
        self.archivedTasks = archivedVMs
        self.focusTask = activeVMs.first
        self.error = nil
    }
}
