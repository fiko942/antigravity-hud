# 🔬 Antigravity HUD Technical Specification

This document provides an in-depth technical breakdown of the **Antigravity HUD** system architecture, macOS WindowServer integration, hardware notch display geometry, CoreGraphics/AppKit rendering pipeline, and real-time log ingestion protocol.

---

## 1. Hardware Notch Display Geometry & Alignment

MacBook Liquid Retina XDR displays feature physical hardware camera cutouts embedded in the top bezel.

### Display Metrics Specification
| Display Model | Scaled Resolution | Native Retina Bounds | Physical Notch Cutout Width | Notch Height | Safe Area Top Inset |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **14" MacBook Pro (M1/M2/M3/M4)** | `1512 × 982` pt | `3024 × 1964` px | `179.0pt` ($X = 666.5 \dots 845.5$) | `32.0pt` | `32.0pt` (`safeAreaInsets.top`) |
| **16" MacBook Pro (M1/M2/M3/M4)** | `1728 × 1117` pt | `3456 × 2234` px | `179.0pt` ($X = 774.5 \dots 953.5$) | `32.0pt` | `32.0pt` (`safeAreaInsets.top`) |
| **13.6" / 15.3" MacBook Air (M2/M3)** | `1470 × 956` pt | `2940 × 1912` px | `179.0pt` ($X = 645.5 \dots 824.5$) | `32.0pt` | `32.0pt` (`safeAreaInsets.top`) |

### Hardware Coordinate Calculation
In macOS AppKit (bottom-left origin coordinate system):
$$\text{screenTop} = \text{screen.frame.maxY}$$
$$\text{screenMidX} = \text{screen.frame.midX}$$
$$\text{xPos} = \text{screenMidX} - \frac{\text{width}}{2}$$
$$\text{yPos} = \text{screenTop} - \text{height}$$

The custom `NSView` sets `override var isFlipped: Bool { true }` so that internal child elements are anchored top-down from $(0, 0)$ at the top screen bezel.

---

## 2. macOS Window Layering & Constraint Overrides

### Window Level Overriding
Standard macOS floating panels (`NSWindow.Level.floating` = Level 3) are rendered **behind** the macOS system Menu Bar (`NSWindow.Level.mainMenu` = Level 24) and are pushed downwards by AppKit's automatic window boundary constraint manager.

To position the Dynamic Island directly on top of the physical notch:
```swift
self.level = NSWindow.Level(rawValue: 102) // Level 102 sits above Menu Bar and Screen Bezels
```

### Bypassing AppKit Frame Constraints
By default, `NSWindow.constrainFrameRect(_:to:)` prevents windows from overlapping the Menu Bar rect ($Y > 924$). We override this behavior:
```swift
override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
    return frameRect // Bypass automatic boundary pushdown
}
```

---

## 3. Solid OLED Pure Black Rendering Pipeline (`drawRect`)

Transparent borderless panels in macOS AppKit can cause sublayer alpha compositing artifacts (such as desert wallpaper or menu text like `Terminal`, `Window`, `Help` bleeding through `CALayer` backgrounds).

To guarantee **100% solid opacity with zero ghosting**:
```swift
override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)

    let w = bounds.width
    let h = bounds.height
    let cornerRadius: CGFloat = isExpandedMode ? 18.0 : 8.0

    let path = NSBezierPath()
    path.move(to: NSPoint(x: 0, y: 0))
    path.line(to: NSPoint(x: w, y: 0))
    path.line(to: NSPoint(x: w, y: h - cornerRadius))
    path.appendArc(withCenter: NSPoint(x: w - cornerRadius, y: h - cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: 90, clockwise: false)
    path.line(to: NSPoint(x: cornerRadius, y: h))
    path.appendArc(withCenter: NSPoint(x: cornerRadius, y: h - cornerRadius), radius: cornerRadius, startAngle: 90, endAngle: 180, clockwise: false)
    path.close()

    // Render 100% solid pure black directly into WindowServer backing store
    NSColor.black.setFill()
    path.fill()

    // Stroke high-precision anti-aliased neon border
    let glowPath = NSBezierPath()
    if isExpandedMode {
        glowPath.move(to: NSPoint(x: 0, y: max(0, h - cornerRadius - 4)))
        glowPath.line(to: NSPoint(x: 0, y: h - cornerRadius))
        glowPath.appendArc(withCenter: NSPoint(x: cornerRadius, y: h - cornerRadius), radius: cornerRadius, startAngle: 180, endAngle: 90, clockwise: true)
        glowPath.line(to: NSPoint(x: w - cornerRadius, y: h))
        glowPath.appendArc(withCenter: NSPoint(x: w - cornerRadius, y: h - cornerRadius), radius: cornerRadius, startAngle: 90, endAngle: 0, clockwise: true)
        glowPath.line(to: NSPoint(x: w, y: max(0, h - cornerRadius - 4)))
    } else {
        glowPath.move(to: NSPoint(x: 10, y: h - 1.5))
        glowPath.line(to: NSPoint(x: w - 10, y: h - 1.5))
    }

    glowPath.lineWidth = isExpandedMode ? 1.8 : 2.0
    themeColor.withAlphaComponent(isExpandedMode ? 0.9 : 0.85).setStroke()
    glowPath.stroke()
}
```

## 4. Multi-Theme Geometry & Sensory Pipeline (7 Themes)

```
┌─────────────────────────────────────────────────────────────┐
│                      ANTIGRAVITY HUD                        │
├───────────────────┬───────────────────┬─────────────────────┤
│ Theme ID          │ Geometry & Beacon │ Equalizer & Chime   │
├───────────────────┼───────────────────┼─────────────────────┤
│ macos-light       │ Porcelain Drop    │ Classic Wave / Glass│
│ general           │ Superellipse Glass│ Classic Wave / Glass│
│ cyberpunk         │ 45° Mecha Chamfer │ Cyber Blocks / Funk │
│ matrix            │ Terminal Bracket  │ Binary Scan / Morse │
│ sunset            │ Continuous Pill   │ Synth Pillars / Hero│
│ dracula           │ Gothic Bevels     │ Spikes / Basso      │
│ fineline          │ Hairline & Stars  │ Needle / Tink       │
└───────────────────┴───────────────────┴─────────────────────┘
```

---

## 5. Real-Time Brain Streaming Protocol

1. **Global Scanning (`~/.gemini/antigravity-ide/brain/`)**:
   - `BrainWatcher.swift` polls every `100ms` for updated session transcripts.
   - Parses the latest trajectory steps (`type: PLANNER_RESPONSE`, `USER_INPUT`, `SYSTEM`) and extracts tools / task states (`working`, `thinking`, `done`, `idle`).
2. **Offset Seeking Protocol**:
   - Ingests the last `16KB` of the JSONL file or seeks incrementally using `FileHandle`.
   - Streaming JSONL records mapped:
     - `USER_INPUT` $\rightarrow$ State: `thinking`, Event: `UserInput`
     - `PLANNER_RESPONSE` with `tool_calls` $\rightarrow$ State: `working`, Event: `<tool_name>`
     - `PLANNER_RESPONSE` without `tool_calls` $\rightarrow$ State: `done` (auto-resets to `idle` after 3.5s).
3. **Event Dispatching**:
   - Dispatches parsed `AgentActivity` to `AppDelegate` and `NotchIslandContentView` on the Main Dispatch Queue.
   - Triggers theme-specific audio chimes and haptic patterns via `SensoryManager`.

---

## 6. Native SQLite3 Storage Protocol

All persistent configurations are managed through `~/.gemini/antigravity-hud/settings.sqlite` via `SQLiteStorageManager.swift`:
- `active_theme_id`
- `active_task_display_mode`
- `expanded_width`, `expanded_height`
- `compact_width`, `compact_height`
- `idle_hover_expands`, `sound_enabled`, `haptics_enabled`, `launch_at_login`

