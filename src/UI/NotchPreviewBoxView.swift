import Cocoa
import QuartzCore

// MARK: - Interactive Real-Time Notch Preview Canvas
public class NotchPreviewBoxView: NSView {
    public var isExpandedPreview: Bool = true {
        didSet {
            updatePreview()
        }
    }

    public var previewExpandedWidth: CGFloat = 380.0 {
        didSet {
            needsDisplay = true
            updateSublayers()
        }
    }

    public var previewExpandedHeight: CGFloat = 46.0 {
        didSet {
            needsDisplay = true
            updateSublayers()
        }
    }

    public var previewCompactWidth: CGFloat = 185.0 {
        didSet {
            needsDisplay = true
            updateSublayers()
        }
    }

    public var previewCompactHeight: CGFloat = 2.0 {
        didSet {
            needsDisplay = true
            updateSublayers()
        }
    }

    private let notchShapeLayer = CAShapeLayer()
    private let glowShapeLayer = CAShapeLayer()
    private let beaconLayer = CALayer()
    private let headerTextLayer = CATextLayer()
    private let detailTextLayer = CATextLayer()
    private let equalizerLayer = CALayer()
    private var eqBars: [CALayer] = []

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        setupUI()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
        setupUI()
    }

    private func setupUI() {
        guard let layer = self.layer else { return }

        // Screen Bezel Simulation Background
        layer.cornerRadius = 12.0
        layer.backgroundColor = NSColor(white: 0.08, alpha: 0.85).cgColor
        layer.borderColor = NSColor(white: 1.0, alpha: 0.12).cgColor
        layer.borderWidth = 1.0
        layer.masksToBounds = true

        // Notch Shape Layers
        layer.addSublayer(notchShapeLayer)
        layer.addSublayer(glowShapeLayer)

        // Status Beacon
        beaconLayer.cornerRadius = 4
        layer.addSublayer(beaconLayer)

        // Text Layers
        headerTextLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0
        headerTextLayer.alignmentMode = .left
        layer.addSublayer(headerTextLayer)

        detailTextLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0
        detailTextLayer.alignmentMode = .left
        layer.addSublayer(detailTextLayer)

        // Equalizer Simulation
        for _ in 0..<4 {
            let bar = CALayer()
            bar.cornerRadius = 1.5
            equalizerLayer.addSublayer(bar)
            eqBars.append(bar)
        }
        layer.addSublayer(equalizerLayer)

        updatePreview()
    }

    public func updatePreview() {
        let theme = ThemeManager.shared.currentTheme
        let color = theme.palette.working
        let isLight = theme.isLightMode

        // Background color
        if isLight {
            notchShapeLayer.fillColor = NSColor(red: 0.965, green: 0.97, blue: 0.98, alpha: 1.0).cgColor
            glowShapeLayer.strokeColor = NSColor(white: 0.0, alpha: 0.2).cgColor
            glowShapeLayer.lineWidth = 1.2
            detailTextLayer.foregroundColor = NSColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0).cgColor
        } else if theme.shapeType == .finelineConstellation {
            notchShapeLayer.fillColor = NSColor(red: 0.04, green: 0.04, blue: 0.05, alpha: 1.0).cgColor
            glowShapeLayer.strokeColor = color.withAlphaComponent(0.95).cgColor
            glowShapeLayer.lineWidth = 1.0
            detailTextLayer.foregroundColor = NSColor(red: 0.94, green: 0.93, blue: 0.91, alpha: 1.0).cgColor
        } else {
            notchShapeLayer.fillColor = NSColor.black.cgColor
            glowShapeLayer.strokeColor = color.withAlphaComponent(0.85).cgColor
            glowShapeLayer.lineWidth = 1.6
            detailTextLayer.foregroundColor = NSColor.white.cgColor
        }

        glowShapeLayer.fillColor = NSColor.clear.cgColor
        beaconLayer.backgroundColor = color.cgColor

        // Header & Detail Text with Custom Attributed Kerning
        let headerString: String
        let detailString: String
        let detailTextColor: NSColor

        if theme.id == "matrix" {
            headerString = "> SYS://AGY.KERNEL [WORKING]"
            detailString = "> Running command █"
            detailTextColor = NSColor(red: 0.8, green: 1.0, blue: 0.85, alpha: 1.0)
        } else {
            headerString = "ANTIGRAVITY • WORKING"
            detailString = "Editing SQLiteStorageManager.swift"
            detailTextColor = isLight ? NSColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0) : .white
        }

        headerTextLayer.string = theme.makeAttributedHeader(text: headerString, color: color, size: 8.5)
        detailTextLayer.string = theme.makeAttributedDetail(text: detailString, color: detailTextColor, size: 10.5)

        // Equalizer Bars
        for (i, bar) in eqBars.enumerated() {
            bar.backgroundColor = color.cgColor
            let heights: [CGFloat] = [12, 16, 10, 14]
            bar.frame = CGRect(x: CGFloat(i) * 5, y: 16 - heights[i], width: 3, height: heights[i])
        }

        updateSublayers()
    }

    private func updateSublayers() {
        let boxW = bounds.width
        let theme = ThemeManager.shared.currentTheme
        let notchHardwareH: CGFloat = 26.0

        let targetW: CGFloat
        let targetH: CGFloat

        if isExpandedPreview {
            // Scale proportionally to preview box (factor ~0.72)
            let scale: CGFloat = 0.72
            targetW = min(boxW - 30, previewExpandedWidth * scale)
            targetH = notchHardwareH + (previewExpandedHeight * scale)

            headerTextLayer.isHidden = false
            detailTextLayer.isHidden = false
            equalizerLayer.isHidden = false
        } else {
            let scale: CGFloat = 0.72
            targetW = min(boxW - 60, previewCompactWidth * scale)
            targetH = notchHardwareH + (previewCompactHeight * scale)

            headerTextLayer.isHidden = true
            detailTextLayer.isHidden = true
            equalizerLayer.isHidden = true
        }

        let startX = (boxW - targetW) / 2
        let path = NSBezierPath()
        let glowPath = NSBezierPath()

        // Geometry contour
        switch theme.shapeType {
        case .finelineConstellation:
            let rad: CGFloat = isExpandedPreview ? 14.0 : 6.0
            path.move(to: NSPoint(x: startX, y: 0))
            path.line(to: NSPoint(x: startX + targetW, y: 0))
            path.line(to: NSPoint(x: startX + targetW, y: targetH - rad))
            path.appendArc(withCenter: NSPoint(x: startX + targetW - rad, y: targetH - rad), radius: rad, startAngle: 0, endAngle: 90, clockwise: false)
            path.line(to: NSPoint(x: startX + rad, y: targetH))
            path.appendArc(withCenter: NSPoint(x: startX + rad, y: targetH - rad), radius: rad, startAngle: 90, endAngle: 180, clockwise: false)
            path.close()

            glowPath.move(to: NSPoint(x: startX, y: targetH - rad))
            glowPath.appendArc(withCenter: NSPoint(x: startX + rad, y: targetH - rad), radius: rad, startAngle: 180, endAngle: 90, clockwise: true)
            glowPath.line(to: NSPoint(x: startX + targetW - rad, y: targetH))
            glowPath.appendArc(withCenter: NSPoint(x: startX + targetW - rad, y: targetH - rad), radius: rad, startAngle: 90, endAngle: 0, clockwise: true)

        case .cyberpunkCut:
            let chamfer: CGFloat = isExpandedPreview ? 10.0 : 4.0
            path.move(to: NSPoint(x: startX, y: 0))
            path.line(to: NSPoint(x: startX + targetW, y: 0))
            path.line(to: NSPoint(x: startX + targetW, y: targetH - chamfer))
            path.line(to: NSPoint(x: startX + targetW - chamfer, y: targetH))
            path.line(to: NSPoint(x: startX + chamfer, y: targetH))
            path.line(to: NSPoint(x: startX, y: targetH - chamfer))
            path.close()

            glowPath.move(to: NSPoint(x: startX, y: targetH - chamfer))
            glowPath.line(to: NSPoint(x: startX + chamfer, y: targetH))
            glowPath.line(to: NSPoint(x: startX + targetW - chamfer, y: targetH))
            glowPath.line(to: NSPoint(x: startX + targetW, y: targetH - chamfer))

        case .matrixBracket:
            let rad: CGFloat = isExpandedPreview ? 3.0 : 1.5
            path.move(to: NSPoint(x: startX, y: 0))
            path.line(to: NSPoint(x: startX + targetW, y: 0))
            path.line(to: NSPoint(x: startX + targetW, y: targetH - rad))
            path.line(to: NSPoint(x: startX + targetW - rad, y: targetH))
            path.line(to: NSPoint(x: startX + rad, y: targetH))
            path.line(to: NSPoint(x: startX, y: targetH - rad))
            path.close()

            glowPath.move(to: NSPoint(x: startX, y: targetH - 8))
            glowPath.line(to: NSPoint(x: startX, y: targetH))
            glowPath.line(to: NSPoint(x: startX + 12, y: targetH))
            glowPath.move(to: NSPoint(x: startX + 16, y: targetH - 1))
            glowPath.line(to: NSPoint(x: startX + targetW - 16, y: targetH - 1))
            glowPath.move(to: NSPoint(x: startX + targetW - 12, y: targetH))
            glowPath.line(to: NSPoint(x: startX + targetW, y: targetH))
            glowPath.line(to: NSPoint(x: startX + targetW, y: targetH - 8))

        case .sunsetPill:
            let rad: CGFloat = isExpandedPreview ? 16.0 : 7.0
            path.move(to: NSPoint(x: startX, y: 0))
            path.line(to: NSPoint(x: startX + targetW, y: 0))
            path.line(to: NSPoint(x: startX + targetW, y: targetH - rad))
            path.appendArc(withCenter: NSPoint(x: startX + targetW - rad, y: targetH - rad), radius: rad, startAngle: 0, endAngle: 90, clockwise: false)
            path.line(to: NSPoint(x: startX + rad, y: targetH))
            path.appendArc(withCenter: NSPoint(x: startX + rad, y: targetH - rad), radius: rad, startAngle: 90, endAngle: 180, clockwise: false)
            path.close()

            glowPath.move(to: NSPoint(x: startX, y: targetH - rad))
            glowPath.appendArc(withCenter: NSPoint(x: startX + rad, y: targetH - rad), radius: rad, startAngle: 180, endAngle: 90, clockwise: true)
            glowPath.line(to: NSPoint(x: startX + targetW - rad, y: targetH))
            glowPath.appendArc(withCenter: NSPoint(x: startX + targetW - rad, y: targetH - rad), radius: rad, startAngle: 90, endAngle: 0, clockwise: true)

        case .draculaGothic:
            let bevel: CGFloat = isExpandedPreview ? 6.0 : 2.5
            path.move(to: NSPoint(x: startX, y: 0))
            path.line(to: NSPoint(x: startX + targetW, y: 0))
            path.line(to: NSPoint(x: startX + targetW, y: targetH - bevel))
            path.line(to: NSPoint(x: startX + targetW - bevel, y: targetH))
            path.line(to: NSPoint(x: startX + bevel, y: targetH))
            path.line(to: NSPoint(x: startX, y: targetH - bevel))
            path.close()

            glowPath.move(to: NSPoint(x: startX, y: targetH - bevel))
            glowPath.line(to: NSPoint(x: startX + bevel, y: targetH))
            glowPath.line(to: NSPoint(x: startX + targetW - bevel, y: targetH))
            glowPath.line(to: NSPoint(x: startX + targetW, y: targetH - bevel))

        case .rounded:
            let rad: CGFloat = isExpandedPreview ? 14.0 : 6.0
            path.move(to: NSPoint(x: startX, y: 0))
            path.line(to: NSPoint(x: startX + targetW, y: 0))
            path.line(to: NSPoint(x: startX + targetW, y: targetH - rad))
            path.appendArc(withCenter: NSPoint(x: startX + targetW - rad, y: targetH - rad), radius: rad, startAngle: 0, endAngle: 90, clockwise: false)
            path.line(to: NSPoint(x: startX + rad, y: targetH))
            path.appendArc(withCenter: NSPoint(x: startX + rad, y: targetH - rad), radius: rad, startAngle: 90, endAngle: 180, clockwise: false)
            path.close()

            glowPath.move(to: NSPoint(x: startX, y: targetH - rad))
            glowPath.appendArc(withCenter: NSPoint(x: startX + rad, y: targetH - rad), radius: rad, startAngle: 180, endAngle: 90, clockwise: true)
            glowPath.line(to: NSPoint(x: startX + targetW - rad, y: targetH))
            glowPath.appendArc(withCenter: NSPoint(x: startX + targetW - rad, y: targetH - rad), radius: rad, startAngle: 90, endAngle: 0, clockwise: true)
        }

        notchShapeLayer.path = path.cgPath
        glowShapeLayer.path = glowPath.cgPath

        // Positioning elements
        if isExpandedPreview {
            let dropDownH = targetH - notchHardwareH
            let activeMidY = notchHardwareH + (dropDownH / 2)
            beaconLayer.bounds = CGRect(x: 0, y: 0, width: 7, height: 7)
            beaconLayer.position = CGPoint(x: startX + 17.5, y: activeMidY)

            let eqW: CGFloat = 20
            equalizerLayer.frame = CGRect(x: startX + targetW - eqW - 14, y: activeMidY - 8, width: eqW, height: 16)

            let labelX = startX + 28
            let labelW = max(60, equalizerLayer.frame.minX - labelX - 6)

            let headerH: CGFloat = dropDownH < 30 ? 10 : 12
            let detailH: CGFloat = dropDownH < 30 ? 12 : 14
            let spacing: CGFloat = dropDownH < 30 ? 1 : 2
            let totalTextH = headerH + spacing + detailH
            let textStartY = activeMidY - (totalTextH / 2)

            headerTextLayer.frame = CGRect(x: labelX, y: textStartY, width: labelW, height: headerH)
            detailTextLayer.frame = CGRect(x: labelX, y: textStartY + headerH + spacing, width: labelW, height: detailH)
        } else {
            beaconLayer.bounds = CGRect(x: 0, y: 0, width: 6, height: 6)
            beaconLayer.position = CGPoint(x: boxW / 2, y: targetH - 2.5)
        }
    }

    public override func layout() {
        super.layout()
        updateSublayers()
    }
}

// CGPath helper for NSBezierPath
extension NSBezierPath {
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        for i in 0..<elementCount {
            let type = element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo: path.move(to: points[0])
            case .lineTo: path.addLine(to: points[0])
            case .curveTo, .cubicCurveTo: path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .quadraticCurveTo: path.addQuadCurve(to: points[1], control: points[0])
            case .closePath: path.closeSubpath()
            @unknown default: break
            }
        }
        return path
    }
}
