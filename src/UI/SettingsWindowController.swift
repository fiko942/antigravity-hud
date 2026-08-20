import Cocoa

public enum SettingsTab: Int {
    case settings = 0
    case about = 1
}

// MARK: - Modern Telegram-Style Liquid Sliding Bubble Tab Control
public class LiquidPillSegmentedControl: NSView {
    public var onSelectionChanged: ((Int) -> Void)?
    public private(set) var selectedIndex: Int = 0

    private var items: [String] = []
    private let bubbleLayer = CALayer()
    private var itemButtons: [NSButton] = []

    public init(items: [String], frame: NSRect) {
        self.items = items
        super.init(frame: frame)
        wantsLayer = true
        setupUI()
    }

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
    }

    private func setupUI() {
        guard let layer = self.layer else { return }

        // Outer pill capsule container (Adaptive Dark Glass)
        layer.cornerRadius = bounds.height / 2
        layer.backgroundColor = NSColor(white: 0.12, alpha: 0.75).cgColor
        layer.borderColor = NSColor(white: 1.0, alpha: 0.14).cgColor
        layer.borderWidth = 1.0
        layer.masksToBounds = false

        // Sliding bubble indicator (Telegram / Dynamic Island style)
        let padding: CGFloat = 3.0
        let itemW = (bounds.width - (padding * 2)) / CGFloat(max(1, items.count))
        let itemH = bounds.height - (padding * 2)

        bubbleLayer.cornerRadius = itemH / 2
        bubbleLayer.backgroundColor = NSColor(red: 0.0, green: 0.52, blue: 0.98, alpha: 0.95).cgColor
        bubbleLayer.borderColor = NSColor(white: 1.0, alpha: 0.25).cgColor
        bubbleLayer.borderWidth = 0.5
        bubbleLayer.shadowColor = NSColor(red: 0.0, green: 0.45, blue: 0.98, alpha: 0.5).cgColor
        bubbleLayer.shadowOpacity = 0.45
        bubbleLayer.shadowRadius = 6
        bubbleLayer.shadowOffset = CGSize(width: 0, height: -1)
        bubbleLayer.frame = CGRect(x: padding, y: padding, width: itemW, height: itemH)
        layer.addSublayer(bubbleLayer)

        // Item buttons
        for (i, title) in items.enumerated() {
            let btn = NSButton(title: title, target: self, action: #selector(itemClicked(_:)))
            btn.tag = i
            btn.isBordered = false
            btn.wantsLayer = true
            btn.font = NSFont.systemFont(ofSize: 12.5, weight: i == 0 ? .bold : .medium)
            btn.contentTintColor = i == 0 ? .white : NSColor(white: 0.7, alpha: 1.0)
            btn.frame = NSRect(x: padding + CGFloat(i) * itemW, y: padding, width: itemW, height: itemH)
            addSubview(btn)
            itemButtons.append(btn)
        }
    }

    public func setSelectedIndex(_ index: Int, animated: Bool = true) {
        guard index >= 0 && index < items.count else { return }
        selectedIndex = index

        let padding: CGFloat = 3.0
        let itemW = (bounds.width - (padding * 2)) / CGFloat(items.count)
        let targetX = padding + CGFloat(index) * itemW
        let targetFrame = CGRect(x: targetX, y: padding, width: itemW, height: bounds.height - (padding * 2))

        for (i, btn) in itemButtons.enumerated() {
            btn.font = NSFont.systemFont(ofSize: 12.5, weight: i == index ? .bold : .medium)
            btn.contentTintColor = i == index ? .white : NSColor(white: 0.7, alpha: 1.0)
        }

        if animated {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.26)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(controlPoints: 0.2, 0.9, 0.3, 1.0))
            bubbleLayer.frame = targetFrame
            CATransaction.commit()
        } else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            bubbleLayer.frame = targetFrame
            CATransaction.commit()
        }
    }

    @objc private func itemClicked(_ sender: NSButton) {
        let index = sender.tag
        if index != selectedIndex {
            setSelectedIndex(index, animated: true)
            SensoryManager.shared.triggerHaptic(pattern: .generic)
            onSelectionChanged?(index)
        }
    }
}

public class FlippedSettingsView: NSView {
    public override var isFlipped: Bool { true }
}

// MARK: - Modern Glassmorphic Preferences & About Window Controller
public class SettingsWindowController: NSWindowController, NSWindowDelegate {
    public static let shared = SettingsWindowController()

    private var pillSegmentedControl: LiquidPillSegmentedControl!
    private var containerView: NSView!

    private var settingsScrollView: NSScrollView!
    private var settingsContentView: FlippedSettingsView!
    private var aboutView: NSView!

    // Preview Component
    private var previewBox: NotchPreviewBoxView!
    private var previewToggle: NSSegmentedControl!

    // Dimension Sliders & Labels (Expanded / Open / Hover)
    private var expWidthSlider: NSSlider!
    private var expWidthValueLabel: NSTextField!
    private var expHeightSlider: NSSlider!
    private var expHeightValueLabel: NSTextField!

    // Dimension Sliders & Labels (Compact / Closed / Idle)
    private var compWidthSlider: NSSlider!
    private var compWidthValueLabel: NSTextField!
    private var compHeightSlider: NSSlider!
    private var compHeightValueLabel: NSTextField!

    private var resetDimButton: NSButton!

    // Settings Controls
    private var activeModePopup: NSPopUpButton!
    private var idleHoverCheck: NSButton!
    private var themePopup: NSPopUpButton!
    private var soundCheck: NSButton!
    private var hapticCheck: NSButton!
    private var launchLoginCheck: NSButton!

    private init() {
        let windowRect = NSRect(x: 0, y: 0, width: 560, height: 720)
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
        window.level = .floating

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

        // Top Liquid Pill Control
        pillSegmentedControl = LiquidPillSegmentedControl(
            items: ["⚙️ Settings", "ℹ️ About"],
            frame: NSRect(x: (560 - 240) / 2, y: 670, width: 240, height: 32)
        )
        pillSegmentedControl.onSelectionChanged = { [weak self] index in
            if let tab = SettingsTab(rawValue: index) {
                self?.showTab(tab)
            }
        }
        visualEffect.addSubview(pillSegmentedControl)

        // Main Container View
        containerView = NSView(frame: NSRect(x: 0, y: 0, width: 560, height: 660))
        visualEffect.addSubview(containerView)

        buildSettingsView()
        buildAboutView()

        showTab(.settings)
    }

    // MARK: - Build Settings Tab View
    private func buildSettingsView() {
        settingsScrollView = NSScrollView(frame: containerView.bounds)
        settingsScrollView.hasVerticalScroller = true
        settingsScrollView.drawsBackground = false
        settingsScrollView.autoresizingMask = [.width, .height]

        let totalContentH: CGFloat = 720
        settingsContentView = FlippedSettingsView(frame: NSRect(x: 0, y: 0, width: 560, height: totalContentH))
        settingsScrollView.documentView = settingsContentView

        var currentY: CGFloat = 16

        // 1. Live Interactive Preview Section
        let previewHeader = makeSectionHeader(title: "Interactive Notch Live Preview", y: currentY)
        previewHeader.frame = NSRect(x: 35, y: currentY, width: 200, height: 18)
        settingsContentView.addSubview(previewHeader)

        // State Toggle [ Open / Expanded ] vs [ Closed / Compact ]
        previewToggle = NSSegmentedControl(labels: ["📌 Open (Expanded)", "🔒 Closed (Compact)"], trackingMode: .selectOne, target: self, action: #selector(previewToggleChanged))
        previewToggle.selectedSegment = 0
        previewToggle.segmentStyle = .rounded
        previewToggle.frame = NSRect(x: 240, y: currentY - 2, width: 285, height: 24)
        settingsContentView.addSubview(previewToggle)
        currentY += 28

        previewBox = NotchPreviewBoxView(frame: NSRect(x: 35, y: currentY, width: 490, height: 100))
        settingsContentView.addSubview(previewBox)
        currentY += 114

        // 2. Custom Notch Dimensions Section
        let dimHeader = makeSectionHeader(title: "Custom Notch Dimensions (Width & Height)", y: currentY)
        dimHeader.frame = NSRect(x: 35, y: currentY, width: 340, height: 18)
        settingsContentView.addSubview(dimHeader)

        // Reset to Defaults Button
        resetDimButton = NSButton(title: "🔄 Reset Defaults", target: self, action: #selector(resetDimensionsClicked))
        resetDimButton.bezelStyle = .inline
        resetDimButton.font = NSFont.systemFont(ofSize: 11, weight: .semibold)
        resetDimButton.frame = NSRect(x: 385, y: currentY - 2, width: 140, height: 22)
        settingsContentView.addSubview(resetDimButton)
        currentY += 24

        // --- SUBSECTION A: Expanded Mode (Posisi Terbuka / Hover / Active) ---
        let expSubHeader = makeSubSectionHeader(title: "Posisi Terbuka / Hover / Active (Expanded)", y: currentY)
        settingsContentView.addSubview(expSubHeader)
        currentY += 20

        // Expanded Width Slider
        let expWLabel = makeLabel(text: "Expanded Width:", y: currentY, isSub: false)
        expWLabel.frame = NSRect(x: 35, y: currentY, width: 180, height: 18)
        settingsContentView.addSubview(expWLabel)

        expWidthValueLabel = makeValueLabel(text: "380 pt", x: 450, y: currentY)
        settingsContentView.addSubview(expWidthValueLabel)
        currentY += 18

        expWidthSlider = NSSlider(value: 380, minValue: 280, maxValue: 560, target: self, action: #selector(expandedWidthChanged))
        expWidthSlider.frame = NSRect(x: 35, y: currentY, width: 490, height: 20)
        settingsContentView.addSubview(expWidthSlider)
        currentY += 24

        // Expanded Height Slider
        let expHLabel = makeLabel(text: "Expanded Drop Height:", y: currentY, isSub: false)
        expHLabel.frame = NSRect(x: 35, y: currentY, width: 180, height: 18)
        settingsContentView.addSubview(expHLabel)

        expHeightValueLabel = makeValueLabel(text: "46 pt", x: 450, y: currentY)
        settingsContentView.addSubview(expHeightValueLabel)
        currentY += 18

        expHeightSlider = NSSlider(value: 46, minValue: 32, maxValue: 80, target: self, action: #selector(expandedHeightChanged))
        expHeightSlider.frame = NSRect(x: 35, y: currentY, width: 490, height: 20)
        settingsContentView.addSubview(expHeightSlider)
        currentY += 28

        // --- SUBSECTION B: Compact Mode (Posisi Tertutup / Idle) ---
        let compSubHeader = makeSubSectionHeader(title: "Posisi Tertutup / Idle (Compact)", y: currentY)
        settingsContentView.addSubview(compSubHeader)
        currentY += 20

        // Compact Width Slider
        let compWLabel = makeLabel(text: "Compact Idle Width:", y: currentY, isSub: false)
        compWLabel.frame = NSRect(x: 35, y: currentY, width: 180, height: 18)
        settingsContentView.addSubview(compWLabel)

        compWidthValueLabel = makeValueLabel(text: "185 pt", x: 450, y: currentY)
        settingsContentView.addSubview(compWidthValueLabel)
        currentY += 18

        compWidthSlider = NSSlider(value: 185, minValue: 140, maxValue: 260, target: self, action: #selector(compactWidthChanged))
        compWidthSlider.frame = NSRect(x: 35, y: currentY, width: 490, height: 20)
        settingsContentView.addSubview(compWidthSlider)
        currentY += 24

        // Compact Height Slider
        let compHLabel = makeLabel(text: "Compact Drop Height:", y: currentY, isSub: false)
        compHLabel.frame = NSRect(x: 35, y: currentY, width: 180, height: 18)
        settingsContentView.addSubview(compHLabel)

        compHeightValueLabel = makeValueLabel(text: "2 pt", x: 450, y: currentY)
        settingsContentView.addSubview(compHeightValueLabel)
        currentY += 18

        compHeightSlider = NSSlider(value: 2, minValue: 0, maxValue: 20, target: self, action: #selector(compactHeightChanged))
        compHeightSlider.frame = NSRect(x: 35, y: currentY, width: 490, height: 20)
        settingsContentView.addSubview(compHeightSlider)
        currentY += 32

        // 3. Behavior & Theme Section
        let activeHeader = makeSectionHeader(title: "Behavior & Theme", y: currentY)
        settingsContentView.addSubview(activeHeader)
        currentY += 26

        let themeLabel = makeLabel(text: "Active Theme & Contour:", y: currentY + 2, isSub: false)
        themeLabel.frame = NSRect(x: 35, y: currentY, width: 170, height: 20)
        settingsContentView.addSubview(themeLabel)

        themePopup = NSPopUpButton(frame: NSRect(x: 215, y: currentY - 2, width: 310, height: 26), pullsDown: false)
        for theme in ThemeManager.shared.availableThemes {
            themePopup.addItem(withTitle: theme.displayName)
        }
        themePopup.target = self
        themePopup.action = #selector(themeChanged)
        settingsContentView.addSubview(themePopup)
        currentY += 32

        activeModePopup = NSPopUpButton(frame: NSRect(x: 35, y: currentY, width: 490, height: 26), pullsDown: false)
        activeModePopup.addItems(withTitles: [
            "🖱️ Click to Expand (Stay compact, expand only on click)",
            "🔍 Hover to Expand (Expands when mouse cursor enters)",
            "📌 Always Expanded (Stays open for duration of task)"
        ])
        activeModePopup.target = self
        activeModePopup.action = #selector(activeModeChanged)
        settingsContentView.addSubview(activeModePopup)
        currentY += 32

        idleHoverCheck = makeCheckbox(title: "Expand notch drop-down on hover when Idle", y: currentY, action: #selector(idleHoverChanged))
        settingsContentView.addSubview(idleHoverCheck)
        currentY += 34

        // 4. Sensory & Automation Section
        let sensoryHeader = makeSectionHeader(title: "Sensory & Automation", y: currentY)
        settingsContentView.addSubview(sensoryHeader)
        currentY += 26

        soundCheck = makeCheckbox(title: "Play audio chime on task completion", y: currentY, action: #selector(soundChanged))
        settingsContentView.addSubview(soundCheck)
        currentY += 24

        hapticCheck = makeCheckbox(title: "Enable trackpad haptic feedback on state changes", y: currentY, action: #selector(hapticChanged))
        settingsContentView.addSubview(hapticCheck)
        currentY += 24

        launchLoginCheck = makeCheckbox(title: "Launch Antigravity HUD automatically at login", y: currentY, action: #selector(launchLoginChanged))
        settingsContentView.addSubview(launchLoginCheck)
    }

    // MARK: - Build About Tab View
    private func buildAboutView() {
        aboutView = FlippedSettingsView(frame: containerView.bounds)

        var curY: CGFloat = 24

        // App Icon
        let iconImageView = NSImageView(frame: NSRect(x: (560 - 72) / 2, y: curY, width: 72, height: 72))
        if let iconPath = Bundle.main.path(forResource: "AppIcon", ofType: "icns"),
           let appIcon = NSImage(contentsOfFile: iconPath) {
            iconImageView.image = appIcon
        } else if let img = NSApp.applicationIconImage {
            iconImageView.image = img
        }
        aboutView.addSubview(iconImageView)
        curY += 80

        // Title
        let titleLabel = NSTextField(labelWithString: "Antigravity HUD")
        titleLabel.font = NSFont.systemFont(ofSize: 21, weight: .heavy)
        titleLabel.alignment = .center
        titleLabel.frame = NSRect(x: 0, y: curY, width: 560, height: 26)
        aboutView.addSubview(titleLabel)
        curY += 28

        // Version
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.1.0"
        let versionLabel = NSTextField(labelWithString: "Version \(appVersion) (Powered by SQLite3 Engine)")
        versionLabel.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .semibold)
        versionLabel.textColor = NSColor(red: 0.0, green: 0.88, blue: 0.45, alpha: 1.0)
        versionLabel.alignment = .center
        versionLabel.frame = NSRect(x: 0, y: curY, width: 560, height: 18)
        aboutView.addSubview(versionLabel)
        curY += 26

        // Description
        let descLabel = NSTextField(wrappingLabelWithString: "Native macOS Dynamic Notch Island interface for Google Antigravity AI Agent.\nReal-time streaming status, atomic SQLite3 persistence, custom notch dimensions,\nand multi-theme adaptive AppKit HUD.")
        descLabel.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        descLabel.textColor = .secondaryLabelColor
        descLabel.alignment = .center
        descLabel.frame = NSRect(x: 40, y: curY, width: 480, height: 55)
        aboutView.addSubview(descLabel)
        curY += 60

        // Author credits & Portfolio Link
        let authorButton = NSButton(
            title: "Created & engineered by Wiji Fiko Teren (@fiko942)",
            target: self,
            action: #selector(openPortfolio)
        )
        authorButton.isBordered = false
        authorButton.font = NSFont.systemFont(ofSize: 12.5, weight: .bold)
        authorButton.contentTintColor = NSColor(red: 0.0, green: 0.88, blue: 0.45, alpha: 1.0)
        authorButton.frame = NSRect(x: 0, y: curY, width: 560, height: 20)
        aboutView.addSubview(authorButton)
        curY += 32

        // Action Buttons: Portfolio, GitHub, & Donate Saweria
        let btnW: CGFloat = 145
        let spacing: CGFloat = 10
        let totalW = (btnW * 3) + (spacing * 2)
        let startX = (560 - totalW) / 2

        let portfolioBtn = NSButton(title: "🌐 Portfolio ↗", target: self, action: #selector(openPortfolio))
        portfolioBtn.bezelStyle = .rounded
        portfolioBtn.font = NSFont.systemFont(ofSize: 11.5, weight: .medium)
        portfolioBtn.frame = NSRect(x: startX, y: curY, width: btnW, height: 32)
        aboutView.addSubview(portfolioBtn)

        let githubBtn = NSButton(title: "🐙 GitHub ↗", target: self, action: #selector(openGitHub))
        githubBtn.bezelStyle = .rounded
        githubBtn.font = NSFont.systemFont(ofSize: 11.5, weight: .medium)
        githubBtn.frame = NSRect(x: startX + btnW + spacing, y: curY, width: btnW, height: 32)
        aboutView.addSubview(githubBtn)

        let donateBtn = NSButton(title: "☕ Donate ↗", target: self, action: #selector(openSaweria))
        donateBtn.bezelStyle = .rounded
        donateBtn.font = NSFont.systemFont(ofSize: 11.5, weight: .bold)
        donateBtn.contentTintColor = NSColor(red: 1.0, green: 0.65, blue: 0.0, alpha: 1.0)
        donateBtn.frame = NSRect(x: startX + (btnW + spacing) * 2, y: curY, width: btnW, height: 32)
        aboutView.addSubview(donateBtn)
        curY += 48

        // Saweria QR Code Card
        let possiblePaths = [
            Bundle.main.path(forResource: "saweria-qr", ofType: "png"),
            "/Applications/AntigravityHUD.app/Contents/Resources/saweria-qr.png",
            "resources/saweria-qr.png",
            "Resources/saweria-qr.png"
        ].compactMap { $0 }

        if let qrPath = possiblePaths.first(where: { FileManager.default.fileExists(atPath: $0) }),
           let qrImage = NSImage(contentsOfFile: qrPath) {
            let qrContainer = NSView(frame: NSRect(x: (560 - 150) / 2, y: curY, width: 150, height: 160))
            qrContainer.wantsLayer = true
            qrContainer.layer?.backgroundColor = NSColor(white: 0.15, alpha: 0.8).cgColor
            qrContainer.layer?.cornerRadius = 12
            qrContainer.layer?.borderColor = NSColor(white: 1.0, alpha: 0.12).cgColor
            qrContainer.layer?.borderWidth = 1.0

            let qrView = NSImageView(frame: NSRect(x: 15, y: 30, width: 120, height: 120))
            qrView.image = qrImage
            qrContainer.addSubview(qrView)

            let scanLabel = NSTextField(labelWithString: "Scan QR to Donate")
            scanLabel.font = NSFont.systemFont(ofSize: 10, weight: .semibold)
            scanLabel.textColor = NSColor(white: 0.75, alpha: 1.0)
            scanLabel.alignment = .center
            scanLabel.frame = NSRect(x: 0, y: 8, width: 150, height: 16)
            qrContainer.addSubview(scanLabel)

            aboutView.addSubview(qrContainer)
        }
    }

    // MARK: - Actions & Sync
    public func showWindow(tab: SettingsTab) {
        refreshControls()
        showTab(tab)
        pillSegmentedControl.setSelectedIndex(tab.rawValue, animated: false)
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        self.window?.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }

    private func showTab(_ tab: SettingsTab) {
        containerView.subviews.forEach { $0.removeFromSuperview() }
        switch tab {
        case .settings:
            containerView.addSubview(settingsScrollView)
            window?.title = "Antigravity HUD Preferences"
        case .about:
            containerView.addSubview(aboutView)
            window?.title = "About Antigravity HUD"
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

        // Expanded Dimensions
        expWidthSlider.doubleValue = Double(s.expandedWidth)
        expWidthValueLabel.stringValue = "\(Int(s.expandedWidth)) pt"

        expHeightSlider.doubleValue = Double(s.expandedHeight)
        expHeightValueLabel.stringValue = "\(Int(s.expandedHeight)) pt"

        // Compact Dimensions
        compWidthSlider.doubleValue = Double(s.compactWidth)
        compWidthValueLabel.stringValue = "\(Int(s.compactWidth)) pt"

        compHeightSlider.doubleValue = Double(s.compactHeight)
        compHeightValueLabel.stringValue = "\(Int(s.compactHeight)) pt"

        // Update preview canvas
        previewBox.previewExpandedWidth = s.expandedWidth
        previewBox.previewExpandedHeight = s.expandedHeight
        previewBox.previewCompactWidth = s.compactWidth
        previewBox.previewCompactHeight = s.compactHeight
        previewBox.updatePreview()

        let currentThemeId = ThemeManager.shared.activeThemeId
        if let idx = ThemeManager.shared.availableThemes.firstIndex(where: { $0.id == currentThemeId }) {
            themePopup.selectItem(at: idx)
        }
    }

    // MARK: - Dimension Sliders Action Handlers
    @objc private func expandedWidthChanged() {
        let val = CGFloat(expWidthSlider.doubleValue)
        expWidthValueLabel.stringValue = "\(Int(val)) pt"
        previewBox.previewExpandedWidth = val

        SettingsManager.shared.expandedWidth = val
        SettingsManager.shared.saveSettings()
    }

    @objc private func expandedHeightChanged() {
        let val = CGFloat(expHeightSlider.doubleValue)
        expHeightValueLabel.stringValue = "\(Int(val)) pt"
        previewBox.previewExpandedHeight = val

        SettingsManager.shared.expandedHeight = val
        SettingsManager.shared.saveSettings()
    }

    @objc private func compactWidthChanged() {
        let val = CGFloat(compWidthSlider.doubleValue)
        compWidthValueLabel.stringValue = "\(Int(val)) pt"
        previewBox.previewCompactWidth = val

        SettingsManager.shared.compactWidth = val
        SettingsManager.shared.saveSettings()
    }

    @objc private func compactHeightChanged() {
        let val = CGFloat(compHeightSlider.doubleValue)
        compHeightValueLabel.stringValue = "\(Int(val)) pt"
        previewBox.previewCompactHeight = val

        SettingsManager.shared.compactHeight = val
        SettingsManager.shared.saveSettings()
    }

    @objc private func resetDimensionsClicked() {
        SettingsManager.shared.resetDimensionsToDefaults()
        SensoryManager.shared.triggerHaptic(pattern: .generic)
        refreshControls()
    }

    @objc private func previewToggleChanged() {
        previewBox.isExpandedPreview = (previewToggle.selectedSegment == 0)
        SensoryManager.shared.triggerHaptic(pattern: .generic)
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
            previewBox.updatePreview()
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

    @objc private func openPortfolio() {
        if let url = URL(string: "https://wijifikoteren.streampeg.com") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc private func openSaweria() {
        if let url = URL(string: "https://saweria.co/wijifikoteren") {
            NSWorkspace.shared.open(url)
        }
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
        label.frame = NSRect(x: 35, y: y, width: 490, height: 18)
        return label
    }

    private func makeSubSectionHeader(title: String, y: CGFloat) -> NSTextField {
        let label = NSTextField(labelWithString: title)
        label.font = NSFont.systemFont(ofSize: 11.5, weight: .semibold)
        label.textColor = NSColor(red: 0.0, green: 0.65, blue: 1.0, alpha: 1.0)
        label.frame = NSRect(x: 35, y: y, width: 490, height: 16)
        return label
    }

    private func makeLabel(text: String, y: CGFloat, isSub: Bool) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = NSFont.systemFont(ofSize: isSub ? 11 : 12.5, weight: isSub ? .regular : .medium)
        label.textColor = isSub ? .secondaryLabelColor : .labelColor
        label.frame = NSRect(x: 35, y: y, width: 490, height: 18)
        return label
    }

    private func makeValueLabel(text: String, x: CGFloat, y: CGFloat) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .bold)
        label.textColor = NSColor(red: 0.0, green: 0.88, blue: 0.45, alpha: 1.0)
        label.alignment = .right
        label.frame = NSRect(x: x, y: y, width: 75, height: 18)
        return label
    }

    private func makeCheckbox(title: String, y: CGFloat, action: Selector) -> NSButton {
        let btn = NSButton(checkboxWithTitle: title, target: self, action: action)
        btn.font = NSFont.systemFont(ofSize: 12.5, weight: .regular)
        btn.frame = NSRect(x: 35, y: y, width: 490, height: 20)
        return btn
    }
}
