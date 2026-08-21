import Cocoa

// MARK: - Notch Geometry Shape Style
public enum ThemeShapeType: String {
    case rounded                // Classic smooth Apple-style curves (macOS 13 Ventura)
    case cyberpunkCut           // Sci-fi 45-degree angular mecha chamfers with RGB glitch
    case matrixBracket          // Terminal box with digital bracket crosshairs [ ]
    case sunsetPill             // Retro synthwave smooth pill with sunset glow
    case draculaGothic          // Gothic stepped bevel with royal violet & blood-red glow
    case finelineConstellation  // Minimalist single-needle tattoo 1.0pt hairline with celestial star dots
}

// MARK: - Unique Theme Beacon Animation Style
public enum ThemeBeaconStyle: String {
    case venturaSiriPulse       // macOS 13 Ventura organic Siri breathing orb
    case cyberpunkGlitchStrobe  // High-frequency twitching diamond glitch strobe
    case matrixTerminalBlock    // Square terminal cursor binary blink
    case synthwaveHorizonHalo   // 80s Neon expanding horizon rings
    case draculaGothicHeartbeat // Floating eerie vampire double-pulse heartbeat
    case finelineCelestialOrbit // Delicate single-needle micro star with expanding concentric orbital ripples
}

// MARK: - Unique Theme Audio Equalizer Waveform Style
public enum ThemeEqualizerStyle: String {
    case classicWave       // Smooth Apple Siri rounded sinusoidal waveform
    case cyberpunkBlocks   // Segmented cybernetic blocks with energetic rapid stepped dance
    case matrixBinary      // Sharp square phosphor-green CRT binary scanline ladder
    case synthwavePillars  // 80s neon gradient horizon rhythmic pumping pillars
    case draculaSpikes     // Sharp jagged gothic vampire spectral pulse spikes
    case finelineNeedle    // Ultra-thin 1.0pt hairline single-needle vertical strokes with micro-dots on top
}

// MARK: - Unique Theme Kebab Menu Button (⋮) Style
public enum ThemeButtonShape: String {
    case capsuleCircle     // Smooth Apple capsule with clean translucent frosted tint
    case cyberChamfer      // Angular 45-degree chamfered sci-fi square
    case matrixBracket     // Digital square bracket terminal frame [ ⋮ ]
    case neonRing          // 80s Neon glowing badge ring
    case gothicDiamond     // Gothic sharp diamond bevel with vampire violet/crimson tint
    case finelineHairline  // Ultra-delicate 0.8pt hairline circle
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
    public var equalizerStyle: ThemeEqualizerStyle
    public var buttonShape: ThemeButtonShape
    public var hasGlitchEffect: Bool
    public var hasMatrixRain: Bool
    public var isLightMode: Bool
    public var headerFontName: String?
    public var detailFontName: String?
    public var headerKerning: CGFloat
    public var detailKerning: CGFloat
    public var completionSoundName: String
    public var hapticPattern: NSHapticFeedbackManager.FeedbackPattern
    public var palette: ThemePalette

    public init(
        id: String,
        displayName: String,
        shapeType: ThemeShapeType,
        beaconStyle: ThemeBeaconStyle = .venturaSiriPulse,
        equalizerStyle: ThemeEqualizerStyle = .classicWave,
        buttonShape: ThemeButtonShape = .capsuleCircle,
        hasGlitchEffect: Bool = false,
        hasMatrixRain: Bool = false,
        isLightMode: Bool = false,
        headerFontName: String? = nil,
        detailFontName: String? = nil,
        headerKerning: CGFloat = 0.0,
        detailKerning: CGFloat = 0.0,
        completionSoundName: String = "Glass",
        hapticPattern: NSHapticFeedbackManager.FeedbackPattern = .generic,
        palette: ThemePalette
    ) {
        self.id = id
        self.displayName = displayName
        self.shapeType = shapeType
        self.beaconStyle = beaconStyle
        self.equalizerStyle = equalizerStyle
        self.buttonShape = buttonShape
        self.hasGlitchEffect = hasGlitchEffect
        self.hasMatrixRain = hasMatrixRain
        self.isLightMode = isLightMode
        self.headerFontName = headerFontName
        self.detailFontName = detailFontName
        self.headerKerning = headerKerning
        self.detailKerning = detailKerning
        self.completionSoundName = completionSoundName
        self.hapticPattern = hapticPattern
        self.palette = palette
    }

    public func makeHeaderFont(size: CGFloat = 9.0) -> NSFont {
        if id == "fineline" {
            return FontManager.shared.resolveFont(
                preferredName: headerFontName ?? "Optima-Bold",
                fallbackNames: ["Optima-ExtraBlack", "Optima-Regular", "Cinzel-Bold", "Didot-Bold"],
                size: size,
                defaultWeight: .bold
            )
        } else if id == "matrix" {
            return FontManager.shared.resolveFont(
                preferredName: headerFontName ?? "Menlo-Bold",
                fallbackNames: ["Menlo", "CourierNewPS-BoldMT", "Monaco"],
                size: size,
                defaultWeight: .bold
            )
        } else if id == "cyberpunk" {
            return FontManager.shared.resolveFont(
                preferredName: headerFontName ?? "HelveticaNeue-CondensedBlack",
                fallbackNames: ["Avenir-Black", "Impact", "Arial-Black"],
                size: size + 0.5,
                defaultWeight: .black
            )
        } else if id == "sunset" {
            return FontManager.shared.resolveFont(
                preferredName: headerFontName ?? "Futura-Bold",
                fallbackNames: ["Futura-Medium", "Avenir-Heavy"],
                size: size + 0.5,
                defaultWeight: .heavy
            )
        } else if id == "dracula" {
            return FontManager.shared.resolveFont(
                preferredName: headerFontName ?? "Didot-Bold",
                fallbackNames: ["Baskerville-Bold", "Georgia-Bold"],
                size: size,
                defaultWeight: .bold
            )
        }
        // macOS Classic (Ventura)
        return FontManager.shared.resolveFont(
            preferredName: headerFontName,
            fallbackNames: [],
            size: size,
            defaultWeight: .bold
        )
    }

    public func makeDetailFont(size: CGFloat = 11.5) -> NSFont {
        if id == "fineline" {
            return FontManager.shared.resolveFont(
                preferredName: detailFontName ?? "Avenir-Light",
                fallbackNames: ["Avenir-Book", "Optima-Regular", "HelveticaNeue-Light"],
                size: size,
                defaultWeight: .light
            )
        } else if id == "matrix" {
            return FontManager.shared.resolveFont(
                preferredName: detailFontName ?? "Menlo-Bold",
                fallbackNames: ["Menlo", "CourierNewPS-BoldMT"],
                size: size - 0.5,
                defaultWeight: .bold
            )
        } else if id == "cyberpunk" {
            return FontManager.shared.resolveFont(
                preferredName: detailFontName ?? "Avenir-Black",
                fallbackNames: ["HelveticaNeue-Bold", "Arial-BoldMT"],
                size: size,
                defaultWeight: .heavy
            )
        } else if id == "sunset" {
            return FontManager.shared.resolveFont(
                preferredName: detailFontName ?? "Futura-Medium",
                fallbackNames: ["Futura", "Avenir-Medium"],
                size: size,
                defaultWeight: .semibold
            )
        } else if id == "dracula" {
            return FontManager.shared.resolveFont(
                preferredName: detailFontName ?? "Palatino-Bold",
                fallbackNames: ["Georgia-Bold", "Baskerville-SemiBold"],
                size: size,
                defaultWeight: .semibold
            )
        }
        // macOS Classic (Ventura)
        return FontManager.shared.resolveFont(
            preferredName: detailFontName,
            fallbackNames: [],
            size: size,
            defaultWeight: .semibold
        )
    }

    /// Creates an attributed string with theme-specific font, kerning (letter-spacing), and color
    public func makeAttributedHeader(text: String, color: NSColor, size: CGFloat = 9.0) -> NSAttributedString {
        let font = makeHeaderFont(size: size)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byTruncatingTail
        var attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ]
        if headerKerning != 0.0 {
            attrs[.kern] = headerKerning
        }
        return NSAttributedString(string: text, attributes: attrs)
    }

    /// Creates an attributed string for detail text with theme-specific typography and kerning
    public func makeAttributedDetail(text: String, color: NSColor, size: CGFloat = 11.5) -> NSAttributedString {
        let font = makeDetailFont(size: size)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byTruncatingTail
        var attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ]
        if detailKerning != 0.0 {
            attrs[.kern] = detailKerning
        }
        return NSAttributedString(string: text, attributes: attrs)
    }
}
