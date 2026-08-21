# 📐 Antigravity HUD Architecture

This document describes the internal engineering design of **Antigravity HUD**, how it integrates directly with macOS hardware notch geometry, AppKit window layers, and the Antigravity AI Agent real-time brain stream.

---

## 1. Hardware Notch Geometry & Display Alignment

MacBook Liquid Retina XDR displays feature physical camera notches at the top center of the screen:
- **Screen Bounds (Typical 14" / 16")**: `1470 × 956` points (scaled) / native Retina.
- **Physical Notch Cutout Width**: `179.0pt` (centered at `X = midX = 735.0`).
- **Physical Notch Cutout Height**: `32.0pt` to `34.0pt` (`Y = 924.0...956.0`).

### Coordinate System & Window Level
- **Coordinate Anchoring**: The custom `NSView` sets `override var isFlipped: Bool { true }` so that `(0, 0)` refers to the top-left edge of the window at the top bezel.
- **Window Layering**: Standard `NSWindow.Level.floating` is overridden to `NSWindow.Level(rawValue: 102)` (above system Menu Bar items and auxiliary window layers) so that the HUD properly renders on top of the notch area without macOS pushing it below the menu bar.
- **Constraint Override**: `override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect` returns `frameRect` unchanged, bypassing AppKit's automatic menu bar collision pushdown.

---

## 2. Solid OLED Black Rendering (`drawRect`)

To prevent macOS compositor blending and transparency bleed-through over underlying Menu Bar items (such as `File`, `Edit`, `Terminal`, `Window`, `Help`, and status menus):
- The content view overrides `func draw(_ dirtyRect: NSRect)`.
- It executes `NSBezierPath.fill()` with `NSColor.black.setFill()`, drawing 100% solid, non-transparent pixels directly into the WindowServer backing store.
- Glowing neon contour borders are drawn with high-precision anti-aliased Bézier paths matching the status theme color.

---

## 3. Dual Interaction State Machine

```mermaid
stateDiagram-v2
    [*] --> IdleCollapsed: App Launch

    state IdleCollapsed {
        [*] --> CompactNotch: 185px x 34px (Subtle Emerald Rim)
    }

    state IdleHovered {
        [*] --> DropDownCard: 380px x 74px (Status Ready)
    }

    state ActivePulsing {
        [*] --> CompactActiveNotch: 185px x 34px (Neon Purple / Cyan Rim)
    }

    state ActiveExpanded {
        [*] --> FullActionCard: 380px x 74px (Action Details + Equalizer)
    }

    IdleCollapsed --> IdleHovered: Cursor Enters Notch Area
    IdleHovered --> IdleCollapsed: Cursor Exits Notch Area

    IdleCollapsed --> ActivePulsing: Agent Event (Thinking / Working)
    IdleHovered --> ActivePulsing: Agent Event (Thinking / Working)

    ActivePulsing --> ActiveExpanded: User Click on Notch
    ActiveExpanded --> ActivePulsing: User Click on Notch

    ActivePulsing --> IdleCollapsed: Agent Completes Task (Done -> Idle)
    ActiveExpanded --> IdleCollapsed: Agent Completes Task (Done -> Idle)
```

---

## 4. Single-Instance Mutex & Auto-LaunchAgent

1. **Kernel Mutex**:
   - Uses `flock(fd, LOCK_EX | LOCK_NB)` on `/tmp/antigravity-hud.lock`.
   - Guaranteed zero duplicate processes even if invoked multiple times.
2. **Auto-LaunchAgent**:
   - On launch, checks for existence of `~/Library/LaunchAgents/com.google.antigravity.hud.plist`.
   - If missing, automatically generates the plist pointing to `/Applications/AntigravityHUD.app/Contents/MacOS/AntigravityHUD` and registers via `launchctl load -w`.

---

## 5. Native SQLite3 Storage Architecture

- **Engine**: SQLite3 in **Write-Ahead Logging (WAL)** mode.
- **Database Path**: `~/.config/antigravity-hud/antigravity_hud.sqlite3`.
- **Concurrency & Latency**: Synchronous writes `< 0.1ms` without blocking main UI thread.
- **Schema**:
  ```sql
  CREATE TABLE IF NOT EXISTS app_settings (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );
  ```
- **Atomicity**: Atomic disk commits guarantee settings persist through application restarts and macOS system power cycles.

---

## 6. Dynamic Notch Dimension Morphing & Live Demo Pipeline

- **Continuous Dimension Bounds**:
  - `expandedWidth`: `280.0pt ... 560.0pt` (default `380.0pt`)
  - `expandedHeight`: `32.0pt ... 80.0pt` (default `46.0pt`)
  - `compactWidth`: `140.0pt ... 260.0pt` (default `185.0pt`)
  - `compactHeight`: `0.0pt ... 20.0pt` (default `2.0pt`)
- **Live Hardware Notch Demo Mode**:
  - Moving expanded/compact sliders triggers `SettingsManager.shared.requestPreviewDemo()`.
  - Floating panel instantly adapts frame size live on screen.
  - Automatically reverts to real AI status after `2.0s` inactivity timeout via non-blocking debounce timer.
- **Interactive Live Preview Canvas**:
  - `NotchPreviewBoxView` renders miniature MacBook bezel with dynamic contour Bezier paths scaled at `0.72x` inside Preferences.
