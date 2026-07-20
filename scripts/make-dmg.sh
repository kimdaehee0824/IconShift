#!/usr/bin/env bash
#
# Packages dist/IconShift.app into dist/IconShift-<version>.dmg.
#
# Usage:
#   scripts/build.sh release && scripts/make-dmg.sh
#
# The volume gets an /Applications shortcut, the compiled app icon as its
# volume icon, and the drag-to-install Finder layout from scripts/dmg/
# (regenerate those assets with scripts/make-dmg-layout.sh). hdiutil cannot
# set the volume's custom-icon Finder bit at create time, so the image is
# built read-write first, stamped with SetFile, then converted to a
# compressed read-only UDZO image.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/dist/IconShift.app"
VOLUME_NAME="IconShift"

test -d "$APP" || { echo "app bundle not found; run scripts/build.sh first" >&2; exit 1; }

VERSION="$(plutil -extract CFBundleShortVersionString raw "$APP/Contents/Info.plist")"
ICON_NAME="$(plutil -extract CFBundleIconFile raw "$APP/Contents/Info.plist")"
ICON_PATH="$APP/Contents/Resources/$ICON_NAME"
[[ -f "$ICON_PATH" ]] || ICON_PATH="$ICON_PATH.icns"
test -s "$ICON_PATH" || { echo "compiled app icon not found: $ICON_PATH" >&2; exit 1; }

DMG="$ROOT/dist/IconShift-$VERSION.dmg"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

test -s "$ROOT/scripts/dmg/background.tiff" || { echo "missing scripts/dmg/background.tiff; run scripts/make-dmg-layout.sh" >&2; exit 1; }
test -s "$ROOT/scripts/dmg/DS_Store" || { echo "missing scripts/dmg/DS_Store; run scripts/make-dmg-layout.sh" >&2; exit 1; }

STAGING="$WORK/staging"
mkdir -p "$STAGING/.background"
cp -R "$APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"
cp "$ICON_PATH" "$STAGING/.VolumeIcon.icns"
cp "$ROOT/scripts/dmg/background.tiff" "$STAGING/.background/background.tiff"
cp "$ROOT/scripts/dmg/DS_Store" "$STAGING/.DS_Store"

echo "==> Creating writable image"
RW_DMG="$WORK/rw.dmg"
hdiutil create -srcfolder "$STAGING" -volname "$VOLUME_NAME" -fs HFS+ \
    -format UDRW -quiet "$RW_DMG"

echo "==> Stamping volume icon"
MOUNT_POINT="$WORK/mount"
hdiutil attach "$RW_DMG" -mountpoint "$MOUNT_POINT" -nobrowse -quiet
SetFile -a C "$MOUNT_POINT"
hdiutil detach "$MOUNT_POINT" -quiet

echo "==> Converting to compressed image"
rm -f "$DMG"
hdiutil convert "$RW_DMG" -format UDZO -imagekey zlib-level=9 -quiet -o "$DMG"
hdiutil verify -quiet "$DMG"

echo "==> Done: $DMG"
