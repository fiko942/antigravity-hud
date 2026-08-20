import Cocoa

// MARK: - Notch Dynamic Island Panel (Level 102 above Menu Bar)
public class AntigravityNotchPanel: NSPanel {
    public var onPanelClicked: (() -> Void)?
    public var onRightClicked: ((NSEvent) -> Void)?

    public init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .borderless, .hudWindow, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        self.level = NSWindow.Level(rawValue: 102) // Layer 102 sits above Menu Bar & Notch
        self.isFloatingPanel = true
        self.isMovableByWindowBackground = false
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = true
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.ignoresMouseEvents = false
        self.acceptsMouseMovedEvents = true
    }

    public override var canBecomeKey: Bool { false }
    public override var canBecomeMain: Bool { false }

    public override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        return frameRect
    }

    public override func mouseDown(with event: NSEvent) {
        onPanelClicked?()
    }

    public override func rightMouseDown(with event: NSEvent) {
        onRightClicked?(event)
    }
}
