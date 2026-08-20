# 🛠️ Antigravity HUD Development & Contribution Guide

This guide covers local environment setup, live debugging workflows, release compilation, and architecture guidelines for contributing to **Antigravity HUD**.

---

## 1. Prerequisites

- **macOS**: macOS 12.0 (Monterey) or later (macOS 14 Sonoma & macOS 15 Sequoia recommended).
- **Architecture**: Apple Silicon (`arm64`) or Intel (`x86_64`).
- **Toolchain**:
  - Xcode Command Line Tools (`xcode-select --install`) with `swiftc` compiler.
  - Python 3 with `Pillow` (for icon generation): `pip3 install pillow`.
  - Node.js & `pnpm` (optional, for package manager scripts).
  - GitHub CLI (`gh`) for automated releases.

---

## 2. Local Development Workflow

### Quick Compilation & Run
To compile the single-file native Swift binary and launch it immediately:
```bash
# Build and run directly
swiftc -O src/main.swift -o /tmp/AntigravityHUD
/tmp/AntigravityHUD
```

### Live Reloading / Testing during Development
```bash
# Recompile and restart cleanly
swiftc -O src/main.swift -o /tmp/AntigravityHUD && killall AntigravityHUD 2>/dev/null || true
/tmp/AntigravityHUD &
```

### Testing Dynamic State Injection Manually
You can test HUD state transitions without waiting for AI Agent logs by writing mock states directly to `/tmp/antigravity-status.json`:

```bash
# Test 'thinking' state
echo '{"state":"thinking","event":"UserInput"}' > /tmp/antigravity-status.json

# Test 'working' state with tool action
echo '{"state":"working","event":"replace_file_content"}' > /tmp/antigravity-status.json

# Test 'done' state
echo '{"state":"done","event":"ResponseGenerated"}' > /tmp/antigravity-status.json

# Test 'idle' standby
echo '{"state":"idle","event":"Standby"}' > /tmp/antigravity-status.json
```

---

## 3. Building Production Release & DMG

Run the automated build script:
```bash
bash build.sh
```

This will:
1. Clean previous build artifacts.
2. Compile the high-performance native Swift binary with `-O` optimizations.
3. Bundle `Info.plist` and `AppIcon.icns` into `build/AntigravityHUD.app`.
4. Stage a `/Applications` symlink.
5. Package `build/AntigravityHUD-v1.0.0.dmg` ready for distribution.

---

## 4. Coding Standards & Guidelines

1. **Zero External Framework Dependencies**:
   - Keep the codebase lightweight, blazing fast, and self-contained using pure Swift + AppKit + QuartzCore / CoreAnimation.
2. **Deterministic Memory & Thread Safety**:
   - UI updates and AppKit frame changes must be dispatched onto `DispatchQueue.main`.
   - Polling and disk I/O should execute asynchronously with minimal CPU cycles (target `< 0.2%` CPU usage during standby).
3. **Display Non-Intrusiveness**:
   - Do not display standard window chrome, titlebars, shadows, or Dock icons (`LSUIElement = true`).
   - Respect user focus: `canBecomeKey` and `canBecomeMain` should always return `false`.

---

## 5. Future Roadmap & Ideas

- [ ] **Multi-Monitor Fallback**: Auto-detect non-notch external displays and render a centered floating top pill.
- [ ] **Custom Neon Color Schemes**: User-configurable color themes via JSON configuration (`~/.config/antigravity-hud/theme.json`).
- [ ] **Audio Feedback (Optional Chimes)**: Optional subtle sound chimes on task completion.
- [ ] **Token Usage Meter**: Display real-time session tokens and cost in the expanded drop-down card.
