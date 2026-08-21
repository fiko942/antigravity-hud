# 🏝️ Antigravity HUD (macOS Dynamic Notch Island)

<p align="center">
  <img src="./Resources/AppIcon.icns" width="120" height="120" alt="Antigravity HUD Icon" />
</p>

<p align="center">
  <b>A sleek, native macOS Dynamic Island widget for Google Antigravity AI Agent that lives seamlessly inside your MacBook's camera notch.</b>
</p>

<p align="center">
  <a href="https://github.com/fiko942/antigravity-hud/releases"><img src="https://img.shields.io/badge/Release-v1.1.0-00E0FF?style=flat-square&logo=apple" alt="Release" /></a>
  <a href="https://developer.apple.com/swift/"><img src="https://img.shields.io/badge/Language-Swift%206-FA7343?style=flat-square&logo=swift" alt="Swift" /></a>
  <a href="./LICENSE"><img src="https://img.shields.io/badge/License-MIT-34D399?style=flat-square" alt="License" /></a>
  <a href="https://wijifikoteren.streampeg.com"><img src="https://img.shields.io/badge/Author-Wiji%20Fiko%20Teren-A855F7?style=flat-square&logo=safari" alt="Author Portfolio" /></a>
  <a href="https://saweria.co/wijifikoteren"><img src="https://img.shields.io/badge/Donate-Saweria-FF8800?style=flat-square&logo=coffeescript" alt="Donate via Saweria" /></a>
</p>

---

## 📸 Live Visual Showcase

<p align="center">
  <b>☀️ macOS Classic (Light Mode - Crisp Platinum Ceramic Island)</b><br>
  <img src="./docs/assets/notch-macos-light.png" alt="macOS Classic Light Notch" width="700" />
</p>

<p align="center">
  <b>🌙 macOS Classic (Dark Mode - Apple Superellipse Glass Island)</b><br>
  <img src="./docs/assets/notch-macos-dark.png" alt="macOS Classic Dark Notch" width="700" />
</p>

<p align="center">
  <b>⚡ Cyberpunk 2077 (Active Working State with Dynamic Glitch & Neural Waveform)</b><br>
  <img src="./docs/assets/notch-cyberpunk-working.png" alt="Cyberpunk Working Notch" width="700" />
</p>

<p align="center">
  <b>💻 Matrix Terminal (Digital Rain Stream & Monospace Decrypt Scramble)</b><br>
  <img src="./docs/assets/notch-matrix-thinking.png" alt="Matrix Thinking Notch" width="700" />
</p>

<p align="center">
  <b>🌅 Sunset Synthwave (Task Completed State with Horizon Glow)</b><br>
  <img src="./docs/assets/notch-sunset-done.png" alt="Sunset Done Notch" width="700" />
</p>

<p align="center">
  <b>🧛 Dracula Gothic (Stepped Micro-Bevel Contour with Royal Purple Halo)</b><br>
  <img src="./docs/assets/notch-dracula-thinking.png" alt="Dracula Thinking Notch" width="700" />
</p>

<p align="center">
  <img src="./docs/assets/preferences-window.png" alt="Preferences Window with Live Preview & Sliders" width="380" />
  &nbsp;&nbsp;
  <img src="./docs/assets/about-window.png" alt="About Window with Saweria QR Code" width="380" />
</p>

---

## ✨ Key Features & Highlights

- 🏝️ **Native Hardware Notch Integration**: Aligns perfectly with Liquid Retina XDR hardware camera notch geometry (`Y = 924...956`) across Apple Silicon MacBooks (M1 / M2 / M3 / M4 / M5).
- 🗄️ **Native SQLite3 WAL Storage Engine**:
  - Direct atomic configuration persistence powered by native Darwin SQLite3 (`import SQLite3`).
  - Configured with **WAL (*Write-Ahead Logging*)** for lightning-fast `< 0.1ms` non-blocking disk commits and `< 100KB` RAM footprint.
  - Settings survive application restarts and macOS system reboots.
- 📏 **Custom Notch Dimensions (Width & Height) with Live Demo**:
  - **Expanded / Open (Active & Hover)**: Continuous Width (`280...560pt`, default `380pt`) & Drop Height (`32...80pt`, default `46pt`) sliders.
  - **Compact / Closed (Idle)**: Continuous Width (`140...260pt`, default `185pt`) & Drop Height (`0...20pt`, default `2pt`) sliders.
  - **Live Hardware Demo Mode**: Dragging any slider immediately morphs the physical notch on your screen to demo the exact size, automatically reverting to real AI status after 2 seconds.
  - **🔄 Reset to Defaults**: Single-click button to instantly restore all dimensions to factory defaults.
- 🖥️ **Simulated Hardware Notch Live Preview Canvas**:
  - Embedded in Preferences with simulated MacBook display bezel & camera lens.
  - State toggle between **`[ 📌 Open (Expanded) ]`** and **`[ 🔒 Closed (Compact) ]`**.
  - Synchronously morphs contour geometry and color schemes across all 6 themes.
- 📐 **6 Distinct Themes with Unique Typography & Beacon Animations**:
  - **`macOS Classic (Dark)`**: Deep obsidian black with Apple superellipse ($R = 18\text{pt}$), `SF Pro` typography, and organic Siri breathing pulse.
  - **`macOS Classic (Light)`**: Crisp platinum ceramic porcelain drop-down with dark `SF Pro` typography and specular borders.
  - **`Cyberpunk 2077`**: Angular $45^\circ$ sci-fi mecha chamfers + active RGB chromatic shift glitch, heavy `Helvetica Neue Condensed Black` & `Avenir Black` typography, and high-frequency diamond glitch strobe beacon.
  - **`Matrix Terminal`**: Monospaced squared corners, authentic `Menlo` terminal typography, cascading phosphor green digital rain, text decrypt scramble, blinking cursor (`█`), and square binary blink beacon.
  - **`Sunset Synthwave`**: Continuous pill curve ($R = 22\text{pt}$), authentic 80s `Futura Bold` & `Futura Medium` typography, and expanding neon horizon halo ripple beacon.
  - **`Dracula Gothic`**: Stepped $45^\circ$ gothic micro-bevels, blood-red and royal violet glow, sharp Victorian `Didot Bold` & `Palatino Bold` serif typography, and floating vampire heartbeat beacon.
  - **`Fineline Dark (Celestial Ink)`**: Minimalist single-needle tattoo $1.0\text{pt}$ hairline contours, celestial constellation micro-dots, elegant `Optima Bold` & `Avenir Light` typography, and dual expanding concentric orbital ripple beacon.
- ⚙️ **Comprehensive Preferences & About Window (Liquid Sliding Tabs)**:
  - **Active Task Behavior Modes**: Choose between *Click to Expand (Distraction Free)*, *Hover to Expand*, or *Always Expanded*.
  - **Liquid Sliding Tab Bar**: Telegram/iOS dynamic island inspired sliding indicator bubble.
  - **Launch at Login**: Auto-register/unregister macOS `LaunchAgent` daemon.
- 🔊 **Sensory Audio-Haptic Engine**: Tactile trackpad haptic pulses on activity changes and subtle completion audio chimes.
- ⚡ **Neural Equalizer Waveform**: 4-bar dynamic audio/cyberizer animation rendered with CoreAnimation (`CAKeyframeAnimation`).
- 🔒 **Kernel Mutex**: Single-instance lock via `flock` on `/tmp/antigravity-hud.lock` prevents duplicate processes.
- 🧠 **Global Real-Time Brain Watcher**: 100ms async polling monitoring `~/.gemini/antigravity-ide/brain/` globally across all active sessions.

---

## 🎨 Interactive State Palette

| State | Default Color | Interaction Behavior | Description |
| :--- | :--- | :--- | :--- |
| **`READY` / `IDLE`** | 🟢 Emerald (`#00E073`) | Collapsed rim, hover expands | AI is standing by for user prompt |
| **`THINKING`** | 🟣 Neon Purple (`#BF5AF2`) | Pulsing rim & waveform | Planner reasoning & structuring steps |
| **`WORKING`** | 🔵 Electric Cyan (`#00F0FF`) | Equalizer wave & active tool path | Editing files, running commands, reading logs |
| **`DONE`** | 🟢 Bright Emerald (`#34D399`) | Smooth 3.5s finish confirmation | Task successfully completed |

---

## 📦 Installation

### Option 1: Download Pre-built DMG (Recommended)
1. Download the latest `AntigravityHUD-v1.1.0.dmg` from [GitHub Releases](https://github.com/fiko942/antigravity-hud/releases).
2. Open the DMG and drag **`Antigravity HUD.app`** into your **`Applications`** folder.
3. Launch `Antigravity HUD.app` from `/Applications` or Spotlight (`Cmd + Space`).
4. That's it! It automatically registers to start silently on login.

### Option 2: Build from Source
```bash
# Clone repository
git clone https://github.com/fiko942/antigravity-hud.git
cd antigravity-hud

# Build the native app bundle and DMG installer
bash build.sh

# Launch the app
open build/AntigravityHUD.app
```

---

## 🛠️ Modular Architecture

```
antigravity-hud/
├── src/
│   ├── App/
│   │   └── AppDelegate.swift        # Main lifecycle, mouse tracking, & context menu
│   ├── Brain/
│   │   ├── AgentActivity.swift      # Activity data model
│   │   └── BrainWatcher.swift       # Async JSONL seek & log parsing
│   ├── Core/
│   │   ├── LaunchAgentManager.swift # Auto-register / uninstall login daemon
│   │   ├── SensoryManager.swift     # Trackpad haptics & completion chimes
│   │   ├── SettingsManager.swift    # Persistent configuration engine
│   │   ├── SingleInstanceMutex.swift# Kernel mutex flock locking
│   │   └── SQLiteStorageManager.swift# Native SQLite3 WAL atomic persistence engine
│   ├── Themes/
│   │   ├── ThemeManager.swift       # State color palettes & config persistence
│   │   └── ThemeStyle.swift         # Dynamic notch geometry shapes & glitch specs
│   ├── UI/
│   │   ├── AntigravityNotchPanel.swift    # AppKit floating panel at Level 102
│   │   ├── CyberEqualizerLayer.swift      # 4-bar CoreAnimation waveform
│   │   ├── GlitchOverlayLayer.swift       # Cyberpunk chromatic shift glitch
│   │   ├── MatrixRainLayer.swift          # Matrix digital rain animation layer
│   │   ├── NotchIslandContentView.swift   # Dynamic notch shape drawing & kebab menu
│   │   ├── NotchPreviewBoxView.swift      # Real-time simulated notch live preview canvas
│   │   └── SettingsWindowController.swift # Preferences (Sliders, Preview) & About window
│   └── main.swift                   # Clean application entry point
├── Resources/
│   ├── AppIcon.icns                 # High-DPI macOS application icon
│   ├── Info.plist                   # macOS bundle metadata
│   ├── saweria-qr.png               # Saweria donation QR Code asset
│   └── theme.example.json           # Example theme configuration
├── docs/
│   ├── ARCHITECTURE.md              # Engineering deep dive & hardware notch specs
│   └── assets/                      # High-res screenshots and showcase images
├── build.sh                         # Production modular compiler & DMG generator
├── package.json                     # Tooling & metadata
├── LICENSE                          # MIT License
└── README.md
```

---

## 👤 Author & Credits

Created and engineered with ❤️ by **[Wiji Fiko Teren](https://wijifikoteren.streampeg.com)** ([@fiko942](https://github.com/fiko942)).
- 🌐 **Portfolio**: [https://wijifikoteren.streampeg.com](https://wijifikoteren.streampeg.com)
- 🐙 **GitHub**: [@fiko942](https://github.com/fiko942)

---

## ☕ Support & Donations

If you enjoy using **Antigravity HUD** and want to support ongoing development, maintenance, and new features, you can buy me a coffee via **Saweria**:

<p align="center">
  <a href="https://saweria.co/wijifikoteren">
    <img src="./docs/assets/saweria-qr.png" width="180" height="180" alt="Saweria QR Code" />
  </a><br>
  👉 <b><a href="https://saweria.co/wijifikoteren">saweria.co/wijifikoteren</a></b>
</p>

---

## 📄 License

This project is licensed under the [MIT License](./LICENSE) - see the LICENSE file for details.
