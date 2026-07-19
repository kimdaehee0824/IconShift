#!/usr/bin/env bash
#
# Builds IconShift and assembles a signed IconShift.app under ./dist.
#
# Usage:
#   scripts/build.sh [debug|release]
#
# Signing identity resolution (first match wins):
#   1. $ICONSHIFT_SIGN_ID           (e.g. "Developer ID Application: ...")
#   2. "IconShift Self-Signed"      (created by scripts/make-signing-cert.sh)
#   3. "-"                         (ad-hoc; fine for local testing)
#
# A stable identity (1 or 2) keeps the macOS "App Management" grant across rebuilds.
set -euo pipefail

CONFIG="${1:-release}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="IconShift"
DIST="$ROOT/dist"
APP="$DIST/$APP_NAME.app"
ARM64_BUILD_DIR="$ROOT/.build/arm64"
X86_64_BUILD_DIR="$ROOT/.build/x86_64"

echo "==> swift build ($CONFIG, arm64)"
swift build -c "$CONFIG" --package-path "$ROOT" \
    --triple arm64-apple-macosx14.0 --scratch-path "$ARM64_BUILD_DIR"

echo "==> swift build ($CONFIG, x86_64)"
swift build -c "$CONFIG" --package-path "$ROOT" \
    --triple x86_64-apple-macosx14.0 --scratch-path "$X86_64_BUILD_DIR"

echo "==> Assembling $APP"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
xcrun lipo -create \
    "$ARM64_BUILD_DIR/arm64-apple-macosx/$CONFIG/$APP_NAME" \
    "$X86_64_BUILD_DIR/x86_64-apple-macosx/$CONFIG/$APP_NAME" \
    -output "$APP/Contents/MacOS/$APP_NAME"
cp "$ROOT/Resources/Info.plist" "$APP/Contents/Info.plist"
xcrun xcstringstool compile "$ROOT/Resources/Localizable.xcstrings" \
    -o "$APP/Contents/Resources"

# The Icon Composer bundle needs actool; swift build never invokes it. --app-icon must match
# the .icon filename, or actool emits an empty catalog and still exits 0.
echo "==> Compiling app icon"
ICON_PARTIAL="$DIST/icon-info.plist"
xcrun actool "$ROOT/Resources/$APP_NAME.icon" \
    --compile "$APP/Contents/Resources" \
    --app-icon "$APP_NAME" \
    --output-partial-info-plist "$ICON_PARTIAL" \
    --platform macosx --target-device mac \
    --minimum-deployment-target 14.0 \
    --output-format human-readable-text
# Xcode merges actool's partial plist automatically; a hand-assembled bundle must do it here.
for key in CFBundleIconFile CFBundleIconName; do
    value="$(/usr/libexec/PlistBuddy -c "Print :$key" "$ICON_PARTIAL")"
    /usr/libexec/PlistBuddy -c "Add :$key string $value" "$APP/Contents/Info.plist"
done
rm -f "$ICON_PARTIAL"

IDENTITY="${ICONSHIFT_SIGN_ID:-}"
if [[ -z "$IDENTITY" ]]; then
    if security find-identity -v -p codesigning 2>/dev/null | grep -q "IconShift Self-Signed"; then
        IDENTITY="IconShift Self-Signed"
    else
        IDENTITY="-"
        echo "    (no stable identity found; using ad-hoc. Run scripts/make-signing-cert.sh for a persistent grant.)"
    fi
fi

echo "==> Signing with: $IDENTITY"
codesign --force --sign "$IDENTITY" --identifier "com.iconshift.IconShift" "$APP"
codesign --verify --strict --verbose=2 "$APP"
codesign -dv "$APP" 2>&1 | grep -E "Identifier|Signature" || true

echo "==> Done: $APP"
