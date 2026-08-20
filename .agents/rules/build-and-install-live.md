---
trigger: always_on
---

# Mandatory Live Build & Install Rule

Whenever any modification is made to the codebase (e.g. `src/main.swift`, resources, or configs):
1. Immediately recompile and build the production bundle:
   ```bash
   bash build.sh
   ```
2. Replace `/Applications/AntigravityHUD.app` with the new build and restart the live process:
   ```bash
   killall AntigravityHUD 2>/dev/null || true
   rm -rf /Applications/AntigravityHUD.app
   cp -R build/AntigravityHUD.app /Applications/
   open /Applications/AntigravityHUD.app
   ```
3. Confirm the new instance is running via `pgrep -fl AntigravityHUD`.
4. Never leave the user with unbuilt or uninstalled changes.
