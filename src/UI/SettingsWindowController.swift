import Cocoa

public enum SettingsTab: Int {
    case settings = 0
    case about = 1
}

// MARK: - Modern Glassmorphic Preferences & About Window Controller
public class SettingsWindowController: NSWindowController, NSWindowDelegate {
    public static let shared = SettingsWindowController()

    private var segmentedControl: NSSegmentedControl!
    private var containerView: NSView!

    private var settingsView: NSView!
    private var aboutView: NSView!

    // Settings Controls
    private var activeModePopup: NSPopUpButton!
    private var idleHoverCheck: NSButton!
    private var themePopup: NSPopUpButton!
    private var soundCheck: NSButton!
    private var hapticCheck: NSButton!
    private var launchLoginCheck: NSButton!

    private init() {
        let windowRect = NSRect(x: 0, y: 0, width: 520, height: 440)
        let window = NSWindow(
            contentRect: windowRect,
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Antigravity HUD Preferences"
        window.isReleasedWhenClosed = false
        window.center()
        window.titlebarAppearsTransparent = true
        window.appearance = NSAppearance(named: .darkAqua)

        super.init(window: window)
        window.delegate = self
        setupUI()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        guard let window = self.window else { return }

        let visualEffect = NSVisualEffectView(frame: window.contentView!.bounds)
        visualEffect.autoresizingMask = [.width, .height]
        visualEffect.material = .underWindowBackground
        visualEffect.state = .active
        visualEffect.blendingMode = .behindWindow
        window.contentView = visualEffect

        // Top Segmented Control Switcher
        segmentedControl = NSSegmentedControl(labels: ["⚙️ Settings", "ℹ️ About"], trackingMode: .selectOne, target: self, action: #selector(tabChanged))
        segmentedControl.selectedSegment = 0
        segmentedControl.frame = NSRect(x: (520 - 240) / 2, y: 390, width: 240, height: 32)
        visualEffect.addSubview(segmentedControl)

        // Main Container View
        containerView = NSView(frame: NSRect(x: 0, y: 0, width: 520, height: 380))
        visualEffect.addSubview(containerView)

        buildSettingsView()
        buildAboutView()

        showTab(.settings)
    }

    // MARK: - Build Settings Tab View
    private func buildSettingsView() {
        settingsView = NSView(frame: containerView.bounds)

        var currentY: CGFloat = 330

        // Section 1: Active Task Behavior
        let activeHeader = makeSectionHeader(title: "Active Task Notch Behavior", y: currentY)
        settingsView.addSubview(activeHeader)
        currentY -= 28

        let activeDesc = makeLabel(text: "Choose how the notch behaves while the AI agent is working/thinking:", y: currentY, isSub: true)
        settingsView.addSubview(activeDesc)
        currentY -= 32

        activeModePopup = NSPopUpButton(frame: NSRect(x: 35, y: currentY, width: 440, height: 26), pullsDown: false)
        activeModePopup.addItems(withTitles: [
            "🖱️ Click to Expand (Stay compact, expand only on click)",
            "🔍 Hover to Expand (Expands when mouse cursor enters)",
            "📌 Always Expanded (Stays open for duration of task)"
        ])
        activeModePopup.target = self
        activeModePopup.action = #selector(activeModeChanged)
        settingsView.addSubview(activeModePopup)
        currentY -= 40

        // Section 2: Idle Behavior & Theme
        let idleHeader = makeSectionHeader(title: "General & Appearance", y: currentY)
        settingsView.addSubview(idleHeader)
        currentY -= 30

        idleHoverCheck = makeCheckbox(title: "Expand notch drop-down on hover when Idle", y: currentY, action: #selector(idleHoverChanged))
        settingsView.addSubview(idleHoverCheck)
        currentY -= 32

        let themeLabel = makeLabel(text: "Active Theme & Shape:", y: currentY + 2, isSub: false)
        themeLabel.frame = NSRect(x: 35, y: currentY, width: 160, height: 20)
        settingsView.addSubview(themeLabel)

        themePopup = NSPopUpButton(frame: NSRect(x: 200, y: currentY - 2, width: 275, height: 26), pullsDown: false)
        for theme in ThemeManager.shared.availableThemes {
            themePopup.addItem(withTitle: theme.displayName)
        }
        themePopup.target = self
        themePopup.action = #selector(themeChanged)
        settingsView.addSubview(themePopup)
        currentY -= 40

        // Section 3: Sensory & System
        let sensoryHeader = makeSectionHeader(title: "Sensory & System", y: currentY)
        settingsView.addSubview(sensoryHeader)
        currentY -= 30

        soundCheck = makeCheckbox(title: "Play audio chime when agent completes a task", y: currentY, action: #selector(soundChanged))
        settingsView.addSubview(soundCheck)
        currentY -= 26

        hapticCheck = makeCheckbox(title: "Trigger trackpad haptic pulses on activity changes", y: currentY, action: #selector(hapticChanged))
        settingsView.addSubview(hapticCheck)
        currentY -= 26

        launchLoginCheck = makeCheckbox(title: "Launch Antigravity HUD automatically at macOS login", y: currentY, action: #selector(launchLoginChanged))
        settingsView.addSubview(launchLoginCheck)
    }

    // MARK: - Build About Tab View
    private func buildAboutView() {
        aboutView = NSView(frame: containerView.bounds)

        // App Icon / Futuristic Badge
        let iconImageView = NSImageView(frame: NSRect(x: (520 - 72) / 2, y: 270, width: 72, height: 72))
        if let icon = NSApp.applicationIconImage {
            iconImageView.image = icon
        }
        aboutView.addSubview(iconImageView)

        // Title
        let titleLabel = NSTextField(labelWithString: "Antigravity HUD")
        titleLabel.font = NSFont.systemFont(ofSize: 20, weight: .heavy)
        titleLabel.alignment = .center
        titleLabel.frame = NSRect(x: 0, y: 232, width: 520, height: 26)
        aboutView.addSubview(titleLabel)

        // Version
        let versionLabel = NSTextField(labelWithString: "Version 1.0.0 (Modular AppKit Build)")
        versionLabel.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .medium)
        versionLabel.textColor = NSColor(red: 0.0, green: 0.88, blue: 0.45, alpha: 1.0)
        versionLabel.alignment = .center
        versionLabel.frame = NSRect(x: 0, y: 210, width: 520, height: 18)
        aboutView.addSubview(versionLabel)

        // Description
        let descLabel = NSTextField(wrappingLabelWithString: "Native macOS Dynamic Notch Island interface for the Google Antigravity AI Agent. Real-time streaming status, dynamic geometry shapes, and high-performance AppKit HUD.")
        descLabel.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        descLabel.textColor = .secondaryLabelColor
        descLabel.alignment = .center
        descLabel.frame = NSRect(x: 50, y: 135, width: 420, height: 55)
        aboutView.addSubview(descLabel)

        // Author credits
        let authorLabel = NSTextField(labelWithString: "Created & engineered by Muhammad Fiko S. (@fikus942)")
        authorLabel.font = NSFont.systemFont(ofSize: 11.5, weight: .semibold)
        authorLabel.alignment = .center
        authorLabel.frame = NSRect(x: 0, y: 95, width: 520, height: 18)
        aboutView.addSubview(authorLabel)

        // GitHub Button
        let githubButton = NSButton(title: "View on GitHub ↗", target: self, action: #selector(openGitHub))
        githubButton.bezelStyle = .rounded
        githubButton.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        githubButton.frame = NSRect(x: (520 - 180) / 2, y: 45, width: 180, height: 32)
        aboutView.addSubview(githubButton)
    }

    // MARK: - Actions & Sync
    public func showWindow(tab: SettingsTab) {
        refreshControls()
        showTab(tab)
        segmentedControl.selectedSegment = tab.rawValue
        NSApp.activate(ignoringOtherApps: true)
        self.window?.makeKeyAndOrderFront(nil)
    }

    private func showTab(_ tab: SettingsTab) {
        containerView.subviews.forEach { $0.removeFromSuperview() }
        switch tab {
        case .settings:
            containerView.addSubview(settingsView)
            window?.title = "Antigravity HUD Preferences"
        case .about:
            containerView.addSubview(aboutView)
            window?.title = "About Antigravity HUD"
        }
    }

    @objc private func tabChanged() {
        if let tab = SettingsTab(rawValue: segmentedControl.selectedSegment) {
            showTab(tab)
        }
    }

    private func refreshControls() {
        let s = SettingsManager.shared
        s.loadSettings()

        switch s.activeTaskDisplayMode {
        case .clickOnly: activeModePopup.selectItem(at: 0)
        case .hoverExpands: activeModePopup.selectItem(at: 1)
        case .alwaysExpanded: activeModePopup.selectItem(at: 2)
        }

        idleHoverCheck.state = s.idleHoverExpands ? .on : .off
        soundCheck.state = s.soundEnabled ? .on : .off
        hapticCheck.state = s.hapticsEnabled ? .on : .off
        launchLoginCheck.state = s.launchAtLogin ? .on : .off

        let currentThemeId = ThemeManager.shared.activeThemeId
        if let idx = ThemeManager.shared.availableThemes.firstIndex(where: { $0.id == currentThemeId }) {
            themePopup.selectItem(at: idx)
        }
    }

    @objc private func activeModeChanged() {
        switch activeModePopup.indexOfSelectedItem {
        case 0: SettingsManager.shared.activeTaskDisplayMode = .clickOnly
        case 1: SettingsManager.shared.activeTaskDisplayMode = .hoverExpands
        case 2: SettingsManager.shared.activeTaskDisplayMode = .alwaysExpanded
        default: break
        }
        SettingsManager.shared.saveSettings()
    }

    @objc private func idleHoverChanged() {
        SettingsManager.shared.idleHoverExpands = (idleHoverCheck.state == .on)
        SettingsManager.shared.saveSettings()
    }

    @objc private func themeChanged() {
        let idx = themePopup.indexOfSelectedItem
        if idx >= 0 && idx < ThemeManager.shared.availableThemes.count {
            let selected = ThemeManager.shared.availableThemes[idx]
            ThemeManager.shared.setTheme(withId: selected.id)
        }
    }

    @objc private func soundChanged() {
        SettingsManager.shared.soundEnabled = (soundCheck.state == .on)
        SettingsManager.shared.saveSettings()
    }

    @objc private func hapticChanged() {
        SettingsManager.shared.hapticsEnabled = (hapticCheck.state == .on)
        SettingsManager.shared.saveSettings()
    }

    @objc private func launchLoginChanged() {
        SettingsManager.shared.launchAtLogin = (launchLoginCheck.state == .on)
        SettingsManager.shared.saveSettings()
    }

    @objc private func openGitHub() {
        if let url = URL(string: "https://github.com/fiko942/antigravity-hud") {
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: - UI Helpers
    private func makeSectionHeader(title: String, y: CGFloat) -> NSTextField {
        let label = NSTextField(labelWithString: title)
        label.font = NSFont.systemFont(ofSize: 13, weight: .bold)
        label.textColor = .labelColor
        label.frame = NSRect(x: 35, y: y, width: 440, height: 18)
        return label
    }

    private func makeLabel(text: String, y: CGFloat, isSub: Bool) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = isSub ? NSFont.systemFont(ofSize: 11) : NSFont.systemFont(ofSize: 12)
        label.textColor = isSub ? .secondaryLabelColor : .labelColor
        label.frame = NSRect(x: 35, y: y, width: 440, height: 16)
        return label
    }

    private func makeCheckbox(title: String, y: CGFloat, action: Selector) -> NSButton {
        let button = NSButton(checkboxWithTitle: title, target: self, action: action)
        button.font = NSFont.systemFont(ofSize: 12)
        button.frame = NSRect(x: 35, y: y, width: 440, height: 18)
        return button
    }
}
