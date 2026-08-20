#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"
APP_NAME="AntigravityHUD.app"
APP_DIR="${BUILD_DIR}/${APP_NAME}"
DMG_NAME="AntigravityHUD-v1.1.0.dmg"
DMG_PATH="${BUILD_DIR}/${DMG_NAME}"
DMG_STAGING="${BUILD_DIR}/dmg_staging"

echo "==> Cleaning previous build artifacts..."
rm -rf "${BUILD_DIR}"
mkdir -p "${APP_DIR}/Contents/MacOS"
mkdir -p "${APP_DIR}/Contents/Resources"
mkdir -p "${DMG_STAGING}"

echo "==> Compiling Swift native binary from modular sources..."
SWIFT_FILES=$(find "${SCRIPT_DIR}/src" -name "*.swift" | sort)
swiftc -O ${SWIFT_FILES} \
    -o "${APP_DIR}/Contents/MacOS/AntigravityHUD"

echo "==> Copying App metadata and resources..."
cp "${SCRIPT_DIR}/Resources/Info.plist" "${APP_DIR}/Contents/Info.plist"
if [ -d "${SCRIPT_DIR}/Resources" ]; then
    cp -R "${SCRIPT_DIR}/Resources/"* "${APP_DIR}/Contents/Resources/" 2>/dev/null || true
fi

echo "==> Preparing DMG staging..."
cp -R "${APP_DIR}" "${DMG_STAGING}/"
ln -s /Applications "${DMG_STAGING}/Applications"

echo "==> Building production DMG installer (${DMG_NAME})..."
hdiutil create -volname "Antigravity HUD" \
    -srcfolder "${DMG_STAGING}" \
    -ov -format UDZO \
    "${DMG_PATH}"

echo "==> Build complete!"
echo "    App: ${APP_DIR}"
echo "    DMG: ${DMG_PATH}"
