import Cocoa

// MARK: - Notch Geometry Shape Style
public enum ThemeShapeType: String {
    case rounded        // Classic smooth Apple-style curves (macOS 13 Ventura)
    case cyberpunkCut   // Sci-fi 45-degree angular mecha chamfers with RGB glitch
    case matrixBracket  // Terminal box with digital bracket crosshairs [ ]
    case sunsetPill     // Retro synthwave smooth pill with sunset glow
    case draculaGothic  // Gothic stepped bevel with royal violet & blood-red glow
}

// MARK: - Unique Theme Beacon Animation Style
public enum ThemeBeaconStyle: String {
    case venturaSiriPulse       // macOS 13 Ventura organic Siri breathing orb
    case cyberpunkGlitchStrobe  // High-frequency twitching diamond glitch strobe
    case matrixTerminalBlock    // Square terminal cursor binary blink
    case synthwaveHorizonHalo   // 80s Neon expanding horizon rings
    case draculaGothicHeartbeat // Floating eerie vampire double-pulse heartbeat
}

public struct ThemePalette {
    public var idle: NSColor
    public var thinking: NSColor
    public var working: NSColor
    public var done: NSColor

    public init(idle: NSColor, thinking: NSColor, working: NSColor, done: NSColor) {
        self.idle = idle
        self.thinking = thinking
        self.working = working
        self.done = done
    }
}

public struct ThemeDefinition {
    public var id: String
    public var displayName: String
    public var shapeType: ThemeShapeType
    public var beaconStyle: ThemeBeaconStyle
    public var hasGlitchEffect: Bool
    public var hasMatrixRain: Bool
    public var isLightMode: Bool
    public var headerFontName: String?
    public var detailFontName: String?
    public var palette: ThemePalette

    public init(
        id: String,
        displayName: String,
        shapeType: ThemeShapeType,
        beaconStyle: ThemeBeaconStyle = .venturaSiriPulse,
        hasGlitchEffect: Bool = false,
        hasMatrixRain: Bool = false,
        isLightMode: Bool = false,
        headerFontName: String? = nil,
        detailFontName: String? = nil,
        palette: ThemePalette
    ) {
        self.id = id
        self.displayName = displayName
        self.shapeType = shapeType
        self.beaconStyle = beaconStyle
        self.hasGlitchEffect = hasGlitchEffect
        self.hasMatrixRain = hasMatrixRain
        self.isLightMode = isLightMode
        self.headerFontName = headerFontName
        self.detailFontName = detailFontName
        self.palette = palette
    }

    public func makeHeaderFont(size: CGFloat = 9.0) -> NSFont {
        if let name = headerFontName, let customFont = NSFont(name: name, size: size) {
            return customFont
        }
        if id == "matrix" {
            return NSFont(name: "Menlo-Bold", size: size) ?? NSFont.monospacedSystemFont(ofSize: size, weight: .bold)
        } else if id == "cyberpunk" {
            return NSFont(name: "HelveticaNeue-CondensedBlack", size: size + 1.0) ?? NSFont(name: "Avenir-Black", size: size) ?? NSFont.systemFont(ofSize: size, weight: .black)
        } else if id == "sunset" {
            return NSFont(name: "Futura-Bold", size: size + 0.5) ?? NSFont.systemFont(ofSize: size, weight: .heavy)
        } else if id == "dracula" {
            return NSFont(name: "Didot-Bold", size: size + 1.0) ?? NSFont(name: "Baskerville-Bold", size: size + 0.5) ?? NSFont.systemFont(ofSize: size, weight: .bold)
        }
        // macOS Classic (Ventura)
        return NSFont.systemFont(ofSize: size, weight: .bold)
    }

    public func makeDetailFont(size: CGFloat = 11.5) -> NSFont {
        if let name = detailFontName, let customFont = NSFont(name: name, size: size) {
            return customFont
        }
        if id == "matrix" {
            return NSFont(name: "Menlo-Bold", size: size - 0.5) ?? NSFont.monospacedSystemFont(ofSize: size, weight: .bold)
        } else if id == "cyberpunk" {
            return NSFont(name: "Avenir-Black", size: size) ?? NSFont.systemFont(ofSize: size, weight: .heavy)
        } else if id == "sunset" {
            return NSFont(name: "Futura-Medium", size: size) ?? NSFont.systemFont(ofSize: size, weight: .semibold)
        } else if id == "dracula" {
            return NSFont(name: "Palatino-Bold", size: size) ?? NSFont(name: "Georgia-Bold", size: size) ?? NSFont.systemFont(ofSize: size, weight: .semibold)
        }
        // macOS Classic (Ventura)
        return NSFont.systemFont(ofSize: size, weight: .semibold)
    }
}
