# Antigravity HUD - Agent Instructions & Engineering Protocols

## 1. Mandatory Live Build & Install Protocol
Whenever any code or resource is modified in this repository:
1. You MUST execute `bash build.sh` to generate the updated `build/AntigravityHUD.app`.
2. You MUST replace `/Applications/AntigravityHUD.app` with the fresh build.
3. You MUST restart the running process:
   ```bash
   killall AntigravityHUD 2>/dev/null || true && rm -rf /Applications/AntigravityHUD.app && cp -R build/AntigravityHUD.app /Applications/ && open /Applications/AntigravityHUD.app
   ```
4. Verify the process is running live via `pgrep -fl AntigravityHUD`.

## 2. Git Commit & Push Guidelines
- **NEVER push directly to the remote repository**.
- Create clear, structured conventional commits locally (e.g. `feat(...)`, `fix(...)`, `docs(...)`).
- The user will perform `git push` manually when ready.

## 3. Database Persistence & Storage Protocol
- All user configurations, active themes, dimensions, and sensory toggles are stored persistently in SQLite (`~/.gemini/antigravity-hud/settings.sqlite`) via `SQLiteStorageManager.swift` and `SettingsManager.swift`.
- Default installation profile:
  - **Active Theme**: `sunset` (Sunset Synthwave Horizon)
  - **Active Task Mode**: `.hoverExpands`
  - **Expanded Dimensions**: `275 x 44 pt`
  - **Compact Dimensions**: `177 x 6 pt`
  - **All Sensory & Startup Toggles**: Enabled (`idleHoverExpands`, `soundEnabled`, `hapticsEnabled`, `launchAtLogin`).

## 4. Typography & Font Architecture
- Automated font registration engine in `src/Core/FontManager.swift` auto-registers all custom fonts in `Resources/Fonts/` via CoreText in-process APIs (`CTFontManagerRegisterFontURLs`) and synchronizes them to `~/Library/Fonts/`.
- Never hardcode font dependencies without fallback cascades defined in `ThemeStyle.swift`.

## 5. Multi-Theme Geometry & Sensory Catalog (7 Themes)
- **`macos-light`**: Platinum ceramic drop-down, `SF Pro` bold, Siri breathing pulse, `classicWave` equalizer, `Glass` chime.
- **`general`**: Obsidian superellipse glass island, `SF Pro` bold, Siri breathing pulse, `classicWave` equalizer, `Glass` chime.
- **`cyberpunk`**: $45^\circ$ mecha chamfers + active RGB glitch, `Helvetica Neue Condensed Black`, diamond glitch strobe, `cyberpunkBlocks` equalizer, `Funk` chime.
- **`matrix`**: Digital square terminal box + cascading green matrix rain & text decrypt scramble, `Menlo Bold`, cursor binary blink, `matrixBinary` equalizer, `Morse` chime.
- **`sunset`**: 80s continuous pill curve, `Futura Bold`, neon horizon halo rings, `synthwavePillars` equalizer, `Hero` fanfare chime.
- **`dracula`**: Stepped $45^\circ$ gothic micro-bevels with blood-red vampire orb, `Didot Bold` & `Palatino Bold`, vampire double heartbeat, `draculaSpikes` equalizer, `Basso` cathedral chime.
- **`fineline`**: Single-needle tattoo $1.0\text{pt}$ hairline with constellation star dots, `Optima Bold` & `Avenir Light`, celestial orbital ripple, `finelineNeedle` equalizer, `Tink` crystalline chime.

## 6. Author Attribution
- **Author**: Wiji Fiko Teren
- **Portfolio**: [https://wijifikoteren.streampeg.com](https://wijifikoteren.streampeg.com)
- **Saweria**: [https://saweria.co/wijifikoteren](https://saweria.co/wijifikoteren)
- **GitHub**: [https://github.com/fiko942](https://github.com/fiko942)
