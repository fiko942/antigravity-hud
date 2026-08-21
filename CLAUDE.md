# Antigravity HUD Developer & Agent Guide

This repository contains the native macOS Dynamic Notch Island application for Google Antigravity AI Agent.

## Core Rules & Architecture
1. **Source Code**: Modular Swift architecture organized in:
   - `src/Core/`: `SQLiteStorageManager.swift`, `FontManager.swift`, `SensoryManager.swift`, `LaunchAgentManager.swift`, `AppMutex.swift`
   - `src/Themes/`: `ThemeStyle.swift` (Geometry, Beacons, Equalizers, Buttons, Typography, Audio Chimes), `ThemeManager.swift` (7 Themes & Persistence)
   - `src/Brain/`: `BrainWatcher.swift` (100ms async polling monitoring `~/.gemini/antigravity-ide/brain/`), `AgentActivity.swift`
   - `src/UI/`: `AntigravityNotchPanel.swift`, `NotchIslandContentView.swift`, `CyberEqualizerLayer.swift`, `GlitchOverlayView.swift`, `MatrixRainView.swift`, `SettingsWindowController.swift`, `NotchPreviewBoxView.swift`
   - `src/App/`: `AppDelegate.swift`
   - `src/main.swift`: Native entry point

2. **Mandatory Live Build & Install Protocol**:
   - Whenever any code or resource is modified, you MUST automatically run:
     ```bash
     bash build.sh && killall AntigravityHUD 2>/dev/null || true && rm -rf /Applications/AntigravityHUD.app && cp -R build/AntigravityHUD.app /Applications/ && open /Applications/AntigravityHUD.app
     ```
   - Verify process is running live via `pgrep -fl AntigravityHUD`.

3. **Git Commit & Push Protocol**:
   - Commit locally only! Do NOT push directly to origin.

4. **Default Installation Profile**:
   - Default Theme: `sunset` (Sunset Synthwave Horizon)
   - Mode: `.hoverExpands`
   - Expanded: `275 x 44 pt`, Compact: `177 x 6 pt`
   - All sensory & startup checkboxes enabled (`idleHoverExpands = true`, `soundEnabled = true`, `hapticsEnabled = true`, `launchAtLogin = true`).

5. **Author Attribution**:
   - Author: **Wiji Fiko Teren**
   - Portfolio: `https://wijifikoteren.streampeg.com`
   - Saweria: `https://saweria.co/wijifikoteren`
   - GitHub: `https://github.com/fiko942`
