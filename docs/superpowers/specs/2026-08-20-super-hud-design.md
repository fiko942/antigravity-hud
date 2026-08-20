# 🏝️ Antigravity Modular Super-HUD Design Specification

- **Date**: 2026-08-20
- **Status**: Proposed / Under Review
- **Target**: `src/main.swift`

---

## 1. Overview & Objective

The **Modular Super-HUD** upgrade elevates the Antigravity macOS Dynamic Island from a high-level state indicator into an active, rich telemetry and control surface. It delivers:
1. **Granular Live Observability**: Real-time extraction of active target file paths, terminal command snippets, and task step indices from streaming JSONL logs.
2. **Audio-Tactile Sensory Feedback**: macOS trackpad haptic pulses on state transitions and subtle completion audio chimes.
3. **Dynamic Theme Engine**: User-customizable neon palettes (`cyberpunk`, `matrix`, `sunset`, `dracula`) via `~/.config/antigravity-hud/theme.json`.
4. **Interactive Action Controls**: Direct file opener (click to reveal active file in default editor/Finder) and a quick abort/stop action for active agent runs.

---

## 2. Architectural Design & Component Breakdown

```
┌─────────────────────────────────────────────────────────────┐
│                   ANTIGRAVITY SUPER-HUD                      │
├──────────────────────────────┬──────────────────────────────┤
│  OBSERVABILITY ENGINE        │  SENSORY ENGINE              │
│  - Tool Argument Parser      │  - NSHapticFeedbackManager   │
│  - Step Index Counter        │  - NSSound Audio Chimes      │
│  - File Path Truncation      │  - JSON Theme Provider       │
├──────────────────────────────┼──────────────────────────────┤
│  INTERACTION CONTROLLER      │  RENDERING PIPELINE          │
│  - Quick File Opener         │  - Solid OLED Pure Black     │
│  - Emergency Abort Trigger   │  - Dynamic Neon Border Glow  │
│  - Notch Hitbox Click/Hover  │  - 4-Bar CoreAnimation Wave  │
└──────────────────────────────┴──────────────────────────────┘
```

### A. Data Ingestion & Tool Argument Parser
- **Log Stream Target**: `~/.gemini/antigravity-ide/brain/<session-id>/.system_generated/logs/transcript.jsonl`
- **Delta Seeking**: Retains high-performance `FileHandle` seek & byte-offset tracking (target `< 0.2%` CPU standby).
- **Parsed Fields**:
  - `step_index`: Parsed as `Int` to display `Step #N`.
  - `tool_calls`:
    - `replace_file_content`, `multi_replace_file_content`, `write_to_file`, `view_file`: Extracts `TargetFile` or `AbsolutePath`, strips workspace prefix to produce clean relative path (e.g. `src/main.swift`).
    - `run_command`: Extracts `CommandLine`, truncates to 35 characters with ellipsis (e.g. `bash build.sh`).
    - `list_dir`, `grep_search`: Extracts directory or query string.
- **State Data Model**:
  ```swift
  struct AgentActivity {
      var state: String         // "idle", "thinking", "working", "done"
      var header: String        // "STEP #4 • EDITING FILE"
      var detail: String        // "src/main.swift"
      var activePath: String?   // Full path for quick file opening
      var isAnimated: Bool      // Controls equalizer waveform
  }
  ```

---

### B. Audio & Haptic Sensory System
- **Haptic Feedback**:
  - Leverages `NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)` or `.alignment`.
  - Triggered on:
    1. Transition into `working` or `thinking` state.
    2. Task completion (`done`).
    3. User click expanding/collapsing the island card.
- **Completion Audio Chime**:
  - When transitioning from `working`/`thinking` $\rightarrow$ `done`, triggers a macOS system chime (e.g. `NSSound(named: "Glass")?.play()`).
  - Configurable toggle (`soundEnabled: Bool`) via configuration.

---

### C. Dynamic Theme Engine (`theme.json`)
- **Config Path**: `~/.config/antigravity-hud/theme.json`
- **Default Palettes**:
  - `cyberpunk`: Emerald Idle (`#00E073`), Neon Purple Thinking (`#BF5AF2`), Electric Cyan Working (`#00F0FF`), Bright Emerald Done (`#34D399`).
  - `matrix`: Matrix Green Idle (`#00FF41`), Deep Code Thinking (`#008F11`), Neon Lime Working (`#00FF66`), Bright Phosphor Done (`#39FF14`).
  - `sunset`: Amber Warm Idle (`#FFB800`), Hot Pink Thinking (`#FF007A`), Vivid Orange Working (`#FF6B00`), Electric Cyan Done (`#00F0FF`).
- **Resilience**: If the configuration file is missing or invalid JSON, automatically uses built-in default constants without crashing.

---

### D. Interactive Action Controls (Drop-Down Card)
- When the island expands to `380 × 74 pt`:
  - **Clickable File Detail**: Clicking the file path or an inline folder icon triggers `NSWorkspace.shared.open(URL(fileURLWithPath: path))` to immediately view the file.
  - **Emergency Abort Action**: A subtle neon red pill button (`ABORT` / 🛑) appears during `working`/`thinking` states. Clicking it touches `/tmp/antigravity-abort.signal` or logs an interposition notice.

---

## 3. Screen Layout & Visual Wireframe

```
IDLE MODE (Flush on Notch - 185x34 pt):
┌─────────────────────────────────┐
│              [•]                │  <-- Glowing Neon Dot & Subtle Bottom Lip
└─────────────────────────────────┘

EXPANDED CARD (Drop-Down - 380x74 pt):
┌─────────────────────────────────────────────────────────┐
│ (Hardware Notch Area - Y: 0...32pt)                     │
├─────────────────────────────────────────────────────────┤
│ [🟢] ANTIGRAVITY • STEP #4 • EDITING FILE    [|||| EQ]  │
│      src/main.swift [📂 Open]               [🛑 Abort]  │
└─────────────────────────────────────────────────────────┘
```

---

## 4. Verification & Testing Strategy

1. **Compilation & Syntax**:
   - Run `swiftc -O src/main.swift -o /tmp/AntigravityHUD` to ensure zero compilation warnings or errors under Swift 6.
2. **Mock State Injection**:
   - Write structured mock JSON to `/tmp/antigravity-status.json` with file paths and commands to test visual label formatting and layout stability.
3. **Audio-Haptic Validation**:
   - Trigger state changes and confirm trackpad haptic pulse and completion sound execution.
4. **Binary Packaging**:
   - Execute `bash build.sh` to package `build/AntigravityHUD.app` and DMG release.
