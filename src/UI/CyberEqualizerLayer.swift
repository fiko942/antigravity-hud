import Cocoa
import QuartzCore

// MARK: - Animated Cyber Waveform / Equalizer Component (Flicker-Free State Guarded)
public class CyberEqualizerLayer: CALayer {
    private var bars: [CALayer] = []
    private let barCount = 4
    private let barWidth: CGFloat = 2.5
    private let barSpacing: CGFloat = 2.5

    private var isCurrentlyAnimating: Bool = false
    private var currentColor: CGColor? = nil

    public override init() {
        super.init()
        setupBars()
    }

    public override init(layer: Any) {
        super.init(layer: layer)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBars()
    }

    private func setupBars() {
        for _ in 0..<barCount {
            let bar = CALayer()
            bar.cornerRadius = 1.25
            bar.backgroundColor = NSColor(red: 0.0, green: 0.94, blue: 1.0, alpha: 1.0).cgColor
            addSublayer(bar)
            bars.append(bar)
        }
        updateLayout()
    }

    public func updateLayout() {
        let totalW = CGFloat(barCount) * barWidth + CGFloat(barCount - 1) * barSpacing
        let startX = (bounds.width - totalW) / 2
        let midY = bounds.height / 2

        for (i, bar) in bars.enumerated() {
            let h: CGFloat = 4.0
            let x = startX + CGFloat(i) * (barWidth + barSpacing)
            bar.frame = CGRect(x: x, y: midY - (h / 2), width: barWidth, height: h)
        }
    }

    public func setAnimating(_ animating: Bool, color: CGColor) {
        // Update color seamlessly if changed
        if currentColor != color {
            currentColor = color
            for bar in bars {
                bar.backgroundColor = color
            }
        }

        // Prevent restarting existing active animations (prevents flickering/stuttering)
        if isCurrentlyAnimating == animating {
            return
        }
        isCurrentlyAnimating = animating

        for (i, bar) in bars.enumerated() {
            bar.removeAnimation(forKey: "equalize")

            if animating {
                let anim = CAKeyframeAnimation(keyPath: "bounds.size.height")
                let minH: CGFloat = 3.0
                let maxH: CGFloat = CGFloat([14, 18, 16, 12][i])
                let midH: CGFloat = CGFloat([8, 12, 10, 7][i])

                anim.values = [minH, maxH, midH, maxH * 0.7, minH]
                anim.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
                anim.duration = Double([0.65, 0.55, 0.75, 0.60][i])
                anim.repeatCount = .infinity
                anim.autoreverses = true
                anim.timeOffset = Double(i) * 0.15
                anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

                bar.add(anim, forKey: "equalize")
            } else {
                bar.frame.size.height = 3.0
            }
        }
    }
}
