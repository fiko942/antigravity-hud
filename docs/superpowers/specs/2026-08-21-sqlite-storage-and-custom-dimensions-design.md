# Design Specification: SQLite Persistence Engine & Custom Notch Dimension Sliders with Live Preview

## 1. Overview
Antigravity HUD currently persists configuration across JSON files. To ensure 100% reliable ACID persistence across app restarts and system reboots, this specification introduces:
1. **`SQLiteStorageManager`**: A native SQLite3 persistence layer utilizing macOS Darwin's built-in `libsqlite3` with zero external dependencies and near-zero memory footprint (<100 KB RAM).
2. **Custom Dimension Sliders**: Controls in Preferences for customizing **Expanded Width** (280–560 pt), **Expanded Height** (32–80 pt), and **Compact Width** (140–260 pt).
3. **Live Interactive Preview Box**: A real-time preview component in the Preferences window allowing users to toggle between **Open / Expanded** and **Closed / Compact** states while dynamically sliding dimensions.

---

## 2. Architecture & Components

```
+-----------------------------------------------------------------------+
|                         Preferences Window                            |
| +-------------------------------------------------------------------+ |
| | LiquidPillTab: [ ⚙️ Settings ]   [ ℹ️ About ]                       | |
| +-------------------------------------------------------------------+ |
| | [ Dimension Sliders ]        [ Live Interactive Notch Preview ]    | |
| | - Expanded Width (280-560pt) |   [ 📌 Open ]  [ 🔒 Closed ]       | |
| | - Expanded Height (32-80pt)  |   +------------------------------+ | |
| | - Compact Width (140-260pt)  |   |  > SYS://AGY.KERNEL [READY]  | | |
| |                              |   |  Standby for prompt  ...     | | |
| |                              |   +------------------------------+ | |
| +-------------------------------------------------------------------+ |
+-----------------------------------------------------------------------+
                                  | (Slider / Toggle Events)
                                  v
+-----------------------------------------------------------------------+
|                          SettingsManager                              |
|   - expandedWidth: CGFloat (default 380.0)                            |
|   - expandedHeight: CGFloat (default 46.0)                            |
|   - compactWidth: CGFloat (default 185.0)                             |
|   - activeTheme: String                                               |
|   - activeTaskDisplayMode: ActiveTaskDisplayMode                      |
|   - soundEnabled / hapticsEnabled / launchAtLogin                     |
+-----------------------------------------------------------------------+
                                  | (ACID Transactions)
                                  v
+-----------------------------------------------------------------------+
|                       SQLiteStorageManager                            |
|   - Path: ~/.config/antigravity-hud/antigravity_hud.sqlite3          |
|   - Table: kv_store (key TEXT PRIMARY KEY, value TEXT, updated_at)    |
|   - Mode: WAL (Write-Ahead Logging) for atomic, non-blocking I/O      |
|   - Memory: < 100 KB, Zero external dependencies                      |
+-----------------------------------------------------------------------+
                                  |
                                  v
+-----------------------------------------------------------------------+
|                    Live Floating Notch (AppDelegate)                  |
|   - Immediately resizes & morphs smoothly to new dimensions           |
+-----------------------------------------------------------------------+
```

---

## 3. Data Schema & SQLite Implementation

- **Database File**: `~/.config/antigravity-hud/antigravity_hud.sqlite3`
- **Schema**:
  ```sql
  CREATE TABLE IF NOT EXISTS app_settings (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  );
  PRAGMA journal_mode = WAL;
  PRAGMA synchronous = NORMAL;
  ```
- **Stored Keys**:
  - `active_theme`: String (e.g. `general`, `macos-light`, `cyberpunk`, `matrix`, `sunset`, `dracula`)
  - `active_task_display_mode`: String (`clickOnly`, `hoverExpands`, `alwaysExpanded`)
  - `idle_hover_expands`: Bool (`true`/`false`)
  - `sound_enabled`: Bool (`true`/`false`)
  - `haptics_enabled`: Bool (`true`/`false`)
  - `launch_at_login`: Bool (`true`/`false`)
  - `compact_width`: Double (default: `185.0`, min: `140.0`, max: `260.0`)
  - `expanded_width`: Double (default: `380.0`, min: `280.0`, max: `560.0`)
  - `expanded_height`: Double (default: `46.0`, min: `32.0`, max: `80.0`)

---

## 4. UI & Interactive Live Preview in Preferences

### Dimensions & Sliders Section:
1. **Expanded Width**:
   - Continuous `NSSlider` (`280...560`, tick marks at `380`).
   - Dynamic label updates: `Width: 380 pt`.
2. **Expanded Height**:
   - Continuous `NSSlider` (`32...80`, tick marks at `46`).
   - Dynamic label updates: `Height: 46 pt`.
3. **Compact Idle Width**:
   - Continuous `NSSlider` (`140...260`, tick marks at `185`).
   - Dynamic label updates: `Compact Width: 185 pt`.

### Live Interactive Preview View (`NotchPreviewBoxView`):
- Embedded canvas displaying the MacBook bezel and the rendered notch using the active theme's styling, fonts, and colors.
- State Toggle: `[ 📌 Open / Expanded ]` vs `[ 🔒 Closed / Compact ]`.
- Live rendering with real-time recalculation as sliders move without memory leaks or heavy allocations.

---

## 5. Memory & Performance Safeguards
1. **Zero-Overhead SQLite**: Single connection handle opened with WAL mode, cached statements, and automatic closing on termination.
2. **Zero-Lag Slider Event Debouncing**: Slider value changes update the preview view instantly at 60fps via layer bounds transform, and write to SQLite with a 150ms trailing debounce or upon mouse release.
3. **Live Sync with Floating Notch**: `AppDelegate` listens to `onSettingsChanged` and smoothly animates the active notch on screen to match new user dimensions.
