import Cocoa

// MARK: - Active Task Display Behavior
public enum ActiveTaskDisplayMode: String, Codable {
    case hoverExpands    // Notch expands when mouse hovers over it during tasks
    case clickOnly       // Notch stays compact, expands only when user clicks
    case alwaysExpanded  // Notch automatically stays expanded throughout active tasks
}

// MARK: - Live Preview Demo State
public enum NotchPreviewDemoState {
    case none
    case demoExpanded
    case demoCompact
}

// MARK: - Centralized Persistent Settings Manager (Powered by SQLite3)
public class SettingsManager {
    public static let shared = SettingsManager()

    public var activeTaskDisplayMode: ActiveTaskDisplayMode = .alwaysExpanded
    public var idleHoverExpands: Bool = true
    public var soundEnabled: Bool = true
    public var hapticsEnabled: Bool = true
    public var glitchEnabled: Bool = true
    public var launchAtLogin: Bool = true

    // Custom Notch Dimensions (Expanded / Open / Hover / Active)
    public var expandedWidth: CGFloat = 380.0
    public var expandedHeight: CGFloat = 46.0

    // Custom Notch Dimensions (Compact / Closed / Idle)
    public var compactWidth: CGFloat = 185.0
    public var compactHeight: CGFloat = 2.0

    public var onSettingsChanged: (() -> Void)?
    public var onPreviewDemoRequested: ((NotchPreviewDemoState) -> Void)?

    private let db = SQLiteStorageManager.shared

    private init() {
        loadSettings()
    }

    public func loadSettings() {
        let modeStr = db.getString("active_task_display_mode", default: "alwaysExpanded")
        if let mode = ActiveTaskDisplayMode(rawValue: modeStr) {
            self.activeTaskDisplayMode = mode
        }

        self.idleHoverExpands = db.getBool("idle_hover_expands", default: true)
        self.soundEnabled = db.getBool("sound_enabled", default: true)
        self.hapticsEnabled = db.getBool("haptics_enabled", default: true)
        self.glitchEnabled = db.getBool("glitch_enabled", default: true)
        self.launchAtLogin = db.getBool("launch_at_login", default: true)

        // Load custom dimensions with bounds validation
        let expW = CGFloat(db.getDouble("expanded_width", default: 380.0))
        self.expandedWidth = min(max(expW, 280.0), 560.0)

        let expH = CGFloat(db.getDouble("expanded_height", default: 46.0))
        self.expandedHeight = min(max(expH, 32.0), 80.0)

        let compW = CGFloat(db.getDouble("compact_width", default: 185.0))
        self.compactWidth = min(max(compW, 140.0), 260.0)

        let compH = CGFloat(db.getDouble("compact_height", default: 2.0))
        self.compactHeight = min(max(compH, 0.0), 20.0)
    }

    public func saveSettings() {
        db.setString("active_task_display_mode", value: self.activeTaskDisplayMode.rawValue)
        db.setBool("idle_hover_expands", value: self.idleHoverExpands)
        db.setBool("sound_enabled", value: self.soundEnabled)
        db.setBool("haptics_enabled", value: self.hapticsEnabled)
        db.setBool("glitch_enabled", value: self.glitchEnabled)
        db.setBool("launch_at_login", value: self.launchAtLogin)

        db.setDouble("expanded_width", value: Double(self.expandedWidth))
        db.setDouble("expanded_height", value: Double(self.expandedHeight))
        db.setDouble("compact_width", value: Double(self.compactWidth))
        db.setDouble("compact_height", value: Double(self.compactHeight))

        // Sync with LaunchAgent if setting changed
        if launchAtLogin {
            LaunchAgentManager.ensureInstalled()
        } else {
            LaunchAgentManager.uninstall()
        }

        onSettingsChanged?()
    }

    public func requestPreviewDemo(_ state: NotchPreviewDemoState) {
        onPreviewDemoRequested?(state)
    }

    public func resetDimensionsToDefaults() {
        self.expandedWidth = 380.0
        self.expandedHeight = 46.0
        self.compactWidth = 185.0
        self.compactHeight = 2.0
        saveSettings()
    }

    public func resetAllToDefaults() {
        self.activeTaskDisplayMode = .alwaysExpanded
        self.idleHoverExpands = true
        self.soundEnabled = true
        self.hapticsEnabled = true
        self.glitchEnabled = true
        self.launchAtLogin = true
        resetDimensionsToDefaults()
        ThemeManager.shared.setTheme(withId: "general")
    }
}
