#!/usr/bin/env bash
#
# Notarizes an .app or .dmg with notarytool and staples the ticket.
# Requires an App Store Connect *team* API key with the Developer role
# (personal keys are rejected by the notary service).
#
# Usage:
#   NOTARY_KEY_FILE=key.p8 NOTARY_KEY_ID=... NOTARY_ISSUER_ID=... \
#       scripts/notarize.sh <path-to-.app-or-.dmg>
set -euo pipefail

TARGET="${1:?usage: scripts/notarize.sh <path-to-.app-or-.dmg>}"
: "${NOTARY_KEY_FILE:?NOTARY_KEY_FILE is required}"
: "${NOTARY_KEY_ID:?NOTARY_KEY_ID is required}"
: "${NOTARY_ISSUER_ID:?NOTARY_ISSUER_ID is required}"
command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 1; }

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# The notary service accepts dmg/pkg/zip; bare .app bundles must be zipped.
SUBMIT="$TARGET"
if [[ "$TARGET" == *.app ]]; then
    SUBMIT="$WORK/$(basename "$TARGET").zip"
    ditto -c -k --keepParent "$TARGET" "$SUBMIT"
fi

echo "==> notarytool submit $(basename "$SUBMIT")"
RESULT="$(xcrun notarytool submit "$SUBMIT" \
    --key "$NOTARY_KEY_FILE" --key-id "$NOTARY_KEY_ID" --issuer "$NOTARY_ISSUER_ID" \
    --wait --timeout 30m --output-format json)"
echo "$RESULT"

STATUS="$(jq -r '.status' <<<"$RESULT")"
if [[ "$STATUS" != "Accepted" ]]; then
    SUBMISSION_ID="$(jq -r '.id' <<<"$RESULT")"
    xcrun notarytool log "$SUBMISSION_ID" \
        --key "$NOTARY_KEY_FILE" --key-id "$NOTARY_KEY_ID" --issuer "$NOTARY_ISSUER_ID" || true
    echo "Notarization failed with status: $STATUS" >&2
    exit 1
fi

echo "==> stapler staple $(basename "$TARGET")"
xcrun stapler staple "$TARGET"
