import Cocoa

// MARK: - Dynamic Theme Engine & Persistence
public class ThemeManager {
    public static let shared = ThemeManager()

    public let availableThemes: [ThemeDefinition] = [
        ThemeDefinition(
            id: "general",
            displayName: "macOS Classic (Dark)",
            shapeType: .rounded,
            beaconStyle: .venturaSiriPulse,
            hasGlitchEffect: false,
            hasMatrixRain: false,
            isLightMode: false,
            headerFontName: nil,
            detailFontName: nil,
            palette: ThemePalette(
                idle: NSColor(red: 0.19, green: 0.82, blue: 0.35, alpha: 1.0),      // #30D158 Ventura Emerald
                thinking: NSColor(red: 0.69, green: 0.32, blue: 0.87, alpha: 1.0),  // #AF52DE Ventura Siri Purple
                working: NSColor(red: 0.04, green: 0.52, blue: 1.0, alpha: 1.0),    // #0A84FF Ventura Electric Blue
                done: NSColor(red: 0.20, green: 0.84, blue: 0.29, alpha: 1.0)       // #32D74B Ventura Bright Green
            )
        ),
        ThemeDefinition(
            id: "macos-light",
            displayName: "macOS Classic (Light)",
            shapeType: .rounded,
            beaconStyle: .venturaSiriPulse,
            hasGlitchEffect: false,
            hasMatrixRain: false,
            isLightMode: true,
            headerFontName: nil,
            detailFontName: nil,
            palette: ThemePalette(
                idle: NSColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1.0),      // #34C759 Apple Green
                thinking: NSColor(red: 0.60, green: 0.20, blue: 0.90, alpha: 1.0),  // #9933E6 Royal Purple
                working: NSColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0),     // #007AFF Apple System Blue
                done: NSColor(red: 0.16, green: 0.80, blue: 0.25, alpha: 1.0)       // #28CD41 Crisp Green
            )
        ),
        ThemeDefinition(
            id: "cyberpunk",
            displayName: "Cyberpunk 2077 (Glitch)",
            shapeType: .cyberpunkCut,
            beaconStyle: .cyberpunkGlitchStrobe,
            hasGlitchEffect: true,
            hasMatrixRain: false,
            isLightMode: false,
            headerFontName: "HelveticaNeue-CondensedBlack",
            detailFontName: "Avenir-Black",
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
            beaconStyle: .matrixTerminalBlock,
            hasGlitchEffect: false,
            hasMatrixRain: true,
            isLightMode: false,
            headerFontName: "Menlo-Bold",
            detailFontName: "Menlo-Bold",
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
            beaconStyle: .synthwaveHorizonHalo,
            hasGlitchEffect: false,
            hasMatrixRain: false,
            isLightMode: false,
            headerFontName: "Futura-Bold",
            detailFontName: "Futura-Medium",
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
            beaconStyle: .draculaGothicHeartbeat,
            hasGlitchEffect: false,
            hasMatrixRain: false,
            isLightMode: false,
            headerFontName: "Didot-Bold",
            detailFontName: "Palatino-Bold",
            palette: ThemePalette(
                idle: NSColor(red: 0.74, green: 0.58, blue: 0.98, alpha: 1.0),     // #BD93F9 Dracula Purple
                thinking: NSColor(red: 1.0, green: 0.16, blue: 0.33, alpha: 1.0),  // #FF2954 Blood Red
                working: NSColor(red: 0.55, green: 0.91, blue: 0.99, alpha: 1.0),   // #8BE9FD Ghost Cyan
                done: NSColor(red: 0.31, green: 0.98, blue: 0.48, alpha: 1.0)      // #50FA7B Vampire Mint
            )
        ),
        ThemeDefinition(
            id: "fineline",
            displayName: "Fineline Dark (Celestial Ink)",
            shapeType: .finelineConstellation,
            beaconStyle: .finelineCelestialOrbit,
            hasGlitchEffect: false,
            hasMatrixRain: false,
            isLightMode: false,
            headerFontName: "Optima-Bold",
            detailFontName: "Avenir-Light",
            palette: ThemePalette(
                idle: NSColor(red: 0.94, green: 0.93, blue: 0.91, alpha: 1.0),      // #F0EFEA Pearl White / Ivory Ink
                thinking: NSColor(red: 0.65, green: 0.55, blue: 0.98, alpha: 1.0),  // #A78BFA Mystic Nebula Lavender
                working: NSColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 1.0),   // #38BDF8 Celestial North Star Cyan
                done: NSColor(red: 0.98, green: 0.75, blue: 0.14, alpha: 1.0)       // #FBBF24 Aurora Star Gold
            )
        )
    ]

    public var currentTheme: ThemeDefinition
    public var onThemeChanged: (() -> Void)?

    private init() {
        if let sunset = availableThemes.first(where: { $0.id == "sunset" }) {
            self.currentTheme = sunset
        } else {
            self.currentTheme = availableThemes[0]
        }
        loadUserTheme()
    }

    public var activeThemeId: String {
        return currentTheme.id
    }

    public var currentPalette: ThemePalette {
        return currentTheme.palette
    }

    public func loadUserTheme() {
        let active = SQLiteStorageManager.shared.getString("active_theme", default: "sunset")
        if let matched = availableThemes.first(where: { $0.id == active.lowercased() }) {
            self.currentTheme = matched
        }
    }

    public func saveUserTheme() {
        SQLiteStorageManager.shared.setString("active_theme", value: self.currentTheme.id)

        // Legacy mirror file
        let configDir = ("~/.config/antigravity-hud" as NSString).expandingTildeInPath
        let configPath = (configDir as NSString).appendingPathComponent("theme.json")

        let configDict: [String: Any] = [
            "activeTheme": self.currentTheme.id,
            "soundEnabled": SettingsManager.shared.soundEnabled,
            "hapticsEnabled": SettingsManager.shared.hapticsEnabled
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

    public func color(for state: String) -> NSColor {
        switch state {
        case "thinking": return currentPalette.thinking
        case "working": return currentPalette.working
        case "done": return currentPalette.done
        default: return currentPalette.idle
        }
    }
}
