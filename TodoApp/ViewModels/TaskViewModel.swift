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
    private(set) var task: Task
    private let repository: TaskRepository
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(task: Task, repository: TaskRepository) {
        self.task = task
        self.repository = repository
        self.title = task.title ?? ""
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
        task.title = trimmed
        try await repository.updateTask(task)
    }

    @MainActor
    func updateNotes(_ newNotes: String?) async throws {
        guard !isEditingDisabled else { return }
        notes = newNotes
        task.notes = newNotes
        try await repository.updateTask(task)
    }

    @MainActor
    func updateDueDate(_ newDate: Date?) async throws {
        guard !isEditingDisabled else { return }
        dueDate = newDate
        task.dueDate = newDate
        try await repository.updateTask(task)
    }

    @MainActor
    func updateCompletion(_ completed: Bool) async throws {
        guard !isEditingDisabled else { return }
        isCompleted = completed
        task.isCompleted = completed
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
