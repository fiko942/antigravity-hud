# Theme-Specific Audio Chime & Sensory Experience Specification

## Overview
This specification details the design for **Theme-Specific Audio Chimes & Sensory Feedback** in Antigravity HUD. Whenever a task reaches the `DONE` state or an interaction occurs, the audio chime and tactile trackpad haptics adapt dynamically to match the personality of the active theme.

---

## 1. Theme-Specific Sensory & Sound Catalog

| Theme ID | Completion Audio Chime | Sound Character | Trackpad Haptic Pattern |
| :--- | :--- | :--- | :--- |
| **`fineline`** | **`Tink`** | Delicate, crisp crystalline needle resonance | `.alignment` (ultra-light precision tick) |
| **`dracula`** | **`Basso`** | Deep gothic crypt cathedral chime | `.generic` (eerie heavy thud) |
| **`matrix`** | **`Morse`** | Digital phosphor CRT teletype data burst | `.levelChange` (quick digital stepped pulse) |
| **`cyberpunk`** | **`Funk`** | Punchy electronic mecha synth strobe | `.levelChange` (high-energy kick) |
| **`sunset`** | **`Hero`** | Radiant 80s retro synth triumphant fanfare | `.generic` (warm resonant pulse) |
| **`general`** / **`macos-light`** | **`Glass`** | Pure Apple signature frosted glass chime | `.generic` (standard macOS tactile feedback) |

---

## 2. Architecture & File Updates

1. **`src/Themes/ThemeStyle.swift`**:
   - Add `completionSoundName: String` and `hapticPattern: NSHapticFeedbackManager.FeedbackPattern` to `ThemeDefinition`.
2. **`src/Themes/ThemeManager.swift`**:
   - Register theme-specific sounds (`Tink`, `Basso`, `Morse`, `Funk`, `Hero`, `Glass`) in `availableThemes`.
3. **`src/Core/SensoryManager.swift`**:
   - Update `playCompletionChime(for:)` to play the active theme's `completionSoundName`.
   - Update `triggerHaptic(pattern:)` to use the active theme's `hapticPattern`.
4. **`src/App/AppDelegate.swift`**:
   - Pass active theme sensory attributes on activity completion and user interactions.

---

## 3. Verification Plan

1. Compile via `bash build.sh` and install to `/Applications/AntigravityHUD.app`.
2. Test task completion (`DONE` state) across each theme:
   - Verify `Tink` for Fineline.
   - Verify `Basso` for Dracula.
   - Verify `Morse` for Matrix.
   - Verify `Funk` for Cyberpunk.
   - Verify `Hero` for Sunset.
   - Verify `Glass` for Classic.
3. Commit locally to Git.
