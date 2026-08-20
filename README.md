# 🏝️ Antigravity HUD (macOS Dynamic Notch Island)

<p align="center">
  <img src="./Resources/AppIcon.icns" width="128" height="128" alt="Antigravity HUD Icon" />
</p>

<p align="center">
  <b>A sleek, native macOS Dynamic Island widget for Google Antigravity AI Agent that lives seamlessly inside your MacBook's camera notch.</b>
</p>

<p align="center">
  <a href="https://github.com/fikus942/antigravity-hud/releases"><img src="https://img.shields.io/badge/Release-v1.0.0-00E0FF?style=flat-square&logo=apple" alt="Release" /></a>
  <a href="https://developer.apple.com/swift/"><img src="https://img.shields.io/badge/Language-Swift%206-FA7343?style=flat-square&logo=swift" alt="Swift" /></a>
  <a href="./LICENSE"><img src="https://img.shields.io/badge/License-MIT-34D399?style=flat-square" alt="License" /></a>
  <a href="https://github.com/fikus942"><img src="https://img.shields.io/badge/Author-Muhammad%20Fiko%20S.-A855F7?style=flat-square&logo=github" alt="Author" /></a>
</p>

---

## ✨ Highlights & Features

- 🏝️ **MacBook Notch Integration**: Sits flush at `Y = 924...956` matching the exact physical hardware geometry of Apple Silicon MacBooks (M1 / M2 / M3 / M4).
- ⬛ **100% Solid OLED Pure Black (`drawRect`)**: Zero translucency or alpha bleeding. Prevents underlying macOS Menu Bar items (`Window`, `Help`, status icons) from showing through.
- 🎯 **Smart Dual-Interaction Modes**:
  - **Idle / Ready Mode**: The widget collapses flush with the notch, displaying only a subtle glowing emerald bottom rim and status dot. Hovering your mouse drops down the full card; moving away auto-closes it.
  - **Active Working Mode** (*Thinking / Editing Code / Running Tools*): The widget stays tucked into the notch with a pulsing Neon Purple/Cyan rim so it doesn't obstruct your workspace. **Clicking the notch toggles it open / closed** at your convenience.
- ⚡ **Neural Equalizer Waveform**: 4-bar dynamic audio/cyberizer animation rendered with CoreAnimation (`CAKeyframeAnimation`) while the AI executes tasks.
- 🚀 **Auto-Start at Login**: Self-registers a native macOS `LaunchAgent` on first launch (`com.google.antigravity.hud.plist`), ensuring zero setup required.
- 🔒 **Kernel Mutex**: Single-instance lock via `flock` on `/tmp/antigravity-hud.lock` prevents duplicate windows.
- 🧠 **Global Real-Time Brain Watcher**: Fast 100ms async polling monitoring `~/.gemini/antigravity-ide/brain/` globally across all active sessions.

---

## 🎨 Interactive State Palette

| State | Theme Color | Behavior | Description |
| :--- | :--- | :--- | :--- |
| **`READY` / `IDLE`** | 🟢 Emerald (`#00E073`) | Collapsed rim, hover to expand | AI is standing by for user prompt |
| **`THINKING`** | 🟣 Neon Purple (`#BF5AF2`) | Pulsing rim, click to toggle card | Planner reasoning & structuring steps |
| **`WORKING`** | 🔵 Electric Cyan (`#00F0FF`) | Equalizer wave, click to toggle card | Editing files, running commands, reading logs |
| **`DONE`** | 🟢 Bright Emerald (`#34D399`) | Smooth 3.5s finish confirmation | Task successfully completed |

---

## 📦 Installation

### Option 1: Download Pre-built DMG (Recommended)
1. Download the latest `AntigravityHUD-v1.0.0.dmg` from [GitHub Releases](https://github.com/fikus942/antigravity-hud/releases).
2. Open the DMG and drag **`Antigravity HUD.app`** into your **`Applications`** folder.
3. Open `Antigravity HUD.app` from `/Applications` or Spotlight (`Cmd + Space`).
4. That's it! It automatically registers with macOS `LaunchAgent` to start silently on login.

### Option 2: Build from Source
```bash
# Clone the repository
git clone https://github.com/fikus942/antigravity-hud.git
cd antigravity-hud

# Build the native app bundle and DMG installer
bash build.sh

# Launch the app
open build/AntigravityHUD.app
```

---

## 🛠️ Project Structure

```
antigravity-hud/
├── src/
│   └── main.swift          # Core AppKit & CoreAnimation implementation
├── Resources/
│   ├── AppIcon.icns        # High-DPI macOS application icon
│   └── Info.plist          # macOS bundle metadata
├── docs/
│   └── ARCHITECTURE.md     # Engineering deep dive & hardware notch specs
├── build.sh                # Production compiler & DMG release generator
├── package.json            # Tooling & metadata
├── LICENSE                 # MIT License
└── README.md
```

---

## 👤 Author & Credits

Created and engineered by **[Muhammad Fiko S.](https://github.com/fikus942)** (`@fikus942`).

Built with love for developers and AI engineers who love clean, futuristic macOS interfaces.

---

## 📄 License

This project is licensed under the [MIT License](./LICENSE) - see the LICENSE file for details.
