import Cocoa

// MARK: - Sensory Feedback System (Haptics & Completion Chimes)
public class SensoryManager {
    public static let shared = SensoryManager()

    private init() {}

    public func triggerHaptic(pattern: NSHapticFeedbackManager.FeedbackPattern = .generic) {
        guard ThemeManager.shared.hapticsEnabled else { return }
        DispatchQueue.main.async {
            NSHapticFeedbackManager.defaultPerformer.perform(pattern, performanceTime: .now)
        }
    }

    public func playCompletionChime() {
        guard ThemeManager.shared.soundEnabled else { return }
        DispatchQueue.main.async {
            NSSound(named: "Glass")?.play()
        }
    }
}
