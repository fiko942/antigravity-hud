# Specification: Matrix Terminal Theme Overhaul

## 1. Overview & Objective
Transform the **Matrix Terminal** theme in Antigravity HUD into an authentic, mind-blowing cyberpunk terminal experience. It integrates real-time digital rain stream rendering, animated text decryption (scramble effect), a blinking terminal block cursor (`█`), and CRT phosphor green styling.

---

## 2. Architecture & Components

```
┌────────────────────────────────────────────────────────┐
│               NotchIslandContentView                   │
│  ┌──────────────────────────────────────────────────┐  │
│  │ MatrixRainLayer (Cascading Green Code Stream)    │  │
│  └──────────────────────────────────────────────────┘  │
│  ┌─────────────────┐  ┌───────────────────────────┐  │
│  │ > SYS://AGY.LOG │  │ Decrypted Text + Cursor █ │  │
│  └─────────────────┘  └───────────────────────────┘  │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Matrix Bracket Crosshair Contours [       ]      │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────┘
```

### A. `MatrixRainLayer.swift` (`src/UI/MatrixRainLayer.swift`)
- **Purpose**: Render subtle cascading green glyph streams (`0`, `1`, `X`, `7`, `F`, `A`, `Z`, `%`) in the background of the notch when in active states (`working` / `thinking`).
- **Performance**: Uses lightweight CoreAnimation / CoreText text layers with randomized fall speeds and alpha gradients, paused during `idle` to ensure 0% CPU consumption.

### B. Text Decryption & Scramble Animator (`NotchIslandContentView.swift`)
- **Behavior**: When a new step/activity is received in Matrix theme:
  - The detail string cycles through random matrix glyphs for ~250ms with step-by-step character settling.
  - Adds a blinking cursor `█` at the end of the text.

### C. Bracket Crosshairs & Terminal Syntax
- **Header Format**: Formatted with terminal prefix: `> SYS://AGY.KERNEL [WORKING]`.
- **Corner Brackets**: Crisp, high-contrast corner brackets `[ ]` with glowing phosphor green `#00FF41`.
- **Equalizer**: Phosphor green digital audio bars with sharp rectangular caps.

---

## 3. Implementation Plan Breakdown

1. **`src/UI/MatrixRainLayer.swift`**:
   - Create the animated matrix rain layer component.
2. **`src/UI/NotchIslandContentView.swift`**:
   - Integrate `MatrixRainLayer`.
   - Add text scramble/decryption helper and terminal blinking cursor timer.
   - Apply terminal syntax formatting for Matrix theme.
3. **`src/Themes/ThemeStyle.swift` & `ThemeManager.swift`**:
   - Add flag `hasMatrixRain` or specialized theme capabilities.
4. **Verification & Build**:
   - Recompile with `bash build.sh`, install to `/Applications/AntigravityHUD.app`, restart live, and test live state transitions.
