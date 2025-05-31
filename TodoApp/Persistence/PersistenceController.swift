//
//  Persistence.swift
//  Todo
//
//  Created by Ben Xia-Reinert on 5/27/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for index in 0..<3 {
            let newTask = Task(context: viewContext)
            newTask.title = "Sample Task \(index + 1)"
            newTask.notes = "This is a sample task for preview"
            newTask.isCompleted = false
            newTask.order = Int32(index)
            newTask.createdAt = Date()
            newTask.updatedAt = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be
            // useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Todo")
        if inMemory {
            if let firstDescription = container.persistentStoreDescriptions.first {
                firstDescription.url = URL(fileURLWithPath: "/dev/null")
            }
        } else {
            // Enable lightweight migration for future schema changes
            if let firstDescription = container.persistentStoreDescriptions.first {
                firstDescription.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
                firstDescription.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
                /*
                 Lightweight migration allows Core Data to automatically migrate the persistent store
                 when the model changes in simple ways (e.g., adding a new attribute). This helps prevent
                 data loss or crashes when updating the app. For more complex migrations, a custom mapping
                 model may be required. See Apple documentation for details.
                */
            }
        }
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                // If migration fails, log the error and fail gracefully for debugging
                print("Core Data migration or load error: \(error), \(error.userInfo)")
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
