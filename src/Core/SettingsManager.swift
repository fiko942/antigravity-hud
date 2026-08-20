import Cocoa

// MARK: - Active Task Display Behavior
public enum ActiveTaskDisplayMode: String, Codable {
    case hoverExpands    // Notch expands when mouse hovers over it during tasks
    case clickOnly       // Notch stays compact, expands only when user clicks
    case alwaysExpanded  // Notch automatically stays expanded throughout active tasks
}

// MARK: - Centralized Persistent Settings Manager
public class SettingsManager {
    public static let shared = SettingsManager()

    public var activeTaskDisplayMode: ActiveTaskDisplayMode = .clickOnly
    public var idleHoverExpands: Bool = true
    public var soundEnabled: Bool = true
    public var hapticsEnabled: Bool = true
    public var glitchEnabled: Bool = true
    public var launchAtLogin: Bool = true

    public var onSettingsChanged: (() -> Void)?

    private let configPath: String

    private init() {
        let configDir = ("~/.config/antigravity-hud" as NSString).expandingTildeInPath
        self.configPath = (configDir as NSString).appendingPathComponent("settings.json")
        loadSettings()
    }

    public func loadSettings() {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: configPath)),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }

        if let modeStr = json["activeTaskDisplayMode"] as? String,
           let mode = ActiveTaskDisplayMode(rawValue: modeStr) {
            self.activeTaskDisplayMode = mode
        }
        if let idleHover = json["idleHoverExpands"] as? Bool { self.idleHoverExpands = idleHover }
        if let sound = json["soundEnabled"] as? Bool { self.soundEnabled = sound }
        if let haptics = json["hapticsEnabled"] as? Bool { self.hapticsEnabled = haptics }
        if let glitch = json["glitchEnabled"] as? Bool { self.glitchEnabled = glitch }
        if let launch = json["launchAtLogin"] as? Bool { self.launchAtLogin = launch }
    }

    public func saveSettings() {
        let configDir = ("~/.config/antigravity-hud" as NSString).expandingTildeInPath
        try? FileManager.default.createDirectory(atPath: configDir, withIntermediateDirectories: true)

        let dict: [String: Any] = [
            "activeTaskDisplayMode": self.activeTaskDisplayMode.rawValue,
            "idleHoverExpands": self.idleHoverExpands,
            "soundEnabled": self.soundEnabled,
            "hapticsEnabled": self.hapticsEnabled,
            "glitchEnabled": self.glitchEnabled,
            "launchAtLogin": self.launchAtLogin
        ]

        if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted]) {
            try? data.write(to: URL(fileURLWithPath: configPath))
        }

        // Sync with LaunchAgent if setting changed
        if launchAtLogin {
            LaunchAgentManager.ensureInstalled()
        }

        onSettingsChanged?()
    }
}
