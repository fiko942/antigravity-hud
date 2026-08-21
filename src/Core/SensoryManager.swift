import Cocoa

// MARK: - Sensory Feedback System (Haptics & Theme-Specific Completion Chimes)
public class SensoryManager {
    public static let shared = SensoryManager()

    private init() {}

    public func triggerHaptic(pattern: NSHapticFeedbackManager.FeedbackPattern? = nil) {
        guard SettingsManager.shared.hapticsEnabled else { return }
        let effectivePattern = pattern ?? ThemeManager.shared.currentTheme.hapticPattern
        DispatchQueue.main.async {
            NSHapticFeedbackManager.defaultPerformer.perform(effectivePattern, performanceTime: .now)
        }
    }

    public func playCompletionChime(for theme: ThemeDefinition? = nil) {
        guard SettingsManager.shared.soundEnabled else { return }
        let soundName = theme?.completionSoundName ?? ThemeManager.shared.currentTheme.completionSoundName
        DispatchQueue.main.async {
            NSSound(named: soundName)?.play()
        }
    }
}
