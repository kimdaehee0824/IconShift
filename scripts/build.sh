#!/usr/bin/env bash
#
# Builds EasyIcon and assembles a signed EasyIcon.app under ./dist.
#
# Usage:
#   scripts/build.sh [debug|release]
#
# Signing identity resolution (first match wins):
#   1. $EASYICON_SIGN_ID           (e.g. "Developer ID Application: ...")
#   2. "EasyIcon Self-Signed"      (created by scripts/make-signing-cert.sh)
#   3. "-"                         (ad-hoc; fine for local testing)
#
# A stable identity (1 or 2) keeps the macOS "App Management" grant across rebuilds.
set -euo pipefail

CONFIG="${1:-release}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="EasyIcon"
BUILD_DIR="$ROOT/.build/$CONFIG"
DIST="$ROOT/dist"
APP="$DIST/$APP_NAME.app"

echo "==> swift build ($CONFIG)"
swift build -c "$CONFIG" --package-path "$ROOT"

echo "==> Assembling $APP"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BUILD_DIR/$APP_NAME" "$APP/Contents/MacOS/$APP_NAME"
cp "$ROOT/Resources/Info.plist" "$APP/Contents/Info.plist"

IDENTITY="${EASYICON_SIGN_ID:-}"
if [[ -z "$IDENTITY" ]]; then
    if security find-identity -v -p codesigning 2>/dev/null | grep -q "EasyIcon Self-Signed"; then
        IDENTITY="EasyIcon Self-Signed"
    else
        IDENTITY="-"
        echo "    (no stable identity found; using ad-hoc. Run scripts/make-signing-cert.sh for a persistent grant.)"
    fi
fi

echo "==> Signing with: $IDENTITY"
codesign --force --sign "$IDENTITY" --identifier "com.easyicon.EasyIcon" "$APP"
codesign -dv "$APP" 2>&1 | grep -E "Identifier|Signature" || true

echo "==> Done: $APP"
