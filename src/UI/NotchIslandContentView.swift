import Cocoa
import QuartzCore

// MARK: - Notch Dynamic Island View (Dynamic Shapes, Themes, & Animations)
public class NotchIslandContentView: NSView {
    public override var isFlipped: Bool { true } // (0,0) is TOP-LEFT of window (screen top bezel)

    // Left Beacon & Icon
    private let beaconLayer = CALayer()
    private let beaconPulseLayer = CALayer()

    // Center Labels
    private let headerLabel = NSTextField(labelWithString: "ANTIGRAVITY • READY")
    private let detailLabel = NSTextField(labelWithString: "Standby for prompt")

    // Right Animated Equalizer, Glitch Layer & Vertical 3-Dots Action Button
    private let equalizer = CyberEqualizerLayer()
    private let glitchOverlay = GlitchOverlayLayer()
    private let matrixRain = MatrixRainLayer()
    private let moreButton = NSButton(title: "⋮", target: nil, action: nil)

    public var onViewClicked: (() -> Void)?
    public var onMoreClicked: ((NSButton) -> Void)?
    public var onRightClicked: ((NSEvent) -> Void)?

    private var currentActivity = AgentActivity(
        state: "idle",
        header: "ANTIGRAVITY • READY",
        detail: "Standby for prompt",
        activePath: nil,
        isAnimated: false
    )

    private var themeColor: NSColor = NSColor(red: 0.0, green: 0.88, blue: 0.45, alpha: 1.0)
    private var glitchAccentColor: NSColor? = nil
    public var isExpandedMode: Bool = false

    public let notchH: CGFloat = 32.0 // Physical hardware notch height

    // Matrix Terminal Decryption & Cursor Engine
    private var scrambleTimer: Timer? = nil
    private var cursorTimer: Timer? = nil
    private var cursorVisible: Bool = true
    private var currentDisplayTargetText: String = ""
    private let matrixChars = Array("0123456789ABCDEF!@#$%^&*<>[]/*{}")

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        wantsLayer = true

        // Background Layers: Matrix Rain & Glitch Overlays
        matrixRain.zPosition = 1
        glitchOverlay.zPosition = 2
        layer?.addSublayer(matrixRain)
        layer?.addSublayer(glitchOverlay)

        glitchOverlay.onGlitchColorTick = { [weak self] color in
            guard let self = self, ThemeManager.shared.currentTheme.hasGlitchEffect else { return }
            self.glitchAccentColor = color
            self.needsDisplay = true
        }

        // Status Beacon
        beaconPulseLayer.zPosition = 10
        beaconPulseLayer.cornerRadius = 8
        layer?.addSublayer(beaconPulseLayer)

        beaconLayer.zPosition = 11
        beaconLayer.cornerRadius = 4
        beaconLayer.shadowRadius = 5
        beaconLayer.shadowOpacity = 1.0
        beaconLayer.shadowOffset = .zero
        layer?.addSublayer(beaconLayer)

        // Equalizer
        equalizer.zPosition = 12
        layer?.addSublayer(equalizer)
        headerLabel.font = NSFont.monospacedSystemFont(ofSize: 9.0, weight: .black)
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

        // Vertical 3-Dots Button (Kebab Menu ⋮)
        setupMoreButton()
        addSubview(moreButton)

        // Equalizer
        layer?.addSublayer(equalizer)

        startPulseAnimation()
        applyTheme()

        ThemeManager.shared.onThemeChanged = { [weak self] in
            self?.applyTheme()
        }
    }

    private func setupMoreButton() {
        moreButton.isBordered = false
        moreButton.wantsLayer = true
        moreButton.layer?.backgroundColor = themeColor.withAlphaComponent(0.12).cgColor
        moreButton.layer?.borderColor = themeColor.withAlphaComponent(0.35).cgColor
        moreButton.layer?.borderWidth = 1.0
        moreButton.layer?.cornerRadius = 11.0
        moreButton.target = self
        moreButton.action = #selector(handleMoreClicked)
        moreButton.attributedTitle = NSAttributedString(
            string: "⋮",
            attributes: [
                .font: NSFont.systemFont(ofSize: 14, weight: .bold),
                .foregroundColor: themeColor
            ]
        )
    }

    @objc private func handleMoreClicked() {
        SensoryManager.shared.triggerHaptic(pattern: .generic)
        onMoreClicked?(moreButton)
    }

    public override func mouseDown(with event: NSEvent) {
        onViewClicked?()
    }

    public override func rightMouseDown(with event: NSEvent) {
        onRightClicked?(event)
    }

    // 100% Solid Opaque Pure Black Drawing with Clean Geometry Shapes
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let w = bounds.width
        let h = bounds.height
        let currentTheme = ThemeManager.shared.currentTheme
        let activeStrokeColor = (currentTheme.hasGlitchEffect && glitchAccentColor != nil && (currentActivity.state == "working" || currentActivity.state == "thinking")) ?
            glitchAccentColor! : themeColor

        let path = NSBezierPath()
        let glowPath = NSBezierPath()

        switch currentTheme.shapeType {
        case .cyberpunkCut:
            // Cyberpunk 2077: Clean 45-degree angular mecha chamfer cuts
            let chamfer: CGFloat = isExpandedMode ? 14.0 : 5.0

            path.move(to: NSPoint(x: 0, y: 0))
            path.line(to: NSPoint(x: w, y: 0))
            path.line(to: NSPoint(x: w, y: h - chamfer))
            path.line(to: NSPoint(x: w - chamfer, y: h))
            path.line(to: NSPoint(x: chamfer, y: h))
            path.line(to: NSPoint(x: 0, y: h - chamfer))
            path.close()

            if isExpandedMode {
                glowPath.move(to: NSPoint(x: 0, y: max(0, h - chamfer - 8)))
                glowPath.line(to: NSPoint(x: 0, y: h - chamfer))
                glowPath.line(to: NSPoint(x: chamfer, y: h))
                glowPath.line(to: NSPoint(x: w - chamfer, y: h))
                glowPath.line(to: NSPoint(x: w, y: h - chamfer))
                glowPath.line(to: NSPoint(x: w, y: max(0, h - chamfer - 8)))
            } else {
                glowPath.move(to: NSPoint(x: 10, y: h - 1.5))
                glowPath.line(to: NSPoint(x: w - 10, y: h - 1.5))
            }

        case .matrixBracket:
            // Matrix Terminal: Clean tech terminal box with corner bracket crosshairs `[ ]`
            let cornerRadius: CGFloat = isExpandedMode ? 4.0 : 2.0
            path.move(to: NSPoint(x: 0, y: 0))
            path.line(to: NSPoint(x: w, y: 0))
            path.line(to: NSPoint(x: w, y: h - cornerRadius))
            path.line(to: NSPoint(x: w - cornerRadius, y: h))
            path.line(to: NSPoint(x: cornerRadius, y: h))
            path.line(to: NSPoint(x: 0, y: h - cornerRadius))
            path.close()

            if isExpandedMode {
                // Corner bracket crosshairs `[ ]`
                glowPath.move(to: NSPoint(x: 0, y: h - 14))
                glowPath.line(to: NSPoint(x: 0, y: h))
                glowPath.line(to: NSPoint(x: 18, y: h))

                glowPath.move(to: NSPoint(x: 26, y: h - 1.5))
                glowPath.line(to: NSPoint(x: w - 26, y: h - 1.5))

                glowPath.move(to: NSPoint(x: w - 18, y: h))
                glowPath.line(to: NSPoint(x: w, y: h))
                glowPath.line(to: NSPoint(x: w, y: h - 14))
            } else {
                glowPath.move(to: NSPoint(x: 10, y: h - 1.5))
                glowPath.line(to: NSPoint(x: w - 10, y: h - 1.5))
            }

        case .sunsetPill:
            // Sunset Synthwave: Deep continuous smooth pill (R = 22pt)
            let cornerRadius: CGFloat = isExpandedMode ? 22.0 : 9.0
            path.move(to: NSPoint(x: 0, y: 0))
            path.line(to: NSPoint(x: w, y: 0))
            path.line(to: NSPoint(x: w, y: h - cornerRadius))
            path.appendArc(withCenter: NSPoint(x: w - cornerRadius, y: h - cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: 90, clockwise: false)
            path.line(to: NSPoint(x: cornerRadius, y: h))
            path.appendArc(withCenter: NSPoint(x: cornerRadius, y: h - cornerRadius), radius: cornerRadius, startAngle: 90, endAngle: 180, clockwise: false)
            path.close()

            if isExpandedMode {
                glowPath.move(to: NSPoint(x: 0, y: max(0, h - cornerRadius - 4)))
                glowPath.line(to: NSPoint(x: 0, y: h - cornerRadius))
                glowPath.appendArc(withCenter: NSPoint(x: cornerRadius, y: h - cornerRadius), radius: cornerRadius, startAngle: 180, endAngle: 90, clockwise: true)
                glowPath.line(to: NSPoint(x: w - cornerRadius, y: h))
                glowPath.appendArc(withCenter: NSPoint(x: w - cornerRadius, y: h - cornerRadius), radius: cornerRadius, startAngle: 90, endAngle: 0, clockwise: true)
                glowPath.line(to: NSPoint(x: w, y: max(0, h - cornerRadius - 4)))
            } else {
                glowPath.move(to: NSPoint(x: 10, y: h - 1.5))
                glowPath.line(to: NSPoint(x: w - 10, y: h - 1.5))
            }

        case .draculaGothic:
            // Dracula Gothic: Stepped gothic micro-bevel notches (6pt 45-degree cut) on bottom corners
            let bevel: CGFloat = isExpandedMode ? 8.0 : 3.0

            path.move(to: NSPoint(x: 0, y: 0))
            path.line(to: NSPoint(x: w, y: 0))
            path.line(to: NSPoint(x: w, y: h - bevel))
            path.line(to: NSPoint(x: w - bevel, y: h))
            path.line(to: NSPoint(x: bevel, y: h))
            path.line(to: NSPoint(x: 0, y: h - bevel))
            path.close()

            if isExpandedMode {
                glowPath.move(to: NSPoint(x: 0, y: max(0, h - bevel - 6)))
                glowPath.line(to: NSPoint(x: 0, y: h - bevel))
                glowPath.line(to: NSPoint(x: bevel, y: h))
                glowPath.line(to: NSPoint(x: w - bevel, y: h))
                glowPath.line(to: NSPoint(x: w, y: h - bevel))
                glowPath.line(to: NSPoint(x: w, y: max(0, h - bevel - 6)))
            } else {
                glowPath.move(to: NSPoint(x: 10, y: h - 1.5))
                glowPath.line(to: NSPoint(x: w - 10, y: h - 1.5))
            }

        case .finelineConstellation:
            // Fineline Dark: Ultra-crisp 1.0pt single-needle hairline contour with celestial star dots
            let cornerRadius: CGFloat = isExpandedMode ? 16.0 : 7.0
            path.move(to: NSPoint(x: 0, y: 0))
            path.line(to: NSPoint(x: w, y: 0))
            path.line(to: NSPoint(x: w, y: h - cornerRadius))
            path.appendArc(withCenter: NSPoint(x: w - cornerRadius, y: h - cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: 90, clockwise: false)
            path.line(to: NSPoint(x: cornerRadius, y: h))
            path.appendArc(withCenter: NSPoint(x: cornerRadius, y: h - cornerRadius), radius: cornerRadius, startAngle: 90, endAngle: 180, clockwise: false)
            path.close()

            if isExpandedMode {
                glowPath.move(to: NSPoint(x: 0, y: max(0, h - cornerRadius - 4)))
                glowPath.line(to: NSPoint(x: 0, y: h - cornerRadius))
                glowPath.appendArc(withCenter: NSPoint(x: cornerRadius, y: h - cornerRadius), radius: cornerRadius, startAngle: 180, endAngle: 90, clockwise: true)
                glowPath.line(to: NSPoint(x: w - cornerRadius, y: h))
                glowPath.appendArc(withCenter: NSPoint(x: w - cornerRadius, y: h - cornerRadius), radius: cornerRadius, startAngle: 90, endAngle: 0, clockwise: true)
                glowPath.line(to: NSPoint(x: w, y: max(0, h - cornerRadius - 4)))
            } else {
                glowPath.move(to: NSPoint(x: 8, y: h - 1.0))
                glowPath.line(to: NSPoint(x: w - 8, y: h - 1.0))
            }

        case .rounded:
            // General Classic: Smooth Apple Superellipse
            let cornerRadius: CGFloat = isExpandedMode ? 18.0 : 8.0
            path.move(to: NSPoint(x: 0, y: 0))
            path.line(to: NSPoint(x: w, y: 0))
            path.line(to: NSPoint(x: w, y: h - cornerRadius))
            path.appendArc(withCenter: NSPoint(x: w - cornerRadius, y: h - cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: 90, clockwise: false)
            path.line(to: NSPoint(x: cornerRadius, y: h))
            path.appendArc(withCenter: NSPoint(x: cornerRadius, y: h - cornerRadius), radius: cornerRadius, startAngle: 90, endAngle: 180, clockwise: false)
            path.close()

            if isExpandedMode {
                glowPath.move(to: NSPoint(x: 0, y: max(0, h - cornerRadius - 4)))
                glowPath.line(to: NSPoint(x: 0, y: h - cornerRadius))
                glowPath.appendArc(withCenter: NSPoint(x: cornerRadius, y: h - cornerRadius), radius: cornerRadius, startAngle: 180, endAngle: 90, clockwise: true)
                glowPath.line(to: NSPoint(x: w - cornerRadius, y: h))
                glowPath.appendArc(withCenter: NSPoint(x: w - cornerRadius, y: h - cornerRadius), radius: cornerRadius, startAngle: 90, endAngle: 0, clockwise: true)
                glowPath.line(to: NSPoint(x: w, y: max(0, h - cornerRadius - 4)))
            } else {
                glowPath.move(to: NSPoint(x: 10, y: h - 1.5))
                glowPath.line(to: NSPoint(x: w - 10, y: h - 1.5))
            }
        }

        // Fill background
        if currentTheme.isLightMode {
            // Light Mode: Pure Crisp Platinum Ceramic
            NSColor(red: 0.965, green: 0.97, blue: 0.98, alpha: 1.0).setFill()
            path.fill()

            // Subtle dark hairline border for Light Mode
            glowPath.lineWidth = isExpandedMode ? 1.5 : 1.8
            NSColor(white: 0.0, alpha: 0.18).setStroke()
            glowPath.stroke()
        } else {
            // Dark Mode: 100% solid pure black
            NSColor.black.setFill()
            path.fill()

            // Stroke primary glowing contour
            if currentTheme.shapeType == .finelineConstellation {
                glowPath.lineWidth = isExpandedMode ? 1.0 : 1.2
                activeStrokeColor.withAlphaComponent(0.95).setStroke()
            } else {
                glowPath.lineWidth = isExpandedMode ? 1.8 : 2.0
                activeStrokeColor.withAlphaComponent(isExpandedMode ? 0.9 : 0.85).setStroke()
            }
            glowPath.stroke()

            // Constellation Star Dots for Fineline Dark theme
            if currentTheme.shapeType == .finelineConstellation && isExpandedMode {
                let dotRadius: CGFloat = 1.25
                let dot1 = NSBezierPath(ovalIn: NSRect(x: 16 - dotRadius, y: h - 3.5 - dotRadius, width: dotRadius * 2, height: dotRadius * 2))
                let dot2 = NSBezierPath(ovalIn: NSRect(x: w - 16 - dotRadius, y: h - 3.5 - dotRadius, width: dotRadius * 2, height: dotRadius * 2))
                activeStrokeColor.setFill()
                dot1.fill()
                dot2.fill()
            }
        }
    }

    public override func layout() {
        super.layout()
        needsDisplay = true
        updateElementPositions()
    }

    private func updateElementPositions() {
        let w = bounds.width
        let h = bounds.height

        glitchOverlay.frame = bounds
        matrixRain.updateLayout(width: w, height: h)

        if !isExpandedMode {
            // Idle Compact
            beaconLayer.bounds = CGRect(x: 0, y: 0, width: 7, height: 7)
            beaconLayer.position = CGPoint(x: w / 2, y: h - 2.5)

            beaconPulseLayer.bounds = CGRect(x: 0, y: 0, width: 15, height: 15)
            beaconPulseLayer.position = CGPoint(x: w / 2, y: h - 2.5)

            headerLabel.isHidden = true
            detailLabel.isHidden = true
            equalizer.isHidden = true
            moreButton.isHidden = true
        } else {
            // Expanded Drop-Down Island
            let dropDownH = h - notchH
            let activeMidY = notchH + (dropDownH / 2)

            // Left Beacon (Safe inside padding X = 20)
            let beaconCenterX: CGFloat = 20
            beaconLayer.bounds = CGRect(x: 0, y: 0, width: 8, height: 8)
            beaconLayer.position = CGPoint(x: beaconCenterX, y: activeMidY)

            beaconPulseLayer.bounds = CGRect(x: 0, y: 0, width: 16, height: 16)
            beaconPulseLayer.position = CGPoint(x: beaconCenterX, y: activeMidY)

            // Right Vertical 3-Dots Button (⋮) (Safe inside padding X = w - 40)
            moreButton.isHidden = false
            let btnSize: CGFloat = 22
            moreButton.frame = NSRect(x: w - btnSize - 18, y: activeMidY - (btnSize / 2), width: btnSize, height: btnSize)

            // Right Equalizer (Next to 3-dots button, hides gracefully if width < 190 pt)
            let eqW: CGFloat = 24
            let eqH: CGFloat = 20
            let showEqualizer = currentActivity.isAnimated && (w >= 190)
            equalizer.isHidden = !showEqualizer
            if showEqualizer {
                equalizer.frame = CGRect(x: moreButton.frame.minX - eqW - 8, y: activeMidY - (eqH / 2), width: eqW, height: eqH)
                equalizer.updateLayout()
            }

            // Center Labels (Dynamic Vertical Auto-Centering based on dropDownH)
            let labelX: CGFloat = 36
            let rightBound = showEqualizer ? (equalizer.frame.minX - 6) : (moreButton.frame.minX - 6)
            let labelW = max(30, rightBound - labelX)

            let isCompactDrop = dropDownH < 38
            let headerH: CGFloat = isCompactDrop ? 12.0 : 13.5
            let detailH: CGFloat = isCompactDrop ? 14.0 : 16.0
            let spacing: CGFloat = isCompactDrop ? 1.0 : 2.5
            let totalTextH = headerH + spacing + detailH
            let textStartY = activeMidY - (totalTextH / 2)

            headerLabel.isHidden = false
            headerLabel.frame = NSRect(x: labelX, y: textStartY, width: labelW, height: headerH)

            detailLabel.isHidden = false
            detailLabel.frame = NSRect(x: labelX, y: textStartY + headerH + spacing, width: labelW, height: detailH)
        }
    }

    private func startPulseAnimation() {
        configureBeaconAnimation(for: ThemeManager.shared.currentTheme, color: themeColor)
    }

    private func configureBeaconAnimation(for theme: ThemeDefinition, color: NSColor) {
        beaconLayer.removeAllAnimations()
        beaconPulseLayer.removeAllAnimations()

        beaconLayer.isHidden = false
        beaconPulseLayer.isHidden = false
        beaconLayer.opacity = 1.0

        switch theme.beaconStyle {
        case .venturaSiriPulse:
            // macOS 13 Ventura organic Siri breathing orb
            beaconLayer.cornerRadius = 4.0
            beaconPulseLayer.cornerRadius = 8.0
            beaconLayer.transform = CATransform3DIdentity
            beaconPulseLayer.transform = CATransform3DIdentity

            let pulse = CABasicAnimation(keyPath: "transform.scale")
            pulse.fromValue = 0.88
            pulse.toValue = 1.35
            pulse.duration = 1.4
            pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            pulse.autoreverses = true
            pulse.repeatCount = .infinity
            beaconPulseLayer.add(pulse, forKey: "pulse")

            let alphaAnim = CABasicAnimation(keyPath: "opacity")
            alphaAnim.fromValue = 0.75
            alphaAnim.toValue = 0.25
            alphaAnim.duration = 1.4
            alphaAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            alphaAnim.autoreverses = true
            alphaAnim.repeatCount = .infinity
            beaconPulseLayer.add(alphaAnim, forKey: "alphaPulse")

        case .cyberpunkGlitchStrobe:
            // Cyberpunk 2077 angular diamond strobe with erratic twitching
            beaconLayer.cornerRadius = 1.5
            beaconPulseLayer.cornerRadius = 2.0
            beaconLayer.transform = CATransform3DMakeRotation(.pi / 4, 0, 0, 1)
            beaconPulseLayer.transform = CATransform3DMakeRotation(.pi / 4, 0, 0, 1)

            let strobe = CAKeyframeAnimation(keyPath: "opacity")
            strobe.values = [0.9, 0.25, 1.0, 0.2, 0.9, 0.35, 1.0, 0.2, 0.9]
            strobe.keyTimes = [0.0, 0.15, 0.22, 0.35, 0.48, 0.62, 0.75, 0.88, 1.0]
            strobe.duration = 0.7
            strobe.repeatCount = .infinity
            beaconPulseLayer.add(strobe, forKey: "cyberStrobe")

            let scaleTwitch = CAKeyframeAnimation(keyPath: "transform.scale")
            scaleTwitch.values = [1.0, 1.35, 0.95, 1.25, 1.0]
            scaleTwitch.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
            scaleTwitch.duration = 0.7
            scaleTwitch.repeatCount = .infinity
            beaconPulseLayer.add(scaleTwitch, forKey: "cyberScale")

        case .matrixTerminalBlock:
            // Matrix Terminal square cursor stepped binary blink
            beaconLayer.cornerRadius = 0.5
            beaconPulseLayer.cornerRadius = 0.5
            beaconLayer.transform = CATransform3DIdentity
            beaconPulseLayer.transform = CATransform3DIdentity

            let binaryBlink = CAKeyframeAnimation(keyPath: "opacity")
            binaryBlink.values = [1.0, 1.0, 0.0, 0.0, 1.0]
            binaryBlink.keyTimes = [0.0, 0.49, 0.5, 0.99, 1.0]
            binaryBlink.duration = 0.6
            binaryBlink.repeatCount = .infinity
            beaconPulseLayer.add(binaryBlink, forKey: "matrixBlink")

        case .synthwaveHorizonHalo:
            // Sunset Synthwave expanding neon horizon halo rings
            beaconLayer.cornerRadius = 4.0
            beaconPulseLayer.cornerRadius = 8.0
            beaconLayer.transform = CATransform3DIdentity
            beaconPulseLayer.transform = CATransform3DIdentity

            let haloExpand = CABasicAnimation(keyPath: "transform.scale")
            haloExpand.fromValue = 0.9
            haloExpand.toValue = 2.4
            haloExpand.duration = 1.5
            haloExpand.timingFunction = CAMediaTimingFunction(name: .easeOut)
            haloExpand.repeatCount = .infinity
            beaconPulseLayer.add(haloExpand, forKey: "haloExpand")

            let haloFade = CABasicAnimation(keyPath: "opacity")
            haloFade.fromValue = 0.85
            haloFade.toValue = 0.0
            haloFade.duration = 1.5
            haloFade.timingFunction = CAMediaTimingFunction(name: .easeOut)
            haloFade.repeatCount = .infinity
            beaconPulseLayer.add(haloFade, forKey: "haloFade")

        case .draculaGothicHeartbeat:
            // Dracula Gothic floating eerie vampire double-pulse heartbeat
            beaconLayer.cornerRadius = 4.0
            beaconPulseLayer.cornerRadius = 8.0
            beaconLayer.transform = CATransform3DIdentity
            beaconPulseLayer.transform = CATransform3DIdentity

            let heartbeat = CAKeyframeAnimation(keyPath: "transform.scale")
            heartbeat.values = [1.0, 1.35, 1.08, 1.5, 1.0, 1.0]
            heartbeat.keyTimes = [0.0, 0.18, 0.32, 0.5, 0.72, 1.0]
            heartbeat.duration = 1.3
            heartbeat.repeatCount = .infinity
            beaconPulseLayer.add(heartbeat, forKey: "draculaHeartbeat")

            let floatAnim = CAKeyframeAnimation(keyPath: "position.y")
            let midY = beaconLayer.position.y
            floatAnim.values = [midY, midY - 2.5, midY, midY + 2.5, midY]
            floatAnim.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
            floatAnim.duration = 2.6
            floatAnim.repeatCount = .infinity
            beaconLayer.add(floatAnim, forKey: "draculaFloat")

        case .finelineCelestialOrbit:
            // Fineline Celestial Orbit: Pin-sharp micro-needle star with expanding orbital ripples
            beaconLayer.cornerRadius = 2.0
            beaconPulseLayer.cornerRadius = 8.0
            beaconLayer.transform = CATransform3DIdentity
            beaconPulseLayer.transform = CATransform3DIdentity
            beaconPulseLayer.borderWidth = 0.75
            beaconPulseLayer.borderColor = color.withAlphaComponent(0.85).cgColor
            beaconPulseLayer.backgroundColor = NSColor.clear.cgColor

            let orbitScale = CABasicAnimation(keyPath: "transform.scale")
            orbitScale.fromValue = 0.5
            orbitScale.toValue = 2.2
            orbitScale.duration = 1.6
            orbitScale.timingFunction = CAMediaTimingFunction(name: .easeOut)
            orbitScale.repeatCount = .infinity
            beaconPulseLayer.add(orbitScale, forKey: "orbitScale")

            let orbitFade = CABasicAnimation(keyPath: "opacity")
            orbitFade.fromValue = 0.95
            orbitFade.toValue = 0.0
            orbitFade.duration = 1.6
            orbitFade.timingFunction = CAMediaTimingFunction(name: .easeOut)
            orbitFade.repeatCount = .infinity
            beaconPulseLayer.add(orbitFade, forKey: "orbitFade")
        }
    }

    public func updateActivity(_ activity: AgentActivity) {
        let textChanged = (currentActivity.detail != activity.detail)
        currentActivity = activity
        applyTheme(textChanged: textChanged)
    }

    public func applyTheme(textChanged: Bool = false) {
        let color = ThemeManager.shared.color(for: currentActivity.state)
        themeColor = color
        let currentTheme = ThemeManager.shared.currentTheme
        let isMatrix = currentTheme.id == "matrix"
        let isLight = currentTheme.isLightMode

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.2)

            self.beaconLayer.backgroundColor = color.cgColor
            self.beaconLayer.shadowColor = color.cgColor
            self.beaconPulseLayer.backgroundColor = color.withAlphaComponent(isLight ? 0.35 : 0.25).cgColor

            // Typography & Headers
            let headerText: String
            if isMatrix {
                let stateTag = self.currentActivity.state.uppercased()
                headerText = "> SYS://AGY.KERNEL [\(stateTag)]"
            } else {
                headerText = self.currentActivity.header
            }

            self.headerLabel.attributedStringValue = currentTheme.makeAttributedHeader(text: headerText, color: color, size: 9.0)
            self.configureBeaconAnimation(for: currentTheme, color: color)

            // Text Decrypt / Scramble Animation for Matrix Theme
            if isMatrix {
                if textChanged || self.currentDisplayTargetText != self.currentActivity.detail {
                    self.scrambleAnimateText(to: self.currentActivity.detail)
                }
            } else {
                self.stopMatrixTextAnimations()
                let detailColor = isLight ? NSColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0) : .white
                self.detailLabel.attributedStringValue = currentTheme.makeAttributedDetail(text: self.currentActivity.detail, color: detailColor, size: 11.5)
            }

            if isLight {
                self.moreButton.layer?.backgroundColor = NSColor(white: 0.0, alpha: 0.06).cgColor
                self.moreButton.layer?.borderColor = NSColor(white: 0.0, alpha: 0.16).cgColor
                self.moreButton.attributedTitle = NSAttributedString(
                    string: "⋮",
                    attributes: [
                        .font: NSFont.systemFont(ofSize: 14, weight: .bold),
                        .foregroundColor: NSColor(red: 0.22, green: 0.22, blue: 0.25, alpha: 1.0)
                    ]
                )
            } else {
                self.moreButton.layer?.backgroundColor = color.withAlphaComponent(0.12).cgColor
                self.moreButton.layer?.borderColor = color.withAlphaComponent(0.35).cgColor
                self.moreButton.attributedTitle = NSAttributedString(
                    string: "⋮",
                    attributes: [
                        .font: NSFont.systemFont(ofSize: 14, weight: .bold),
                        .foregroundColor: color
                    ]
                )
            }

            self.equalizer.setAnimating(self.currentActivity.isAnimated, color: color.cgColor)

            // Trigger active chromatic glitch if enabled for current theme
            let shouldGlitch = currentTheme.hasGlitchEffect && (self.currentActivity.state == "working" || self.currentActivity.state == "thinking")
            self.glitchOverlay.setGlitching(shouldGlitch)
            if !shouldGlitch {
                self.glitchAccentColor = nil
            }

            // Trigger Matrix digital rain if enabled for current theme
            let shouldRain = currentTheme.hasMatrixRain && (self.currentActivity.state == "working" || self.currentActivity.state == "thinking")
            self.matrixRain.setStreaming(shouldRain)

            self.needsLayout = true
            self.needsDisplay = true
            CATransaction.commit()
        }
    }

    // MARK: - Matrix Text Decryption & Blinking Block Cursor
    private func scrambleAnimateText(to target: String) {
        scrambleTimer?.invalidate()
        cursorTimer?.invalidate()

        currentDisplayTargetText = target
        let targetChars = Array(target)
        let totalSteps = 12
        var currentStep = 0

        scrambleTimer = Timer.scheduledTimer(withTimeInterval: 0.025, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
            currentStep += 1

            let progress = CGFloat(currentStep) / CGFloat(totalSteps)
            let unlockedCount = Int(progress * CGFloat(targetChars.count))

            var result = ""
            for i in 0..<targetChars.count {
                if i < unlockedCount {
                    result.append(targetChars[i])
                } else {
                    let randChar = self.matrixChars.randomElement() ?? "*"
                    result.append(randChar)
                }
            }

            let matrixColor = NSColor(red: 0.8, green: 1.0, blue: 0.85, alpha: 1.0)
            self.detailLabel.attributedStringValue = ThemeManager.shared.currentTheme.makeAttributedDetail(text: "> " + result + " █", color: matrixColor, size: 11.5)

            if currentStep >= totalSteps {
                timer.invalidate()
                self.scrambleTimer = nil
                self.startBlinkingCursor()
            }
        }
    }

    private func startBlinkingCursor() {
        cursorTimer?.invalidate()
        cursorVisible = true
        let matrixColor = NSColor(red: 0.8, green: 1.0, blue: 0.85, alpha: 1.0)
        self.detailLabel.attributedStringValue = ThemeManager.shared.currentTheme.makeAttributedDetail(text: "> " + self.currentDisplayTargetText + " █", color: matrixColor, size: 11.5)

        cursorTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self, ThemeManager.shared.currentTheme.id == "matrix" else { return }
            self.cursorVisible.toggle()
            let cursor = self.cursorVisible ? " █" : ""
            let matrixColor = NSColor(red: 0.8, green: 1.0, blue: 0.85, alpha: 1.0)
            self.detailLabel.attributedStringValue = ThemeManager.shared.currentTheme.makeAttributedDetail(text: "> " + self.currentDisplayTargetText + cursor, color: matrixColor, size: 11.5)
        }
    }

    private func stopMatrixTextAnimations() {
        scrambleTimer?.invalidate()
        scrambleTimer = nil
        cursorTimer?.invalidate()
        cursorTimer = nil
    }
}
