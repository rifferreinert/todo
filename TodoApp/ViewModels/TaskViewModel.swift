import Foundation
import Combine
import SwiftUI

/// ViewModel for presenting and editing a single Task.
final class TaskViewModel: ObservableObject {
    // MARK: - Types
    enum ValidationError: Error, Equatable {
        case emptyTitle
    }

    // MARK: - Published Properties
    @Published var title: String
    @Published var notes: String?
    @Published var dueDate: Date?
    @Published var isCompleted: Bool
    @Published var isEditingDisabled: Bool = false

    // MARK: - Private Properties
    private(set) var task: TaskDTO
    private let repository: TaskRepository
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(task: TaskDTO, repository: TaskRepository) {
        self.task = task
        self.repository = repository
        self.title = task.title
        self.notes = task.notes
        self.dueDate = task.dueDate
        self.isCompleted = task.isCompleted
    }

    // MARK: - Update Methods
    @MainActor
    func updateTitle(_ newTitle: String) async throws {
        guard !isEditingDisabled else { return }
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw ValidationError.emptyTitle }
        title = trimmed
        task = TaskDTO(
            id: task.id,
            title: trimmed,
            notes: notes,
            dueDate: dueDate,
            isCompleted: isCompleted,
            order: task.order,
            createdAt: task.createdAt,
            updatedAt: Date()
        )
        try await repository.updateTask(task)
    }

    @MainActor
    func updateNotes(_ newNotes: String?) async throws {
        guard !isEditingDisabled else { return }
        notes = newNotes
        task = TaskDTO(
            id: task.id,
            title: title,
            notes: newNotes,
            dueDate: dueDate,
            isCompleted: isCompleted,
            order: task.order,
            createdAt: task.createdAt,
            updatedAt: Date()
        )
        try await repository.updateTask(task)
    }

    @MainActor
    func updateDueDate(_ newDate: Date?) async throws {
        guard !isEditingDisabled else { return }
        dueDate = newDate
        task = TaskDTO(
            id: task.id,
            title: title,
            notes: notes,
            dueDate: newDate,
            isCompleted: isCompleted,
            order: task.order,
            createdAt: task.createdAt,
            updatedAt: Date()
        )
        try await repository.updateTask(task)
    }

    @MainActor
    func updateCompletion(_ completed: Bool) async throws {
        guard !isEditingDisabled else { return }
        isCompleted = completed
        task = TaskDTO(
            id: task.id,
            title: title,
            notes: notes,
            dueDate: dueDate,
            isCompleted: completed,
            order: task.order,
            createdAt: task.createdAt,
            updatedAt: Date()
        )
        try await repository.updateTask(task)
    }

    // MARK: - External Deletion Handling
    @MainActor
    func handleTaskDeleted() {
        isEditingDisabled = true
    }

    // MARK: - Computed Properties
    var formattedDueDate: String? {
        guard let dueDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: dueDate)
    }
}
