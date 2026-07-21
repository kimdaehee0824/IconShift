#!/usr/bin/env bash
#
# Builds IconShift with xcodebuild and stages dist/IconShift.app.
#
# Usage:
#   scripts/build.sh [debug|release]
#
# Signing identity resolution (first match wins):
#   1. $ICONSHIFT_SIGN_ID           (e.g. "Developer ID Application: Name (TEAMID)")
#   2. "IconShift Self-Signed"      (created by scripts/make-signing-cert.sh)
#   3. "-"                         (ad-hoc; fine for local testing)
#
# A stable identity (1 or 2) keeps the macOS "App Management" grant across rebuilds.
# A "Developer ID Application" identity switches to archive + -exportArchive, which
# re-signs nested code and applies the secure timestamp notarization requires.
set -euo pipefail

CONFIG="${1:-release}"
case "$CONFIG" in
    debug)   XCODE_CONFIG="Debug" ;;
    release) XCODE_CONFIG="Release" ;;
    *) echo "usage: scripts/build.sh [debug|release]" >&2; exit 1 ;;
esac

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="IconShift"
DIST="$ROOT/dist"
APP="$DIST/$APP_NAME.app"
ARCHIVE="$DIST/$APP_NAME.xcarchive"

command -v tuist >/dev/null 2>&1 || {
    echo "tuist not found; install it with 'mise install' or 'brew install tuist'" >&2
    exit 1
}

IDENTITY="${ICONSHIFT_SIGN_ID:-}"
if [[ -z "$IDENTITY" ]]; then
    if security find-identity -v -p codesigning 2>/dev/null | grep -q "IconShift Self-Signed"; then
        IDENTITY="IconShift Self-Signed"
    else
        IDENTITY="-"
        echo "    (no stable identity found; using ad-hoc. Run scripts/make-signing-cert.sh for a persistent grant.)"
    fi
fi

echo "==> tuist generate"
(cd "$ROOT" && tuist generate --no-open)

mkdir -p "$DIST"
rm -rf "$APP" "$ARCHIVE"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

archive() {
    xcodebuild archive \
        -workspace "$ROOT/$APP_NAME.xcworkspace" \
        -scheme "$APP_NAME" \
        -configuration "$XCODE_CONFIG" \
        -destination "generic/platform=macOS" \
        -archivePath "$ARCHIVE" \
        -derivedDataPath "$ROOT/.build/DerivedData" \
        "$@"
}

if [[ "$IDENTITY" == "Developer ID Application"* ]]; then
    TEAM_ID="${IDENTITY##*(}"
    TEAM_ID="${TEAM_ID%)}"
    [[ "$TEAM_ID" =~ ^[A-Z0-9]{10}$ ]] || {
        echo "Could not read a team ID from ICONSHIFT_SIGN_ID: $IDENTITY" >&2
        exit 1
    }

    echo "==> xcodebuild archive (signing with: $IDENTITY)"
    # Hardened runtime only here: it enforces library validation, which would reject
    # the Sparkle framework's upstream signature under ad-hoc/self-signed local builds.
    archive CODE_SIGN_IDENTITY="$IDENTITY" DEVELOPMENT_TEAM="$TEAM_ID" \
        ENABLE_HARDENED_RUNTIME=YES OTHER_CODE_SIGN_FLAGS="--timestamp"

    echo "==> xcodebuild -exportArchive (developer-id)"
    cat > "$WORK/ExportOptions.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key><string>developer-id</string>
    <key>destination</key><string>export</string>
    <key>signingStyle</key><string>manual</string>
    <key>signingCertificate</key><string>Developer ID Application</string>
    <key>teamID</key><string>$TEAM_ID</string>
</dict>
</plist>
PLIST
    xcodebuild -exportArchive \
        -archivePath "$ARCHIVE" \
        -exportOptionsPlist "$WORK/ExportOptions.plist" \
        -exportPath "$WORK/export"
    ditto "$WORK/export/$APP_NAME.app" "$APP"
else
    echo "==> xcodebuild archive (unsigned)"
    archive CODE_SIGNING_ALLOWED=NO

    echo "==> Signing with: $IDENTITY"
    ditto "$ARCHIVE/Products/Applications/$APP_NAME.app" "$APP"
    codesign --force --sign "$IDENTITY" --identifier "com.iconshift.IconShift" "$APP"
fi

codesign --verify --strict --verbose=2 "$APP"
codesign -dv "$APP" 2>&1 | grep -E "Identifier|Authority|flags" || true

echo "==> Done: $APP"
