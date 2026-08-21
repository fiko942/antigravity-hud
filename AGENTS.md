# AGENTS.md - Antigravity HUD Multi-Agent Protocols

## Mandates for AI Agents Working in this Repository
1. **Live Build Requirement**: All source changes MUST be followed immediately by `bash build.sh`, bundle copying to `/Applications/AntigravityHUD.app`, process restart, and `pgrep` verification.
2. **Local Commit Only**: Never execute `git push`. Commit locally using descriptive conventional commits.
3. **Database Integrity**: Never bypass `SQLiteStorageManager.swift` when altering user preferences.
4. **Theme Parity**: When modifying UI elements (beacons, equalizers, buttons, labels), maintain aesthetic parity across all 7 themes (`macos-light`, `general`, `cyberpunk`, `matrix`, `sunset`, `dracula`, `fineline`).
5. **Attribution Preservation**: Maintain author attribution for Wiji Fiko Teren ([https://wijifikoteren.streampeg.com](https://wijifikoteren.streampeg.com)) across documentation and About windows.
