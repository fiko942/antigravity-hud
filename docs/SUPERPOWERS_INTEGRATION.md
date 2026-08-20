# ⚡ Antigravity HUD - Superpowers & Agent Integration

This document defines the specialized agent protocols, system rules, memory preservation standards, and systematic debugging methodologies for AI agents maintaining and extending the **Antigravity HUD** repository.

---

## 1. Agent Persona & Design Philosophy

When modifying or extending this codebase, agents must adhere to the following principles:

1. **Aesthetic Excellence (WOW Factor)**:
   - macOS applications must feel premium, native, and futuristic.
   - Smooth CoreAnimation easing (`CAMediaTimingFunction(name: .easeInEaseOut)`), rounded corners, glowing neon borders, and cybernetic equalizer visualizations.
2. **MacBook Hardware Alignment Integrity**:
   - Never hardcode arbitrary screen coordinates that push windows onto the desktop area.
   - Always query `NSScreen.main.frame` and `safeAreaInsets.top` for dynamic notch detection.
3. **Pure AppKit Solidity**:
   - Transparent panels must use `drawRect` native `NSBezierPath` drawing to prevent WindowServer compositor alpha bleeding.

---

## 2. Systematic Debugging Protocol

When encountering unexpected UI rendering, mouse tracking, or window level issues:

### Step 1: Root Cause Investigation
- Trace AppKit event routing: Check `activationPolicy` (`.accessory` apps do not receive standard active-window tracking).
- Verify WindowServer layer level: `NSWindow.Level(rawValue: 102)` sits above menu bar items.
- Check display coordinate origin: Cocoa uses bottom-left origin; `isFlipped = true` flips the local view coordinate system to top-down.

### Step 2: Scientific Testing
- Isolate the smallest variable (e.g. testing mouse location in isolation with `NSEvent.mouseLocation`).
- Avoid guess-and-check loops. Confirm fix before committing.

---

## 3. Memory & Context Preservation

- All architectural decisions must be documented in `docs/ARCHITECTURE.md`.
- All technical specifications and display geometries must be recorded in `docs/TECHNICAL_SPEC.md`.
- Ensure single-instance mutex (`flock` on `/tmp/antigravity-hud.lock`) is preserved to prevent rogue zombie processes.
