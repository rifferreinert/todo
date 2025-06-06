// FocusBarWindow.swift
// Implements an always-on-top window using NSWindow.Level.statusBar, embedding a SwiftUI view.
// All UI logic should remain in SwiftUI; this file only handles window configuration and bridging.

import AppKit
import SwiftUI
import Foundation

/// A window controller that hosts the always-on-top Focus Bar using SwiftUI for content.
final class FocusBarWindowController: NSWindowController {
    /// Singleton instance to avoid duplicate windows.
    static let shared: FocusBarWindowController = FocusBarWindowController()

    private var opacity: Double = FocusBarOpacitySettings.load()  // Load from UserDefaults
    {
        didSet {
            window?.alphaValue = opacity // Update window opacity when property changes
            FocusBarOpacitySettings.save(opacity) // Persist to UserDefaults
        }
    }
    private var title: String = "Sample Focus Task"

    private var opacityBinding: Binding<Double> {
        Binding<Double>(
            get: { [weak self] in self?.opacity ?? 1.0 },
            set: { [weak self] newValue in self?.opacity = newValue }
        )
    }

    private var hostingController: NSHostingController<FocusBarView>?

    private init() {
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
        window.level = .statusBar
        window.hasShadow = false
        window.ignoresMouseEvents = false
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.isReleasedWhenClosed = false
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.setFrame(barRect, display: true)
        window.alphaValue = opacity // Use property value
        window.isExcludedFromWindowsMenu = true
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.collectionBehavior.insert(.fullScreenAuxiliary)
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

        // Now safe to use self for SwiftUI hosting
        let hostingController = NSHostingController(
            rootView: FocusBarView(
                title: title,
                opacity: opacityBinding
            )
        )
        window.contentView = hostingController.view
        self.hostingController = hostingController
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
    @State static var previewOpacity: Double = 0.5
    static var previews: some View {
        FocusBarView(title: "Preview Focus Task", opacity: $previewOpacity)
            .frame(width: 800, height: 28)
    }
}
#endif
