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
        layer?.addSublayer(matrixRain)
        layer?.addSublayer(glitchOverlay)

        glitchOverlay.onGlitchColorTick = { [weak self] color in
            guard let self = self, ThemeManager.shared.currentTheme.hasGlitchEffect else { return }
            self.glitchAccentColor = color
            self.needsDisplay = true
        }

        // Status Beacon
        beaconPulseLayer.cornerRadius = 8
        layer?.addSublayer(beaconPulseLayer)

        beaconLayer.cornerRadius = 4
        beaconLayer.shadowRadius = 5
        beaconLayer.shadowOpacity = 1.0
        beaconLayer.shadowOffset = .zero
        layer?.addSublayer(beaconLayer)

        // Labels
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

        // Fill 100% solid pure black
        NSColor.black.setFill()
        path.fill()

        // Stroke primary glowing contour
        glowPath.lineWidth = isExpandedMode ? 1.8 : 2.0
        activeStrokeColor.withAlphaComponent(isExpandedMode ? 0.9 : 0.85).setStroke()
        glowPath.stroke()
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
            beaconLayer.frame = CGRect(x: (w / 2) - 3.5, y: h - 6, width: 7, height: 7)
            beaconPulseLayer.frame = CGRect(x: (w / 2) - 7.5, y: h - 10, width: 15, height: 15)

            headerLabel.isHidden = true
            detailLabel.isHidden = true
            equalizer.isHidden = true
            moreButton.isHidden = true
        } else {
            // Expanded Drop-Down Island
            let dropDownH = h - notchH
            let activeMidY = notchH + (dropDownH / 2)

            // Left Beacon (Safe inside padding X = 20)
            let beaconX: CGFloat = 20
            beaconLayer.frame = CGRect(x: beaconX, y: activeMidY - 4, width: 8, height: 8)
            beaconPulseLayer.frame = CGRect(x: beaconX - 4, y: activeMidY - 8, width: 16, height: 16)

            // Right Vertical 3-Dots Button (⋮) (Safe inside padding X = w - 40)
            moreButton.isHidden = false
            let btnSize: CGFloat = 22
            moreButton.frame = NSRect(x: w - btnSize - 18, y: activeMidY - (btnSize / 2), width: btnSize, height: btnSize)

            // Right Equalizer (Next to 3-dots button)
            let eqW: CGFloat = 24
            let eqH: CGFloat = 20
            equalizer.isHidden = !currentActivity.isAnimated
            equalizer.frame = CGRect(x: moreButton.frame.minX - eqW - 10, y: activeMidY - (eqH / 2), width: eqW, height: eqH)
            equalizer.updateLayout()

            // Center Labels
            let labelX: CGFloat = 38
            let rightBound = currentActivity.isAnimated ? (equalizer.frame.minX - 8) : (moreButton.frame.minX - 8)
            let labelW = max(100, rightBound - labelX)

            headerLabel.isHidden = false
            headerLabel.frame = NSRect(x: labelX, y: notchH + 6, width: labelW, height: 14)

            detailLabel.isHidden = false
            detailLabel.frame = NSRect(x: labelX, y: notchH + 22, width: labelW, height: 16)
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

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.2)

            self.beaconLayer.backgroundColor = color.cgColor
            self.beaconLayer.shadowColor = color.cgColor
            self.beaconPulseLayer.backgroundColor = color.withAlphaComponent(0.25).cgColor

            // Typography & Headers
            if isMatrix {
                self.headerLabel.font = NSFont.monospacedSystemFont(ofSize: 9.0, weight: .black)
                self.detailLabel.font = NSFont.monospacedSystemFont(ofSize: 11.0, weight: .bold)
                self.detailLabel.textColor = NSColor(red: 0.8, green: 1.0, blue: 0.85, alpha: 1.0)

                let stateTag = self.currentActivity.state.uppercased()
                self.headerLabel.stringValue = "> SYS://AGY.KERNEL [\(stateTag)]"
            } else {
                self.headerLabel.font = NSFont.monospacedSystemFont(ofSize: 9.0, weight: .black)
                self.detailLabel.font = NSFont.systemFont(ofSize: 11.5, weight: .semibold)
                self.detailLabel.textColor = .white
                self.headerLabel.stringValue = self.currentActivity.header
            }

            self.headerLabel.textColor = color

            // Text Decrypt / Scramble Animation for Matrix Theme
            if isMatrix {
                if textChanged || self.currentDisplayTargetText != self.currentActivity.detail {
                    self.scrambleAnimateText(to: self.currentActivity.detail)
                }
            } else {
                self.stopMatrixTextAnimations()
                self.detailLabel.stringValue = self.currentActivity.detail
            }

            self.moreButton.layer?.backgroundColor = color.withAlphaComponent(0.12).cgColor
            self.moreButton.layer?.borderColor = color.withAlphaComponent(0.35).cgColor
            self.moreButton.attributedTitle = NSAttributedString(
                string: "⋮",
                attributes: [
                    .font: NSFont.systemFont(ofSize: 14, weight: .bold),
                    .foregroundColor: color
                ]
            )

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

            self.detailLabel.stringValue = "> " + result + " █"

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
        self.detailLabel.stringValue = "> " + self.currentDisplayTargetText + " █"

        cursorTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self, ThemeManager.shared.currentTheme.id == "matrix" else { return }
            self.cursorVisible.toggle()
            let cursor = self.cursorVisible ? " █" : ""
            self.detailLabel.stringValue = "> " + self.currentDisplayTargetText + cursor
        }
    }

    private func stopMatrixTextAnimations() {
        scrambleTimer?.invalidate()
        scrambleTimer = nil
        cursorTimer?.invalidate()
        cursorTimer = nil
    }
}
