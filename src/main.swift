import Cocoa
import QuartzCore

// MARK: - Single Instance Lock (Kernel Mutex)
func ensureSingleInstance() -> Bool {
    let lockPath = "/tmp/antigravity-hud.lock"
    let fd = open(lockPath, O_CREAT | O_WRONLY, 0o644)
    if fd < 0 { return false }
    if flock(fd, LOCK_EX | LOCK_NB) != 0 {
        return false // Another instance already running
    }
    return true
}

// MARK: - Auto-Register LaunchAgent on Login
func ensureLaunchAgentInstalled() {
    let bundlePath = Bundle.main.bundlePath
    guard bundlePath.hasSuffix(".app") else { return }

    let agentDir = ("~/Library/LaunchAgents" as NSString).expandingTildeInPath
    let plistPath = (agentDir as NSString).appendingPathComponent("com.google.antigravity.hud.plist")
    let execPath = (bundlePath as NSString).appendingPathComponent("Contents/MacOS/AntigravityHUD")

    let plistContent = """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>Label</key>
        <string>com.google.antigravity.hud</string>
        <key>ProgramArguments</key>
        <array>
            <string>\(execPath)</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
        <key>StandardOutPath</key>
        <string>/tmp/antigravity-hud.log</string>
        <key>StandardErrorPath</key>
        <string>/tmp/antigravity-hud.error.log</string>
    </dict>
    </plist>
    """

    try? FileManager.default.createDirectory(atPath: agentDir, withIntermediateDirectories: true)
    if !FileManager.default.fileExists(atPath: plistPath) {
        try? plistContent.write(toFile: plistPath, atomically: true, encoding: .utf8)
        let task = Process()
        task.launchPath = "/bin/launchctl"
        task.arguments = ["load", "-w", plistPath]
        try? task.run()
    }
}

// MARK: - Notch Dynamic Island Panel (Level 102 above Menu Bar)
class AntigravityNotchPanel: NSPanel {
    var onPanelClicked: (() -> Void)?

    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .borderless, .hudWindow, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        self.level = NSWindow.Level(rawValue: 102) // On top of Menu Bar & Notch
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

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        return frameRect
    }

    override func mouseDown(with event: NSEvent) {
        onPanelClicked?()
    }
}

// MARK: - Animated Cyber Waveform / Equalizer Component
class CyberEqualizerLayer: CALayer {
    private var bars: [CALayer] = []
    private let barCount = 4
    private let barWidth: CGFloat = 2.5
    private let barSpacing: CGFloat = 2.5

    override init() {
        super.init()
        setupBars()
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBars()
    }

    private func setupBars() {
        for _ in 0..<barCount {
            let bar = CALayer()
            bar.cornerRadius = 1.25
            bar.backgroundColor = NSColor(red: 0.0, green: 0.94, blue: 1.0, alpha: 1.0).cgColor
            addSublayer(bar)
            bars.append(bar)
        }
        updateLayout()
    }

    func updateLayout() {
        let totalW = CGFloat(barCount) * barWidth + CGFloat(barCount - 1) * barSpacing
        let startX = (bounds.width - totalW) / 2
        let midY = bounds.height / 2

        for (i, bar) in bars.enumerated() {
            let h: CGFloat = 4.0
            let x = startX + CGFloat(i) * (barWidth + barSpacing)
            bar.frame = CGRect(x: x, y: midY - (h / 2), width: barWidth, height: h)
        }
    }

    func setAnimating(_ animating: Bool, color: CGColor) {
        for (i, bar) in bars.enumerated() {
            bar.backgroundColor = color
            bar.removeAnimation(forKey: "equalize")

            if animating {
                let anim = CAKeyframeAnimation(keyPath: "bounds.size.height")
                let minH: CGFloat = 3.0
                let maxH: CGFloat = CGFloat([14, 18, 16, 12][i])
                let midH: CGFloat = CGFloat([8, 12, 10, 7][i])

                anim.values = [minH, maxH, midH, maxH * 0.7, minH]
                anim.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
                anim.duration = Double([0.65, 0.55, 0.75, 0.60][i])
                anim.repeatCount = .infinity
                anim.autoreverses = true
                anim.timeOffset = Double(i) * 0.15
                anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

                bar.add(anim, forKey: "equalize")
            } else {
                bar.frame.size.height = 3.0
            }
        }
    }
}

// MARK: - Notch Dynamic Island View (100% Solid Black with Drop-Down Click/Hover Animation)
class NotchIslandContentView: NSView {
    override var isFlipped: Bool { true } // (0,0) is TOP-LEFT of window (screen top bezel)

    // Left Beacon & Icon
    private let beaconLayer = CALayer()
    private let beaconPulseLayer = CALayer()

    // Center Labels
    private let headerLabel = NSTextField(labelWithString: "ANTIGRAVITY • READY")
    private let detailLabel = NSTextField(labelWithString: "Standby for prompt")

    // Right Animated Equalizer
    private let equalizer = CyberEqualizerLayer()

    var onViewClicked: (() -> Void)?

    private var currentState: String = "idle"
    private var currentDetail: String = "Standby for prompt"
    private var themeColor: NSColor = NSColor(red: 0.0, green: 0.88, blue: 0.45, alpha: 1.0)
    var isExpandedMode: Bool = false

    let notchH: CGFloat = 32.0 // Physical hardware notch height

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        wantsLayer = true

        // Status Beacon
        beaconPulseLayer.cornerRadius = 8
        layer?.addSublayer(beaconPulseLayer)

        beaconLayer.cornerRadius = 4
        beaconLayer.shadowRadius = 5
        beaconLayer.shadowOpacity = 1.0
        beaconLayer.shadowOffset = .zero
        layer?.addSublayer(beaconLayer)

        // Labels
        headerLabel.font = NSFont.monospacedSystemFont(ofSize: 9.5, weight: .black)
        headerLabel.textColor = themeColor
        headerLabel.backgroundColor = .clear
        headerLabel.isBezeled = false
        headerLabel.isEditable = false
        addSubview(headerLabel)

        detailLabel.font = NSFont.systemFont(ofSize: 11.5, weight: .semibold)
        detailLabel.textColor = .white
        detailLabel.backgroundColor = .clear
        detailLabel.isBezeled = false
        detailLabel.isEditable = false
        detailLabel.lineBreakMode = .byTruncatingTail
        addSubview(detailLabel)

        // Equalizer
        layer?.addSublayer(equalizer)

        startPulseAnimation()
        applyTheme(state: "idle")
    }

    override func mouseDown(with event: NSEvent) {
        onViewClicked?()
    }

    // 100% Solid Opaque Pure Black Drawing (Top flat, Bottom rounded)
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let w = bounds.width
        let h = bounds.height
        let cornerRadius: CGFloat = isExpandedMode ? 18.0 : 8.0

        let path = NSBezierPath()
        // Top edge flush with screen top bezel
        path.move(to: NSPoint(x: 0, y: 0))
        path.line(to: NSPoint(x: w, y: 0))
        path.line(to: NSPoint(x: w, y: h - cornerRadius))
        path.appendArc(withCenter: NSPoint(x: w - cornerRadius, y: h - cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: 90, clockwise: false)
        path.line(to: NSPoint(x: cornerRadius, y: h))
        path.appendArc(withCenter: NSPoint(x: cornerRadius, y: h - cornerRadius), radius: cornerRadius, startAngle: 90, endAngle: 180, clockwise: false)
        path.close()

        // Fill 100% solid pure black (zero transparency)
        NSColor.black.setFill()
        path.fill()

        // Stroke neon glowing bottom lip
        let glowPath = NSBezierPath()
        if isExpandedMode {
            glowPath.move(to: NSPoint(x: 0, y: max(0, h - cornerRadius - 4)))
            glowPath.line(to: NSPoint(x: 0, y: h - cornerRadius))
            glowPath.appendArc(withCenter: NSPoint(x: cornerRadius, y: h - cornerRadius), radius: cornerRadius, startAngle: 180, endAngle: 90, clockwise: true)
            glowPath.line(to: NSPoint(x: w - cornerRadius, y: h))
            glowPath.appendArc(withCenter: NSPoint(x: w - cornerRadius, y: h - cornerRadius), radius: cornerRadius, startAngle: 90, endAngle: 0, clockwise: true)
            glowPath.line(to: NSPoint(x: w, y: max(0, h - cornerRadius - 4)))
        } else {
            // Idle Compact: Subtle glowing notch bottom rim
            glowPath.move(to: NSPoint(x: 10, y: h - 1.5))
            glowPath.line(to: NSPoint(x: w - 10, y: h - 1.5))
        }

        glowPath.lineWidth = isExpandedMode ? 1.8 : 2.0
        themeColor.withAlphaComponent(isExpandedMode ? 0.9 : 0.85).setStroke()
        glowPath.stroke()
    }

    override func layout() {
        super.layout()
        needsDisplay = true
        updateElementPositions()
    }

    private func updateElementPositions() {
        let w = bounds.width
        let h = bounds.height

        if !isExpandedMode {
            // Idle Compact: Everything hidden, ONLY the subtle glowing bottom notch border & status dot
            beaconLayer.frame = CGRect(x: (w / 2) - 3.5, y: h - 6, width: 7, height: 7)
            beaconPulseLayer.frame = CGRect(x: (w / 2) - 7.5, y: h - 10, width: 15, height: 15)

            headerLabel.isHidden = true
            detailLabel.isHidden = true
            equalizer.isHidden = true
        } else {
            // Expanded Drop-Down Island (Visible below notch Y = 32 to Y = h)
            let dropDownH = h - notchH
            let activeMidY = notchH + (dropDownH / 2)

            // Left Beacon
            let beaconX: CGFloat = 16
            beaconLayer.frame = CGRect(x: beaconX, y: activeMidY - 4, width: 8, height: 8)
            beaconPulseLayer.frame = CGRect(x: beaconX - 4, y: activeMidY - 8, width: 16, height: 16)

            // Right Equalizer
            let eqW: CGFloat = 26
            let eqH: CGFloat = 22
            equalizer.isHidden = false
            equalizer.frame = CGRect(x: w - eqW - 16, y: activeMidY - (eqH / 2), width: eqW, height: eqH)
            equalizer.updateLayout()

            // Center Labels
            let labelX: CGFloat = 34
            let labelW = w - labelX - eqW - 20

            headerLabel.isHidden = false
            headerLabel.frame = NSRect(x: labelX, y: notchH + 4, width: labelW, height: 14)

            detailLabel.isHidden = false
            detailLabel.font = NSFont.systemFont(ofSize: 11.5, weight: .semibold)
            detailLabel.frame = NSRect(x: labelX, y: notchH + 19, width: labelW, height: 16)
        }
    }

    private func startPulseAnimation() {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 0.85
        pulse.toValue = 1.4
        pulse.duration = 0.85
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        beaconPulseLayer.add(pulse, forKey: "pulse")
    }

    func updateStatus(state: String, detail: String) {
        if currentState == state && currentDetail == detail { return }
        currentState = state
        currentDetail = detail
        applyTheme(state: state)
    }

    private func applyTheme(state: String) {
        let color: NSColor
        let stateTitle: String
        let isAnimated: Bool

        switch state {
        case "thinking":
            color = NSColor(red: 0.75, green: 0.35, blue: 1.0, alpha: 1.0) // Neon Purple
            stateTitle = "THINKING..."
            isAnimated = true
        case "working":
            color = NSColor(red: 0.0, green: 0.94, blue: 1.0, alpha: 1.0) // Electric Cyan
            stateTitle = "WORKING"
            isAnimated = true
        case "done":
            color = NSColor(red: 0.2, green: 0.95, blue: 0.45, alpha: 1.0) // Bright Emerald
            stateTitle = "DONE"
            isAnimated = false
        default:
            color = NSColor(red: 0.0, green: 0.88, blue: 0.45, alpha: 1.0) // Emerald Ready
            stateTitle = "READY"
            isAnimated = false
        }

        themeColor = color

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.2)

            self.beaconLayer.backgroundColor = color.cgColor
            self.beaconLayer.shadowColor = color.cgColor
            self.beaconPulseLayer.backgroundColor = color.withAlphaComponent(0.25).cgColor

            self.headerLabel.stringValue = "ANTIGRAVITY • \(stateTitle)"
            self.headerLabel.textColor = color
            self.detailLabel.stringValue = self.currentDetail.isEmpty ? "Ready for prompt" : self.currentDetail

            self.equalizer.setAnimating(isAnimated, color: color.cgColor)

            self.needsDisplay = true
            CATransaction.commit()
        }
    }
}

// MARK: - Main Notch Application Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var panel: AntigravityNotchPanel!
    var contentView: NotchIslandContentView!
    var pollTimer: Timer?
    var mouseTimer: Timer?

    private let brainPath = ("~/.gemini/antigravity-ide/brain" as NSString).expandingTildeInPath
    private let directStatusPath = "/tmp/antigravity-status.json"
    private var currentTrackedFile: String? = nil
    private var currentFileHandle: FileHandle? = nil
    private var currentFileOffset: UInt64 = 0
    private var idleTimer: Timer? = nil

    private var screenTop: CGFloat = 956.0
    private var screenMidX: CGFloat = 735.0
    private var notchH: CGFloat = 32.0

    private var currentW: CGFloat = 185.0
    private var currentH: CGFloat = 34.0

    private var isHovered: Bool = false
    private var isClickExpanded: Bool = false // Active Mode Click Toggle
    private var currentState: String = "idle"
    private var currentEvent: String = "Standby"

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        // Ensure auto-start at login is registered
        ensureLaunchAgentInstalled()

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

        panel.contentView = contentView
        panel.orderFrontRegardless()

        // 1. Fast Global Mouse Hover Tracking
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

        // 2. Global Mouse Click Monitor (to detect clicks on the Notch Area)
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown]) { [weak self] _ in
            self?.checkMouseClick()
        }

        // 3. Fast Brain State Polling (every 100ms)
        pollTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.pollGlobalBrain()
        }
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
        if currentState != "idle" {
            // When AI is ACTIVE (thinking/working/editing): Click toggles open/close
            isClickExpanded.toggle()
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

        if currentState == "idle" {
            // In IDLE Mode: Automatically closed by default. Hover opens, un-hover closes!
            if isHovered {
                targetW = 380.0
                targetDropH = 42.0
                shouldExpand = true
            } else {
                targetW = 185.0
                targetDropH = 2.0
                shouldExpand = false
            }
        } else {
            // In ACTIVE Mode (thinking/working/editing): Controlled by Click Toggle!
            if isClickExpanded {
                targetW = 380.0
                targetDropH = 42.0
                shouldExpand = true
            } else {
                // Collapsed active mode: shows only the pulsing neon notch rim
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

    private func handleStateTransition(state: String, event: String) {
        if currentState != state && state == "idle" {
            isClickExpanded = false
        }

        currentState = state
        currentEvent = event
        let detail = formatDetail(event)
        contentView.updateStatus(state: state, detail: detail)
        updateNotchDimensions()
    }

    private func pollGlobalBrain() {
        // Priority 1: Direct status file
        if let data = try? Data(contentsOf: URL(fileURLWithPath: directStatusPath)),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let state = json["state"] as? String {
            let event = json["event"] as? String ?? "Standby"
            handleStateTransition(state: state, event: event)
            return
        }

        // Priority 2: Direct transcript file tailing
        scanLatestTranscriptDirectly()
    }

    private func scanLatestTranscriptDirectly() {
        let fileManager = FileManager.default
        guard let entries = try? fileManager.contentsOfDirectory(atPath: brainPath) else { return }

        var latestFile: String? = nil
        var latestDate: Date = Date.distantPast

        for entry in entries where !entry.hasPrefix(".") && entry != "tempmediaStorage" {
            let logPath = (brainPath as NSString).appendingPathComponent("\(entry)/.system_generated/logs/transcript.jsonl")
            if let attrs = try? fileManager.attributesOfItem(atPath: logPath),
               let modDate = attrs[.modificationDate] as? Date,
               modDate > latestDate {
                latestDate = modDate
                latestFile = logPath
            }
        }

        guard let logFile = latestFile else { return }

        if logFile != currentTrackedFile {
            try? currentFileHandle?.close()
            currentTrackedFile = logFile
            if let handle = try? FileHandle(forReadingFrom: URL(fileURLWithPath: logFile)),
               let attrs = try? fileManager.attributesOfItem(atPath: logFile),
               let size = attrs[.size] as? UInt64 {
                currentFileHandle = handle
                currentFileOffset = size
            }
            return
        }

        guard let handle = currentFileHandle,
              let attrs = try? fileManager.attributesOfItem(atPath: logFile),
              let currentSize = attrs[.size] as? UInt64,
              currentSize > currentFileOffset else { return }

        handle.seek(toFileOffset: currentFileOffset)
        let data = handle.readDataToEndOfFile()
        currentFileOffset = currentSize

        if let content = String(data: data, encoding: .utf8) {
            let lines = content.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            for line in lines {
                if let lineData = line.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: lineData) as? [String: Any],
                   let type = json["type"] as? String {

                    if type == "USER_INPUT" {
                        idleTimer?.invalidate()
                        handleStateTransition(state: "thinking", event: "UserInput")
                    } else if type == "PLANNER_RESPONSE" {
                        if let toolCalls = json["tool_calls"] as? [[String: Any]], let first = toolCalls.first, let name = first["name"] as? String {
                            idleTimer?.invalidate()
                            handleStateTransition(state: "working", event: name)
                        } else {
                            handleStateTransition(state: "done", event: "ResponseGenerated")
                            idleTimer?.invalidate()
                            idleTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { [weak self] _ in
                                self?.handleStateTransition(state: "idle", event: "Standby")
                            }
                        }
                    } else if type == "RUN_COMMAND" || type.contains("FILE") || type.contains("DIR") {
                        idleTimer?.invalidate()
                        handleStateTransition(state: "working", event: type)
                    }
                }
            }
        }
    }

    private func formatDetail(_ raw: String) -> String {
        switch raw {
        case "UserInput": return "Thinking & planning..."
        case "RUN_COMMAND", "run_command": return "Running command"
        case "VIEW_FILE", "view_file": return "Reading file"
        case "REPLACE_FILE_CONTENT", "replace_file_content", "WRITE_TO_FILE", "write_to_file": return "Editing code..."
        case "LIST_DIR", "list_dir": return "Scanning directory"
        case "tool_calls", "ToolCall": return "Executing action"
        case "ResponseGenerated": return "Response completed"
        case "WatcherStarted", "Standby": return "Antigravity Ready"
        default: return raw
        }
    }
}

// Single-instance entry point
guard ensureSingleInstance() else {
    exit(0)
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
