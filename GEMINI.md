# Antigravity HUD - Agent Instructions

## Mandatory Live Build & Install Protocol
Whenever any code or resource is modified in this repository:
1. You MUST execute `bash build.sh` to generate the updated `build/AntigravityHUD.app`.
2. You MUST replace `/Applications/AntigravityHUD.app` with the fresh build.
3. You MUST restart the running process:
   ```bash
   killall AntigravityHUD 2>/dev/null || true && rm -rf /Applications/AntigravityHUD.app && cp -R build/AntigravityHUD.app /Applications/ && open /Applications/AntigravityHUD.app
   ```
4. Verify the process is running live via `pgrep -fl AntigravityHUD`.
