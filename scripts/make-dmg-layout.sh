#!/usr/bin/env bash
#
# Regenerates the committed DMG layout assets in scripts/dmg/:
#   background.tiff   1x+2x Finder window background (arrow between icon slots)
#   DS_Store          Finder view settings: window bounds, icon size/positions,
#                     background picture
#
# Usage:
#   scripts/build.sh release && scripts/make-dmg-layout.sh
#
# Finder only writes usable view settings into a .DS_Store on a real mounted
# volume, so this builds a scratch read-write image from dist/IconShift.app,
# lays it out through Finder scripting, and harvests the result. Run locally
# after changing the layout; CI never runs this and only consumes the
# committed assets through scripts/make-dmg.sh.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/dist/IconShift.app"
OUT="$ROOT/scripts/dmg"
VOLUME_NAME="IconShift"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

test -d "$APP" || { echo "app bundle not found; run scripts/build.sh first" >&2; exit 1; }
mkdir -p "$OUT"

cat > "$WORK/background.swift" <<'EOF'
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

// 600x400pt window content, drawn at 2x with 50pt of bottom bleed so the
// title-bar offset can never expose a white strip. Arrow only - text would
// need localization.
let scale = 2.0
let width = Int(600 * scale), height = Int(450 * scale)
let context = CGContext(
    data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
    space: CGColorSpace(name: CGColorSpace.sRGB)!,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
)!
context.scaleBy(x: scale, y: scale)

context.setFillColor(CGColor(srgbRed: 0.965, green: 0.965, blue: 0.973, alpha: 1))
context.fill(CGRect(x: 0, y: 0, width: 600, height: 450))

// Finder icon centers sit at y=190 from the top; CG origin is bottom-left.
let y = 450.0 - 190.0
context.setStrokeColor(CGColor(srgbRed: 0.69, green: 0.69, blue: 0.72, alpha: 1))
context.setLineWidth(5)
context.setLineCap(.round)
context.setLineJoin(.round)
context.move(to: CGPoint(x: 240, y: y))
context.addLine(to: CGPoint(x: 352, y: y))
context.strokePath()
context.move(to: CGPoint(x: 334, y: y + 16))
context.addLine(to: CGPoint(x: 356, y: y))
context.addLine(to: CGPoint(x: 334, y: y - 16))
context.strokePath()

let image = context.makeImage()!
let destination = CGImageDestinationCreateWithURL(
    URL(fileURLWithPath: CommandLine.arguments[1]) as CFURL,
    UTType.png.identifier as CFString, 1, nil
)!
CGImageDestinationAddImage(destination, image, nil)
guard CGImageDestinationFinalize(destination) else { exit(1) }
EOF

echo "==> Drawing background"
swift "$WORK/background.swift" "$WORK/background@2x.png"
sips -z 450 600 "$WORK/background@2x.png" --out "$WORK/background.png" >/dev/null
tiffutil -cathidpicheck "$WORK/background.png" "$WORK/background@2x.png" \
    -out "$OUT/background.tiff" >/dev/null 2>&1

echo "==> Building scratch volume"
STAGING="$WORK/staging"
mkdir -p "$STAGING/.background"
cp -R "$APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"
cp "$OUT/background.tiff" "$STAGING/.background/background.tiff"
hdiutil create -srcfolder "$STAGING" -volname "$VOLUME_NAME" -fs HFS+ \
    -format UDRW -quiet "$WORK/rw.dmg"
hdiutil attach "$WORK/rw.dmg" -quiet

echo "==> Applying Finder layout"
# Window bounds include the title bar; the background picture fills only the
# content area, so the bounds height is the image height plus the title bar.
TITLE_BAR=28
osascript <<EOF
tell application "Finder"
    tell disk "$VOLUME_NAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {200, 120, 800, $((520 + TITLE_BAR))}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 128
        set background picture of viewOptions to file ".background:background.tiff"
        set position of item "IconShift.app" of container window to {150, 190}
        set position of item "Applications" of container window to {450, 190}
        close
        open
        update without registering applications
        delay 2
        set the bounds of container window to {200, 120, 800, $((520 + TITLE_BAR))}
        delay 1
        close
    end tell
end tell
EOF
sync
sleep 2

test -s "/Volumes/$VOLUME_NAME/.DS_Store" || { echo "Finder wrote no .DS_Store" >&2; exit 1; }
cp "/Volumes/$VOLUME_NAME/.DS_Store" "$OUT/DS_Store"
hdiutil detach "/Volumes/$VOLUME_NAME" -quiet

echo "==> Done: $OUT/background.tiff, $OUT/DS_Store"
