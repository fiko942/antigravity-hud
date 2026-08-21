import Cocoa
import QuartzCore

// MARK: - Animated Multi-Themed Audio Equalizer Waveform Component
public class CyberEqualizerLayer: CALayer {
    private var bars: [CALayer] = []
    private let barCount = 4
    private var currentStyle: ThemeEqualizerStyle = .classicWave

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

    public func configureStyle(_ style: ThemeEqualizerStyle) {
        if currentStyle != style {
            currentStyle = style
            isCurrentlyAnimating = false // Reset animation state to force fresh rebuild
            updateLayout()
        }
    }

    public func updateLayout() {
        let barWidth: CGFloat
        let barSpacing: CGFloat

        switch currentStyle {
        case .finelineNeedle:
            barWidth = 1.0
            barSpacing = 3.5
        case .cyberpunkBlocks:
            barWidth = 3.0
            barSpacing = 2.0
        case .matrixBinary:
            barWidth = 2.5
            barSpacing = 2.5
        case .synthwavePillars:
            barWidth = 2.8
            barSpacing = 2.5
        case .draculaSpikes:
            barWidth = 2.2
            barSpacing = 2.8
        case .classicWave:
            barWidth = 2.5
            barSpacing = 2.5
        }

        let totalW = CGFloat(barCount) * barWidth + CGFloat(barCount - 1) * barSpacing
        let startX = (bounds.width - totalW) / 2
        let midY = bounds.height / 2

        for (i, bar) in bars.enumerated() {
            let h: CGFloat = 3.5
            let x = startX + CGFloat(i) * (barWidth + barSpacing)
            bar.frame = CGRect(x: x, y: midY - (h / 2), width: barWidth, height: h)

            // Shape and corner styling
            switch currentStyle {
            case .finelineNeedle:
                bar.cornerRadius = 0.5
                bar.shadowOpacity = 0.0
            case .cyberpunkBlocks:
                bar.cornerRadius = 0.0
                bar.shadowOpacity = 0.4
                bar.shadowRadius = 1.5
            case .matrixBinary:
                bar.cornerRadius = 0.0
                bar.shadowOpacity = 0.6
                bar.shadowRadius = 2.0
            case .synthwavePillars:
                bar.cornerRadius = 1.4
                bar.shadowOpacity = 0.7
                bar.shadowRadius = 3.0
            case .draculaSpikes:
                bar.cornerRadius = 0.5
                bar.shadowOpacity = 0.5
                bar.shadowRadius = 2.5
            case .classicWave:
                bar.cornerRadius = 1.25
                bar.shadowOpacity = 0.0
            }
        }
    }

    public func setAnimating(_ animating: Bool, color: CGColor, style: ThemeEqualizerStyle? = nil) {
        if let st = style {
            configureStyle(st)
        }

        // Update color seamlessly if changed
        if currentColor != color {
            currentColor = color
            for bar in bars {
                bar.backgroundColor = color
                bar.shadowColor = color
            }
        }

        // Prevent restarting existing active animations unless forced
        if isCurrentlyAnimating == animating {
            return
        }
        isCurrentlyAnimating = animating

        for (i, bar) in bars.enumerated() {
            bar.removeAnimation(forKey: "equalize")

            if animating {
                let anim = CAKeyframeAnimation(keyPath: "bounds.size.height")
                let minH: CGFloat = (currentStyle == .finelineNeedle) ? 2.0 : 3.0

                switch currentStyle {
                case .finelineNeedle:
                    // Delicate needle oscillation
                    let maxH: CGFloat = CGFloat([12, 16, 14, 10][i])
                    let midH: CGFloat = CGFloat([6, 10, 8, 5][i])
                    anim.values = [minH, maxH, midH, maxH * 0.8, minH]
                    anim.keyTimes = [0.0, 0.28, 0.52, 0.76, 1.0]
                    anim.duration = Double([0.8, 0.68, 0.9, 0.75][i])
                    anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

                case .draculaSpikes:
                    // Sharp gothic frequency spikes
                    let maxH: CGFloat = CGFloat([15, 20, 17, 13][i])
                    let midH: CGFloat = CGFloat([5, 9, 7, 4][i])
                    anim.values = [minH, maxH, midH, maxH * 0.9, minH]
                    anim.keyTimes = [0.0, 0.18, 0.45, 0.70, 1.0]
                    anim.duration = Double([0.7, 0.55, 0.8, 0.65][i])
                    anim.timingFunction = CAMediaTimingFunction(name: .easeIn)

                case .cyberpunkBlocks:
                    // Rapid segmented jerky stepped frequency
                    let maxH: CGFloat = CGFloat([14, 18, 15, 12][i])
                    let midH: CGFloat = CGFloat([9, 13, 11, 8][i])
                    anim.values = [minH, maxH, midH, maxH * 0.6, minH]
                    anim.keyTimes = [0.0, 0.2, 0.5, 0.8, 1.0]
                    anim.duration = Double([0.45, 0.38, 0.52, 0.42][i])
                    anim.timingFunction = CAMediaTimingFunction(name: .linear)

                case .matrixBinary:
                    // Digital terminal CRT stepped binary scanlines
                    let maxH: CGFloat = CGFloat([13, 17, 14, 11][i])
                    let midH: CGFloat = CGFloat([7, 11, 8, 6][i])
                    anim.values = [minH, maxH, midH, maxH * 0.8, minH]
                    anim.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
                    anim.duration = Double([0.5, 0.45, 0.6, 0.52][i])
                    anim.timingFunction = CAMediaTimingFunction(name: .linear)

                case .synthwavePillars:
                    // 80s neon pumping horizon pillars
                    let maxH: CGFloat = CGFloat([16, 20, 18, 14][i])
                    let midH: CGFloat = CGFloat([8, 13, 10, 7][i])
                    anim.values = [minH, maxH, midH, maxH * 0.85, minH]
                    anim.keyTimes = [0.0, 0.3, 0.55, 0.8, 1.0]
                    anim.duration = Double([0.75, 0.62, 0.85, 0.7][i])
                    anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

                case .classicWave:
                    // Smooth Apple sinusoidal audio wave
                    let maxH: CGFloat = CGFloat([14, 18, 16, 12][i])
                    let midH: CGFloat = CGFloat([8, 12, 10, 7][i])
                    anim.values = [minH, maxH, midH, maxH * 0.7, minH]
                    anim.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
                    anim.duration = Double([0.65, 0.55, 0.75, 0.60][i])
                    anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                }

                anim.repeatCount = .infinity
                anim.autoreverses = true
                anim.timeOffset = Double(i) * 0.15
                bar.add(anim, forKey: "equalize")
            } else {
                bar.frame.size.height = (currentStyle == .finelineNeedle) ? 2.0 : 3.0
            }
        }
    }
}
