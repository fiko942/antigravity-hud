import Cocoa
import QuartzCore

// MARK: - Animated Matrix Digital Rain Stream Layer
public class MatrixRainLayer: CALayer {
    private let matrixChars = Array("0123456789ABCDEF010101XYZ<>[]/*{}#%^&")
    private var columnLayers: [CATextLayer] = []
    private var isStreaming: Bool = false
    private var rainTimer: Timer? = nil

    public override init() {
        super.init()
        setupColumns()
    }

    public override init(layer: Any) {
        super.init(layer: layer)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupColumns()
    }

    private func setupColumns() {
        masksToBounds = true
        opacity = 0.0
    }

    public func updateLayout(width: CGFloat, height: CGFloat) {
        frame = CGRect(x: 0, y: 0, width: width, height: height)
        rebuildColumns(width: width, height: height)
    }

    private func rebuildColumns(width: CGFloat, height: CGFloat) {
        columnLayers.forEach { $0.removeFromSuperlayer() }
        columnLayers.removeAll()

        let colWidth: CGFloat = 14.0
        let colCount = max(1, Int(width / colWidth))

        for i in 0..<colCount {
            let textLayer = CATextLayer()
            let x = CGFloat(i) * colWidth + 2.0
            textLayer.frame = CGRect(x: x, y: 0, width: colWidth, height: height + 60)
            textLayer.font = NSFont.monospacedSystemFont(ofSize: 8.5, weight: .bold)
            textLayer.fontSize = 8.5
            textLayer.foregroundColor = NSColor(red: 0.0, green: 1.0, blue: 0.35, alpha: CGFloat.random(in: 0.15...0.35)).cgColor
            textLayer.alignmentMode = .center
            textLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0
            textLayer.string = generateRandomStream(length: 12)
            addSublayer(textLayer)
            columnLayers.append(textLayer)
        }
    }

    private func generateRandomStream(length: Int) -> String {
        var chars: [Character] = []
        for _ in 0..<length {
            if let c = matrixChars.randomElement() {
                chars.append(c)
            }
        }
        return chars.map { String($0) }.joined(separator: "\n")
    }

    public func setStreaming(_ active: Bool) {
        guard isStreaming != active else { return }
        isStreaming = active

        if active {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.3)
            opacity = 1.0
            CATransaction.commit()

            startRainAnimation()
        } else {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.25)
            opacity = 0.0
            CATransaction.commit()

            stopRainAnimation()
        }
    }

    private func startRainAnimation() {
        rainTimer?.invalidate()
        for (i, col) in columnLayers.enumerated() {
            col.removeAnimation(forKey: "rainSlide")

            let anim = CABasicAnimation(keyPath: "position.y")
            anim.fromValue = -CGFloat.random(in: 20...60)
            anim.toValue = bounds.height + 40
            anim.duration = Double.random(in: 1.8...3.2)
            anim.repeatCount = .infinity
            anim.timeOffset = Double(i) * 0.23
            anim.timingFunction = CAMediaTimingFunction(name: .linear)
            col.add(anim, forKey: "rainSlide")
        }

        // Random character mutations every 150ms for realistic digital rain
        rainTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { [weak self] _ in
            guard let self = self, self.isStreaming else { return }
            for col in self.columnLayers {
                if Bool.random() && Bool.random() {
                    col.string = self.generateRandomStream(length: 10)
                }
            }
        }
    }

    private func stopRainAnimation() {
        rainTimer?.invalidate()
        rainTimer = nil
        for col in columnLayers {
            col.removeAllAnimations()
        }
    }
}
