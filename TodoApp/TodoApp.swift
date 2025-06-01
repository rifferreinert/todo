//
//  TodoApp.swift
//  Todo
//
//  Created by Ben Xia-Reinert on 5/27/25.
//

import SwiftUI

@main
struct TodoApp: App {
    let persistenceController = PersistenceController.shared
    // Retain the focus bar window controller for the app's lifetime
    private let focusBarWindowController = FocusBarWindowController.shared

    init() {
        // Show the always-on-top Focus Bar window at app launch
        focusBarWindowController.showWindow(nil)
        focusBarWindowController.window?.orderFrontRegardless()
    }

    var body: some Scene {
        // No main window; only show the always-on-top Focus Bar window on app start
        Settings {
            // Provide an empty settings scene to satisfy App protocol
            EmptyView()
        }
    }
}
