// FocusBarWindow.swift
// Implements an always-on-top window using NSWindow.Level.statusBar, embedding a SwiftUI view.
// All UI logic should remain in SwiftUI; this file only handles window configuration and bridging.

import AppKit
import SwiftUI

/// A window controller that hosts the always-on-top Focus Bar using SwiftUI for content.
final class FocusBarWindowController: NSWindowController {
    /// Singleton instance to avoid duplicate windows.
    static let shared = FocusBarWindowController()

    private init() {
        // Create the SwiftUI view for the bar (now using FocusBarView)
        // TODO: Replace these with real bindings from the ViewModel in integration
        let previewTitle = "Sample Focus Task"
        let previewOpacity = Binding<Double>(get: { 0.8 }, set: { _ in })
        let contentView = NSHostingController(rootView: FocusBarView(title: previewTitle, opacity: previewOpacity))

        // Determine main screen dimensions
        let menuBarHeight = NSStatusBar.system.thickness + 1
        let screen = NSScreen.screens.first { $0.frame.origin == .zero } ?? NSScreen.main
        let barHeight: CGFloat = 28
        let barWidth = screen?.frame.width ?? 800
        let barOrigin = CGPoint(x: 0, y: (screen?.frame.maxY ?? barHeight) - menuBarHeight - barHeight)
        let barRect = CGRect(origin: barOrigin, size: CGSize(width: barWidth, height: barHeight))

        // Create the window
        let window = NSWindow(
            contentRect: barRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.contentView = contentView.view
        window.level = .statusBar
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.ignoresMouseEvents = false
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.isMovable = false
        window.isReleasedWhenClosed = false
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.setFrame(barRect, display: true)
        window.alphaValue = 0.8 // 80% opacity default
        window.isExcludedFromWindowsMenu = true
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.collectionBehavior.insert(.fullScreenAuxiliary)
        window.level = .statusBar
        window.orderFrontRegardless()
        window.makeKeyAndOrderFront(nil)
        window.isMovableByWindowBackground = false
        window.setIsVisible(true)
        window.isRestorable = false
        window.preventsApplicationTerminationWhenModal = false
        window.isReleasedWhenClosed = false
        window.styleMask.remove(.resizable)
        window.styleMask.remove(.titled)
        window.styleMask.remove(.closable)
        window.styleMask.remove(.miniaturizable)
        window.styleMask.remove(.fullSizeContentView)
        window.isMovable = false
        window.isOpaque = false
        window.backgroundColor = .clear
        // Remove placeholder effectView, as FocusBarView handles background/opacity

        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Update the displayed task title (to be called from SwiftUI view model)
    func updateTaskTitle(_ title: String) {
        // This will be implemented when FocusBarView is integrated with the real ViewModel.
        // For now, this is a placeholder for future data binding.
    }
}

#if DEBUG
struct FocusBarWindow_Previews: PreviewProvider {
    @State static var previewOpacity: Double = 0.8
    static var previews: some View {
        FocusBarView(title: "Preview Focus Task", opacity: $previewOpacity)
            .frame(width: 800, height: 28)
    }
}
#endif
