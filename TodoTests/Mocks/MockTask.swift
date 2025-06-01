// TodoTests/Mocks/MockTask.swift
// Mock Task entity for testing TaskListViewModel and related tests

import Foundation

/// Mock Task entity for testing
struct MockTask: Identifiable, Equatable {
    let id: UUID
    var title: String
    var notes: String?
    var dueDate: Date?
    var isCompleted: Bool
    var order: Int
    var createdAt: Date
    var updatedAt: Date
}
