# Antigravity HUD Developer & Agent Guide

This repository contains the native macOS Dynamic Notch Island application for Google Antigravity AI Agent.

## Core Rules & Architecture
1. **Source Code**: Modular Swift architecture organized in `src/Core/` (Mutex, Sensory, LaunchAgent), `src/Themes/` (Styles & Manager), `src/Brain/` (Watcher & Activity), `src/UI/` (Notch Panel, Island View, Equalizer & Glitch), `src/App/` (AppDelegate), and `src/main.swift` (Entry Point).
2. **Build & Live Installation Protocol (MANDATORY)**:
   - Whenever any code or resource is modified, you MUST automatically run `bash build.sh`, install it into `/Applications/AntigravityHUD.app`, restart the running application (`killall AntigravityHUD 2>/dev/null || true && open /Applications/AntigravityHUD.app`), and verify with `pgrep -fl AntigravityHUD` so changes are immediately live on the user's system.
3. **Documentation Directory**:
   - `docs/ARCHITECTURE.md`: Geometric alignment, layer levels, and state machine.
   - `docs/TECHNICAL_SPEC.md`: Complete display matrices, coordinate formulas, and streaming protocol.
   - `docs/DEVELOPMENT_GUIDE.md`: Build steps, live debugging, and mock state injection.
   - `docs/SUPERPOWERS_INTEGRATION.md`: Agent rules and systematic debugging protocols.
