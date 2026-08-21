# Automatic Font Manager & Typographical Micro-Styling Specification

## Overview
This specification details the architecture for an **Automatic Font Manager (`FontManager.swift`)** and **Typographical Micro-Styling Engine** for Antigravity HUD. It guarantees that every theme's distinctive font is automatically discovered, registered via CoreText (`CTFontManagerRegisterFontsForURLs`), and optionally installed to `~/Library/Fonts/` without user dialogs or admin prompts, alongside custom letter-spacing (`kern`) and typography rendering.

---

## 1. Automatic Font Manager (`FontManager.swift`)

### Responsibilities:
1. **Bundle Font Registration**:
   - Scans `Bundle.main.resourceURL/Fonts/` and any embedded `.ttf` / `.otf` files.
   - Calls `CTFontManagerRegisterFontsForURLs` with `.process` scope so the application's font subsystem immediately gains access to all custom fonts on startup.
2. **User Font Directory Auto-Sync**:
   - Checks `~/Library/Fonts/`.
   - If any bundled font is missing from the user's font directory, copies it automatically and registers it with `CTFontManagerRegisterFontsForURLs` with `.user` scope.
3. **Safe Font Fallback Pipeline**:
   - Tests PostScript font availability using `NSFont(name:size:)`.
   - If a specific font weight is missing, falls back through a hierarchy of harmonious alternatives before using the system font.

---

## 2. Typographical Micro-Styling Engine (`ThemeStyle.swift`)

### Micro-Styling Rules per Theme:

| Theme ID | Header Font | Header Kern | Detail Font | Detail Kern | Typographical Personality |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`fineline`** | `Optima-Bold` | `+1.6 pt` | `Avenir-Light` | `+0.5 pt` | Minimalist luxury tattoo editorial spacing & crisp calligraphic elegance |
| **`cyberpunk`** | `HelveticaNeue-CondensedBlack` | `-0.2 pt` | `Avenir-Black` | `+0.1 pt` | Ultra-dense punchy sci-fi mecha titles |
| **`matrix`** | `Menlo-Bold` | `+0.8 pt` | `Menlo-Bold` | `+0.4 pt` | Monospaced digital phosphor green terminal telemetry |
| **`sunset`** | `Futura-Bold` | `+1.2 pt` | `Futura-Medium` | `+0.4 pt` | Authentic 80s retro synthwave horizon aesthetic |
| **`dracula`** | `Didot-Bold` | `+1.4 pt` | `Palatino-Bold` | `+0.3 pt` | Dramatic Victorian gothic serif contrast |
| **`general`** / **`macos-light`** | System Bold | `+0.2 pt` | System Semibold | `0.0 pt` | Native macOS Ventura/Sonoma precision |

### Attributed String Helpers:
- `ThemeDefinition.makeAttributedHeader(text:color:size:) -> NSAttributedString`
- `ThemeDefinition.makeAttributedDetail(text:color:size:) -> NSAttributedString`

---

## 3. UI Layer Integration

1. **`NotchIslandContentView.swift`**:
   - Uses `attributedStringValue` for `headerLabel` and `detailLabel`.
   - Properly aligns baseline offsets and ensures text truncation preserves style.
2. **`NotchPreviewBoxView.swift`**:
   - Updates CATextLayers and attributed strings in the live preview canvas to accurately reflect font changes and kerning.

---

## 4. Verification Plan

1. Run font registration test validating CoreText registration.
2. Build via `bash build.sh` and deploy to `/Applications/AntigravityHUD.app`.
3. Switch through all 7 themes in Preferences and verify distinct fonts and kerning live.
4. Capture screenshot verification.
