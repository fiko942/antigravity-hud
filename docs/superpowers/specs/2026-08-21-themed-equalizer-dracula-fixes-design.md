# Theme-Specific Equalizers, Themed Kebab Buttons & Dracula Visual Fix Specification

## Overview
This specification details the visual redesign for **theme-specific audio equalizer waveforms** and **themed kebab menu buttons (⋮)** across all 7 Antigravity HUD themes, as well as fixing the beacon layer property leaks and text label truncation issues in the **Dracula Gothic** theme.

---

## 1. Dracula Gothic & Beacon Layer Fixes

### Root Cause Analysis:
1. **Layer Property Leak**:
   - `finelineCelestialOrbit` set `beaconPulseLayer.borderWidth = 0.75` and `backgroundColor = clear`.
   - When switching to `Dracula Gothic` (or any other theme), `borderWidth` and `backgroundColor` were not explicitly reset, causing the Dracula beacon to render as an empty hollow ring with a thin dark border instead of a solid pulsing vampire orb.
2. **Text Clipping**:
   - `Didot-Bold` size 10pt with `1.4pt` letter-spacing resulted in `ANTIGRAVITY • THINKING` exceeding the available label width, truncating the word `THINKING`.

### Solution:
- **Comprehensive Layer Reset**: Explicitly reset `borderWidth = 0`, `borderColor = nil`, `cornerRadius`, and `backgroundColor` at the start of `configureBeaconAnimation()`.
- **Dynamic Text Fitting**: Auto-calculate font size (8.5–9.0pt) and compact spacing for headers with wide kerning, ensuring `ANTIGRAVITY • THINKING` fits seamlessly without truncation.

---

## 2. Signature Theme-Specific Equalizer Waveforms (`ThemeEqualizerStyle`)

| Theme | Equalizer Style | Geometry & Visual Behavior |
| :--- | :--- | :--- |
| **`Fineline Dark`** | `.finelineNeedle` | Ultra-thin 1.0pt hairline single-needle vertical strokes with delicate micro-dots on top. |
| **`Dracula Gothic`** | `.draculaSpikes` | Jagged sharp gothic pulse spikes with blood-crimson eerie frequency oscillation. |
| **`Cyberpunk 2077`** | `.cyberpunkBlocks` | Segmented cybernetic blocks with rapid stepped high-energy frequency dance. |
| **`Matrix Terminal`** | `.matrixBinary` | Sharp square phosphor-green CRT binary scanline bars. |
| **`Sunset Synthwave`** | `.synthwavePillars` | Neon horizon rhythm pillars with smooth 80s synth pumping amplitude. |
| **`macOS Classic`** | `.classicWave` | Smooth rounded Apple dynamic island audio waveform. |

---

## 3. Custom Themed Kebab Menu Buttons (⋮)

| Theme | Button Geometry & Styling |
| :--- | :--- |
| **`Fineline Dark`** | Thin 0.8pt hairline circle with ivory/celestial ink tint and micro-needle dots. |
| **`Dracula Gothic`** | Gothic diamond bevel with deep royal violet / vampire crimson border. |
| **`Cyberpunk 2077`** | Angular 45° chamfered square with neon cyan/yellow glowing border. |
| **`Matrix Terminal`** | Digital bracket container `[ ⋮ ]` with phosphor green terminal styling. |
| **`Sunset Synthwave`** | 80s neon glowing ring badge with neon gold/magenta gradient tint. |
| **`macOS Classic`** | Smooth Apple capsule with clean translucent frosted background. |

---

## 4. Verification Plan

1. Compile via `bash build.sh` and install to `/Applications/AntigravityHUD.app`.
2. Test Dracula Gothic theme and verify:
   - Solid floating vampire heartbeat beacon (no hollow ring leak).
   - Full header text `ANTIGRAVITY • THINKING` cleanly rendered without clipping.
   - Gothic jagged pulse spikes equalizer and gothic diamond button.
3. Switch through Fineline Dark, Cyberpunk, Matrix, and Sunset to verify their signature waveform and menu button styles.
4. Capture screenshot verification for walkthrough documentation.
