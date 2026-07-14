#!/usr/bin/env bash
#
# Creates a stable self-signed code-signing identity named "IconShift Self-Signed"
# in your login keychain. Signing IconShift with a *stable* identity means the
# macOS "App Management" permission you grant it survives rebuilds (an ad-hoc
# signature changes every build and resets the grant).
#
# You may be prompted for your login keychain password. This creates a local
# development certificate only; it is not trusted by Gatekeeper and is never
# committed to the repo.
set -euo pipefail

NAME="IconShift Self-Signed"
KEYCHAIN="$HOME/Library/Keychains/login.keychain-db"

if security find-identity -v -p codesigning | grep -q "$NAME"; then
    echo "Identity '$NAME' already exists. Nothing to do."
    exit 0
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cat > "$TMP/openssl.cnf" <<EOF
[req]
distinguished_name = dn
x509_extensions = ext
prompt = no
[dn]
CN = $NAME
[ext]
basicConstraints = critical,CA:false
keyUsage = critical,digitalSignature
extendedKeyUsage = critical,codeSigning
EOF

echo "==> Generating key + self-signed certificate"
openssl req -x509 -newkey rsa:2048 -nodes \
    -keyout "$TMP/key.pem" -out "$TMP/cert.pem" \
    -days 3650 -config "$TMP/openssl.cnf"

openssl pkcs12 -export \
    -inkey "$TMP/key.pem" -in "$TMP/cert.pem" \
    -out "$TMP/identity.p12" -passout pass:iconshift -name "$NAME"

echo "==> Importing into login keychain (may prompt for your password)"
security import "$TMP/identity.p12" -k "$KEYCHAIN" -P iconshift \
    -T /usr/bin/codesign -T /usr/bin/security

# Let codesign use the private key without an interactive prompt each build.
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "" "$KEYCHAIN" >/dev/null 2>&1 || \
    echo "    (Could not set key partition list automatically; codesign may prompt once.)"

echo "==> Created identity:"
security find-identity -v -p codesigning | grep "$NAME" || true
echo "Now run: scripts/build.sh"
