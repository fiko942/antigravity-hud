import Cocoa

// MARK: - Main Notch Application Delegate
public class AppDelegate: NSObject, NSApplicationDelegate {
    public var panel: AntigravityNotchPanel!
    public var contentView: NotchIslandContentView!
    public var brainWatcher = BrainWatcher()

    private var pollTimer: Timer?
    private var mouseTimer: Timer?

    private var screenTop: CGFloat = 956.0
    private var screenMidX: CGFloat = 735.0
    private var notchH: CGFloat = 32.0

    private var currentW: CGFloat = 185.0
    private var currentH: CGFloat = 34.0

    private var isHovered: Bool = false
    private var isClickExpanded: Bool = false
    private var currentActivity = AgentActivity(
        state: "idle",
        header: "ANTIGRAVITY • READY",
        detail: "Standby for prompt",
        activePath: nil,
        isAnimated: false
    )

    public func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        // Ensure auto-start at login is registered
        LaunchAgentManager.ensureInstalled()

        guard let screen = NSScreen.main else { return }
        screenTop = screen.frame.maxY
        screenMidX = screen.frame.midX

        if #available(macOS 12.0, *) {
            let topInset = screen.safeAreaInsets.top
            if topInset > 0 {
                notchH = topInset
            }
        }

        // Initial Compact Size flush on notch
        currentW = 185.0
        currentH = notchH + 2.0

        let xPos = screenMidX - (currentW / 2)
        let yPos = screenTop - currentH

        let panelRect = NSRect(x: xPos, y: yPos, width: currentW, height: currentH)
        panel = AntigravityNotchPanel(contentRect: panelRect)

        contentView = NotchIslandContentView(frame: NSRect(x: 0, y: 0, width: currentW, height: currentH))

        let toggleAction: () -> Void = { [weak self] in
            self?.handleUserClick()
        }
        contentView.onViewClicked = toggleAction
        panel.onPanelClicked = toggleAction

        let menuAction: (NSEvent) -> Void = { [weak self] event in
            self?.showActionMenu(positionedNear: nil, event: event)
        }
        contentView.onRightClicked = menuAction
        panel.onRightClicked = menuAction

        contentView.onMoreClicked = { [weak self] button in
            self?.showActionMenu(positionedNear: button, event: nil)
        }

        panel.contentView = contentView
        panel.orderFrontRegardless()

        // Fast Global Mouse Hover Tracking
        NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { [weak self] _ in
            self?.checkMouseHover()
        }
        NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) { [weak self] event in
            self?.checkMouseHover()
            return event
        }
        mouseTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.checkMouseHover()
        }

        // Global Mouse Click Monitor
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown]) { [weak self] _ in
            self?.checkMouseClick()
        }

        // Connect Brain Watcher
        brainWatcher.onActivityChanged = { [weak self] activity in
            self?.handleActivityChange(activity)
        }

        // Brain State Polling (every 100ms)
        pollTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.brainWatcher.poll()
        }
    }

    private func handleActivityChange(_ activity: AgentActivity) {
        let previousState = currentActivity.state

        if previousState != activity.state {
            if activity.state == "done" {
                SensoryManager.shared.playCompletionChime()
                SensoryManager.shared.triggerHaptic(pattern: .alignment)
            } else if activity.state == "working" || activity.state == "thinking" {
                SensoryManager.shared.triggerHaptic(pattern: .generic)
            } else if activity.state == "idle" {
                isClickExpanded = false
            }
        }

        currentActivity = activity
        contentView.updateActivity(currentActivity)
        updateNotchDimensions()
    }

    private func showActionMenu(positionedNear view: NSView?, event: NSEvent?) {
        let menu = NSMenu(title: "Antigravity HUD")

        // 1. Theme Submenu (General, Cyberpunk, Matrix, Sunset, Dracula)
        let themeMenu = NSMenu(title: "Themes")
        for theme in ThemeManager.shared.availableThemes {
            let item = NSMenuItem(title: theme.displayName, action: #selector(selectThemeMenuItem(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = theme.id
            item.state = (ThemeManager.shared.activeThemeId == theme.id) ? .on : .off
            themeMenu.addItem(item)
        }
        let themeItem = NSMenuItem(title: "🎨 Theme & Shape Style", action: nil, keyEquivalent: "")
        themeItem.submenu = themeMenu
        menu.addItem(themeItem)

        menu.addItem(NSMenuItem.separator())

        // 2. Sound & Haptics Toggles
        let soundItem = NSMenuItem(
            title: "🔊 Completion Chime: \(ThemeManager.shared.soundEnabled ? "Enabled" : "Disabled")",
            action: #selector(toggleSoundMenu),
            keyEquivalent: ""
        )
        soundItem.target = self
        menu.addItem(soundItem)

        let hapticItem = NSMenuItem(
            title: "📳 Trackpad Haptics: \(ThemeManager.shared.hapticsEnabled ? "Enabled" : "Disabled")",
            action: #selector(toggleHapticsMenu),
            keyEquivalent: ""
        )
        hapticItem.target = self
        menu.addItem(hapticItem)

        // 3. Dynamic Contextual Actions (Open File & Abort Task)
        var hasContextAction = false
        if let path = currentActivity.activePath, FileManager.default.fileExists(atPath: path) {
            let filename = (path as NSString).lastPathComponent
            menu.addItem(NSMenuItem.separator())
            let openItem = NSMenuItem(
                title: "📂 Open '\(filename)' in Editor",
                action: #selector(openActiveFileMenu),
                keyEquivalent: "o"
            )
            openItem.target = self
            menu.addItem(openItem)
            hasContextAction = true
        }

        if currentActivity.state == "working" || currentActivity.state == "thinking" {
            if !hasContextAction { menu.addItem(NSMenuItem.separator()) }
            let abortItem = NSMenuItem(
                title: "🛑 Abort Current Agent Task",
                action: #selector(abortTaskMenu),
                keyEquivalent: "."
            )
            abortItem.target = self
            menu.addItem(abortItem)
        }

        menu.addItem(NSMenuItem.separator())

        // 4. System Controls
        let restartItem = NSMenuItem(title: "🔄 Restart HUD", action: #selector(restartApp), keyEquivalent: "r")
        restartItem.target = self
        menu.addItem(restartItem)

        let quitItem = NSMenuItem(title: "❌ Quit Antigravity HUD", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        if let anchor = view {
            let menuOrigin = NSPoint(x: 0, y: anchor.bounds.height + 4)
            menu.popUp(positioning: nil, at: menuOrigin, in: anchor)
        } else if let ev = event {
            NSMenu.popUpContextMenu(menu, with: ev, for: contentView)
        } else {
            menu.popUp(positioning: nil, at: NSPoint(x: currentW - 30, y: currentH), in: contentView)
        }
    }

    @objc private func selectThemeMenuItem(_ sender: NSMenuItem) {
        if let themeId = sender.representedObject as? String {
            ThemeManager.shared.setTheme(withId: themeId)
        }
    }

    @objc private func toggleSoundMenu() {
        ThemeManager.shared.toggleSound()
        SensoryManager.shared.triggerHaptic(pattern: .generic)
    }

    @objc private func toggleHapticsMenu() {
        ThemeManager.shared.toggleHaptics()
        SensoryManager.shared.triggerHaptic(pattern: .generic)
    }

    @objc private func openActiveFileMenu() {
        guard let path = currentActivity.activePath, FileManager.default.fileExists(atPath: path) else { return }
        NSWorkspace.shared.open(URL(fileURLWithPath: path))
    }

    @objc private func abortTaskMenu() {
        let abortSignalPath = "/tmp/antigravity-abort.signal"
        try? "ABORT_\(Date().timeIntervalSince1970)".write(toFile: abortSignalPath, atomically: true, encoding: .utf8)
        SensoryManager.shared.triggerHaptic(pattern: .alignment)
    }

    @objc private func restartApp() {
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["-n", Bundle.main.bundlePath]
        try? task.run()
        exit(0)
    }

    @objc private func quitApp() {
        exit(0)
    }

    private func checkMouseClick() {
        let mouseLoc = NSEvent.mouseLocation
        let notchHitBox = NSRect(
            x: screenMidX - (currentW / 2) - 10,
            y: screenTop - currentH - 10,
            width: currentW + 20,
            height: currentH + 20
        )
        if notchHitBox.contains(mouseLoc) {
            handleUserClick()
        }
    }

    private func handleUserClick() {
        if currentActivity.state != "idle" {
            // When AI is ACTIVE: Click toggles open/close
            isClickExpanded.toggle()
            SensoryManager.shared.triggerHaptic(pattern: .generic)
            updateNotchDimensions()
        }
    }

    private func checkMouseHover() {
        let mouseLoc = NSEvent.mouseLocation

        let hoverHitBox = NSRect(
            x: screenMidX - (isHovered ? 190 : 100),
            y: screenTop - (isHovered ? 78 : 36),
            width: isHovered ? 380 : 200,
            height: isHovered ? 80 : 38
        )

        let inside = hoverHitBox.contains(mouseLoc)
        if inside != isHovered {
            isHovered = inside
            updateNotchDimensions()
        }
    }

    private func updateNotchDimensions() {
        var targetW: CGFloat = 185.0
        var targetDropH: CGFloat = 2.0
        var shouldExpand = false

        if currentActivity.state == "idle" {
            if isHovered {
                targetW = 380.0
                targetDropH = 46.0
                shouldExpand = true
            } else {
                targetW = 185.0
                targetDropH = 2.0
                shouldExpand = false
            }
        } else {
            if isClickExpanded {
                targetW = 380.0
                targetDropH = 46.0
                shouldExpand = true
            } else {
                targetW = 185.0
                targetDropH = 2.0
                shouldExpand = false
            }
        }

        let totalH = notchH + targetDropH
        contentView.isExpandedMode = shouldExpand

        if currentW == targetW && currentH == totalH {
            contentView.needsLayout = true
            return
        }
        currentW = targetW
        currentH = totalH

        let xPos = screenMidX - (targetW / 2)
        let yPos = screenTop - totalH
        let targetRect = NSRect(x: xPos, y: yPos, width: targetW, height: totalH)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.28
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.panel.animator().setFrame(targetRect, display: true)
        }
    }
}
