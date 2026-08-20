import Cocoa
import QuartzCore

// MARK: - Advanced Cyberpunk Dynamic Chromatic Glitch Engine
public class GlitchOverlayLayer: CALayer {
    private var scanlines: [CALayer] = []
    private var glitchTimer: Timer?
    private var colorJitterTimer: Timer?

    public var onGlitchColorTick: ((NSColor) -> Void)?

    private let glitchColors: [NSColor] = [
        NSColor(red: 1.0, green: 0.0, blue: 0.45, alpha: 1.0),   // Neon Magenta (#FF0073)
        NSColor(red: 0.0, green: 0.96, blue: 1.0, alpha: 1.0),   // Cyber Cyan (#00F5FF)
        NSColor(red: 1.0, green: 0.88, blue: 0.0, alpha: 1.0),   // Cyberpunk Yellow (#FFE000)
        NSColor(red: 0.75, green: 0.15, blue: 1.0, alpha: 1.0),  // Electric Violet (#BF26FF)
        NSColor(red: 0.2, green: 1.0, blue: 0.4, alpha: 1.0)     // Toxic Acid Green (#33FF66)
    ]

    public override init() {
        super.init()
        setupScanlines()
    }

    public override init(layer: Any) {
        super.init(layer: layer)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupScanlines()
    }

    private func setupScanlines() {
        self.masksToBounds = true

        for i in 0..<5 {
            let line = CALayer()
            line.opacity = 0.0
            line.cornerRadius = 1.0
            line.backgroundColor = glitchColors[i % glitchColors.count].withAlphaComponent(0.65).cgColor
            addSublayer(line)
            scanlines.append(line)
        }
    }

    public func setGlitching(_ active: Bool) {
        glitchTimer?.invalidate()
        glitchTimer = nil
        colorJitterTimer?.invalidate()
        colorJitterTimer = nil

        if !active {
            for line in scanlines {
                line.opacity = 0.0
                line.removeAllAnimations()
            }
            return
        }

        // 1. High frequency chromatic glitch slices (every 0.4s to 0.8s)
        glitchTimer = Timer.scheduledTimer(withTimeInterval: 0.45, repeats: true) { [weak self] _ in
            self?.triggerDynamicGlitchBurst()
        }

        // 2. Continuous subtle color jitter pulse
        colorJitterTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if Bool.random() {
                let randomColor = self.glitchColors.randomElement()!
                self.onGlitchColorTick?(randomColor)
            }
        }
    }

    private func triggerDynamicGlitchBurst() {
        guard bounds.width > 0, bounds.height > 0 else { return }

        // Trigger 2-3 random slice lines
        let activeCount = Int.random(in: 2...scanlines.count)
        for i in 0..<activeCount {
            let line = scanlines[i]
            let color = glitchColors.randomElement()!
            line.backgroundColor = color.withAlphaComponent(0.7).cgColor

            let randomY = CGFloat.random(in: 2...(max(4, bounds.height - 6)))
            let randomH = CGFloat.random(in: 1.5...3.5)
            let randomW = bounds.width * CGFloat.random(in: 0.3...0.95)
            let randomX = CGFloat.random(in: 0...(max(1, bounds.width - randomW)))

            line.frame = CGRect(x: randomX, y: randomY, width: randomW, height: randomH)

            let anim = CAKeyframeAnimation(keyPath: "opacity")
            anim.values = [0.0, 0.9, 0.2, 0.95, 0.0]
            anim.keyTimes = [0.0, 0.15, 0.4, 0.75, 1.0]
            anim.duration = Double.random(in: 0.12...0.22)
            anim.timingFunction = CAMediaTimingFunction(name: .linear)
            line.add(anim, forKey: "chromaGlitch")
        }
    }
}
