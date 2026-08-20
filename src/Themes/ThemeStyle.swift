import Cocoa

// MARK: - Notch Geometry Shape Style
public enum ThemeShapeType: String {
    case rounded        // General / Classic smooth Apple-style curves
    case cyberpunkCut   // Sci-fi 45-degree angular mecha chamfers with RGB glitch
    case matrixBracket  // Terminal box with digital bracket crosshairs [ ]
    case sunsetPill     // Retro synthwave smooth pill with sunset glow
    case draculaGothic  // Gothic stepped bevel with royal violet & blood-red glow
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
    public var hasGlitchEffect: Bool
    public var palette: ThemePalette

    public init(id: String, displayName: String, shapeType: ThemeShapeType, hasGlitchEffect: Bool, palette: ThemePalette) {
        self.id = id
        self.displayName = displayName
        self.shapeType = shapeType
        self.hasGlitchEffect = hasGlitchEffect
        self.palette = palette
    }
}
