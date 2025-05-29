//
//  ContentView.swift
//  Todo
//
//  Created by Ben Xia-Reinert on 5/27/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.createdAt, ascending: true)],
        animation: .default)
    private var tasks: FetchedResults<Task>

    var body: some View {
        NavigationView {
            List {
                ForEach(tasks) { task in
                    NavigationLink {
                        Text("Task: \(task.title ?? "No Title")")
                    } label: {
                        VStack(alignment: .leading) {
                            Text(task.title ?? "No Title")
                                .font(.headline)
                            if let notes = task.notes {
                                Text(notes)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            if let createdAt = task.createdAt {
                                Text("Created: \(createdAt, formatter: taskFormatter)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteTasks)
            }
            .toolbar {
                ToolbarItem {
                    Button(action: addTask) {
                        Label("Add Task", systemImage: "plus")
                    }
                }
            }
            Text("Select a task")
        }
    }

    private func addTask() {
        withAnimation {
            let newTask = Task(context: viewContext)
            newTask.title = "New Task"
            newTask.notes = "Add some details here..."
            newTask.isCompleted = false
            newTask.order = Int32(tasks.count)
            newTask.createdAt = Date()
            newTask.updatedAt = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application, although it may
                // be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteTasks(offsets: IndexSet) {
        withAnimation {
            offsets.map { tasks[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application, although it may
                // be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let taskFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
