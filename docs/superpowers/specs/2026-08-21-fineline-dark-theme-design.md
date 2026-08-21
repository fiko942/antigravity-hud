# Fineline Dark (Celestial Ink) Theme Specification

## Overview
**Fineline Dark** is a new theme for Antigravity HUD inspired by minimalist fine-line & single-needle tattoo art. It features ultra-clean 1.0pt hairline contours, celestial constellation micro-dots, delicate orbital ring animations, and high-fashion editorial typography (`Optima` + `Avenir Light`).

---

## Visual Architecture & Components

### 1. Shape & Contour (`ThemeShapeType.finelineConstellation`)
- **Background**: Deep Onyx Matte Black (`#0A0A0C`).
- **Contour Stroke**: Single-line 1.0pt hairline stroke with smooth superellipse curve (`cornerRadius: 16pt` when expanded, `7pt` when compact).
- **Constellation Accents**: Two subtle micro-dots (diameter 2.5pt) positioned at the left and right baseline curves, evoking constellation star charts and fine-line needle art.

### 2. Beacon & Pulse (`ThemeBeaconStyle.finelineCelestialOrbit`)
- **Center Beacon**: Pin-sharp 4pt micro-needle star point.
- **Pulse Effect**: Dual concentric hairline rings (`borderWidth: 0.75pt`) that expand and fade smoothly outward, mimicking orbital ripple waves and tattoo ink resonance.

### 3. Palette (`ThemePalette.moonlightCelestial`)
- **Idle**: Pearl White / Ivory Ink (`#F0EFEA`) with subtle celestial halo.
- **Thinking**: Mystic Nebula Lavender (`#A78BFA`).
- **Working**: Celestial North Star Cyan (`#38BDF8`).
- **Done**: Aurora Star Gold (`#FBBF24`).

### 4. Typography
- **Header Label**: `Optima-Bold` (Size 9.0pt, letter-spaced, calligraphic modern elegance).
- **Detail Label**: `Avenir-Light` (Size 11.5pt, clean crisp humanistic geometry).

### 5. Equalizer & Menu Button
- **Equalizer**: Ultra-slim 1.0pt hairline animated frequency bars.
- **Menu Button (⋮)**: Thin circular border with 0.8pt stroke.

---

## File Changes Overview

1. **`src/Themes/ThemeDefinition.swift`**:
   - Add `.finelineConstellation` to `ThemeShapeType`.
   - Add `.finelineCelestialOrbit` to `ThemeBeaconStyle`.
2. **`src/Themes/ThemeManager.swift`**:
   - Register the `fineline` theme in `availableThemes`.
3. **`src/UI/NotchIslandContentView.swift`**:
   - Implement `draw(_:)` bezier path and constellation accents for `.finelineConstellation`.
   - Implement orbital ripple pulse in `startPulseAnimation()` for `.finelineCelestialOrbit`.
4. **`src/UI/NotchPreviewBoxView.swift`**:
   - Mirror the `.finelineConstellation` rendering in the Preferences live preview box.
5. **`README.md` & `docs/ARCHITECTURE.md`**:
   - Document the new Fineline Dark theme in the theme roster.

---

## Verification Plan

1. Compile via `bash build.sh`.
2. Deploy to `/Applications/AntigravityHUD.app` and restart.
3. Switch to **Fineline Dark** in Preferences and verify:
   - Hairline 1.0pt border and celestial micro-dots.
   - Smooth orbital ripple pulse animation across Idle, Thinking, Working, and Done states.
   - Optima + Avenir Light typography rendering.
   - Persistence in SQLite database upon restart.
