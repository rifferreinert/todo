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
        // Create the SwiftUI view for the bar (placeholder for now)
        let contentView = NSHostingController(rootView: FocusBarPlaceholderView())

        // Determine main screen dimensions
        let menuBarHeight = NSStatusBar.system.thickness + 1
        let screen = NSScreen.main
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
        // Use NSVisualEffectView for translucent background (AppKit does not have .ultraThinMaterial; use .underWindowBackground for similar effect)
        let effectView = NSVisualEffectView(frame: barRect)
        effectView.material = .underWindowBackground
        effectView.blendingMode = .behindWindow
        effectView.state = .active
        effectView.alphaValue = 0.8
        window.contentView?.addSubview(effectView, positioned: .below, relativeTo: contentView.view)

        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Update the displayed task title (to be called from SwiftUI view model)
    func updateTaskTitle(_ title: String) {
        // This will be implemented when FocusBarView is ready
        // For now, this is a placeholder
    }
}

/// Placeholder SwiftUI view for the bar (replace with FocusBarView in later sub-task)
struct FocusBarPlaceholderView: View {
    var body: some View {
        Text("Focus Bar Placeholder")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
    }
}

#if DEBUG
struct FocusBarWindow_Previews: PreviewProvider {
    static var previews: some View {
        FocusBarPlaceholderView()
            .frame(width: 800, height: 28)
    }
}
#endif
