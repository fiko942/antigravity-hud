import Cocoa

// MARK: - Dynamic Theme Engine & Persistence
public class ThemeManager {
    public static let shared = ThemeManager()

    public let availableThemes: [ThemeDefinition] = [
        ThemeDefinition(
            id: "general",
            displayName: "General (Classic)",
            shapeType: .rounded,
            hasGlitchEffect: false,
            palette: ThemePalette(
                idle: NSColor(red: 0.0, green: 0.88, blue: 0.45, alpha: 1.0),      // #00E073 Emerald
                thinking: NSColor(red: 0.75, green: 0.35, blue: 1.0, alpha: 1.0),   // #BF5AF2 Neon Purple
                working: NSColor(red: 0.0, green: 0.94, blue: 1.0, alpha: 1.0),    // #00F0FF Electric Cyan
                done: NSColor(red: 0.2, green: 0.95, blue: 0.45, alpha: 1.0)       // #34D399 Bright Emerald
            )
        ),
        ThemeDefinition(
            id: "cyberpunk",
            displayName: "Cyberpunk 2077 (Glitch)",
            shapeType: .cyberpunkCut,
            hasGlitchEffect: true,
            palette: ThemePalette(
                idle: NSColor(red: 1.0, green: 0.0, blue: 0.45, alpha: 1.0),       // #FF0073 Neon Magenta
                thinking: NSColor(red: 0.75, green: 0.15, blue: 1.0, alpha: 1.0),  // #BF26FF Electric Violet
                working: NSColor(red: 0.0, green: 0.96, blue: 1.0, alpha: 1.0),    // #00F5FF Cyber Cyan
                done: NSColor(red: 1.0, green: 0.88, blue: 0.0, alpha: 1.0)       // #FFE000 Cyber Yellow
            )
        ),
        ThemeDefinition(
            id: "matrix",
            displayName: "Matrix Terminal",
            shapeType: .matrixBracket,
            hasGlitchEffect: false,
            palette: ThemePalette(
                idle: NSColor(red: 0.0, green: 1.0, blue: 0.25, alpha: 1.0),       // #00FF41 Matrix Green
                thinking: NSColor(red: 0.0, green: 0.56, blue: 0.07, alpha: 1.0),   // #008F11 Deep Terminal
                working: NSColor(red: 0.0, green: 1.0, blue: 0.4, alpha: 1.0),     // #00FF66 Neon Phosphor
                done: NSColor(red: 0.22, green: 1.0, blue: 0.08, alpha: 1.0)       // #39FF14 Bright Lime
            )
        ),
        ThemeDefinition(
            id: "sunset",
            displayName: "Sunset Synthwave (Horizon)",
            shapeType: .sunsetPill,
            hasGlitchEffect: false,
            palette: ThemePalette(
                idle: NSColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 1.0),       // #FF6B00 Sunset Orange
                thinking: NSColor(red: 1.0, green: 0.0, blue: 0.55, alpha: 1.0),   // #FF008C Neon Magenta
                working: NSColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0),    // #FFD700 Neon Gold
                done: NSColor(red: 0.0, green: 0.94, blue: 1.0, alpha: 1.0)        // #00F0FF Electric Cyan
            )
        ),
        ThemeDefinition(
            id: "dracula",
            displayName: "Dracula Gothic (Vampire)",
            shapeType: .draculaGothic,
            hasGlitchEffect: false,
            palette: ThemePalette(
                idle: NSColor(red: 0.74, green: 0.58, blue: 0.98, alpha: 1.0),     // #BD93F9 Dracula Purple
                thinking: NSColor(red: 1.0, green: 0.16, blue: 0.33, alpha: 1.0),  // #FF2954 Blood Red
                working: NSColor(red: 0.55, green: 0.91, blue: 0.99, alpha: 1.0),   // #8BE9FD Ghost Cyan
                done: NSColor(red: 0.31, green: 0.98, blue: 0.48, alpha: 1.0)      // #50FA7B Vampire Mint
            )
        )
    ]

    public var currentTheme: ThemeDefinition
    public var soundEnabled: Bool = true
    public var hapticsEnabled: Bool = true

    public var onThemeChanged: (() -> Void)?

    private init() {
        self.currentTheme = availableThemes[0] // General (Classic) default
        loadUserTheme()
    }

    public var activeThemeId: String {
        return currentTheme.id
    }

    public var currentPalette: ThemePalette {
        return currentTheme.palette
    }

    public func loadUserTheme() {
        let configPath = ("~/.config/antigravity-hud/theme.json" as NSString).expandingTildeInPath
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: configPath)),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }

        if let sound = json["soundEnabled"] as? Bool { self.soundEnabled = sound }
        if let haptics = json["hapticsEnabled"] as? Bool { self.hapticsEnabled = haptics }

        if let active = json["activeTheme"] as? String,
           let matched = availableThemes.first(where: { $0.id == active.lowercased() }) {
            self.currentTheme = matched
        }
    }

    public func saveUserTheme() {
        let configDir = ("~/.config/antigravity-hud" as NSString).expandingTildeInPath
        let configPath = (configDir as NSString).appendingPathComponent("theme.json")

        let configDict: [String: Any] = [
            "activeTheme": self.currentTheme.id,
            "soundEnabled": self.soundEnabled,
            "hapticsEnabled": self.hapticsEnabled
        ]

        try? FileManager.default.createDirectory(atPath: configDir, withIntermediateDirectories: true)
        if let jsonData = try? JSONSerialization.data(withJSONObject: configDict, options: [.prettyPrinted]) {
            try? jsonData.write(to: URL(fileURLWithPath: configPath))
        }
    }

    public func setTheme(withId id: String) {
        guard let matched = availableThemes.first(where: { $0.id == id.lowercased() }) else { return }
        self.currentTheme = matched
        saveUserTheme()
        SensoryManager.shared.triggerHaptic(pattern: .generic)
        onThemeChanged?()
    }

    public func toggleSound() {
        soundEnabled.toggle()
        saveUserTheme()
    }

    public func toggleHaptics() {
        hapticsEnabled.toggle()
        saveUserTheme()
    }

    public func color(for state: String) -> NSColor {
        switch state {
        case "thinking": return currentPalette.thinking
        case "working": return currentPalette.working
        case "done": return currentPalette.done
        default: return currentPalette.idle
        }
    }
}
