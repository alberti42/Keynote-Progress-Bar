#!/usr/bin/env bash
#
# notarize_framework.sh — Sign and notarize a standalone .framework (KeynoteProgressBarHelper.framework)
#
# 1. Remove old signatures — clears _CodeSignature folders, avoiding conflicts.
# 2. Sign framework — signs the framework bundle and its binary.
# 3. Verify — ensures the signature is valid.
# 4. Archive — compresses into a distributable .zip.
# 5. Notarize — uploads to Apple, waits for approval.
# 6. Gatekeeper test — uses spctl to assess the framework bundle.
#
# Notes:
# - Stapling is typically not applicable to a raw .framework zip distribution.
# - If users still get "damaged or missing necessary resources", have them remove quarantine:
#     xattr -dr com.apple.quarantine ~/Library/Frameworks/KeynoteProgressBarHelper.framework
#
# Usage:
#   ./notarize_framework.sh /path/to/KeynoteProgressBarHelper.framework
#
# Requirements:
#   1. Paid Apple Developer account
#   2. "Developer ID Application" certificate in keychain
#   3. notarytool credentials stored:
#        xcrun notarytool store-credentials "notary-profile" \
#          --apple-id "..." --team-id "..." --password "app-specific-password"
#
# Check identities with: security find-identity -v -p codesigning

set -euo pipefail

FRAMEWORK_PATH=${1:-}
FRAMEWORK_NAME="KeynoteProgressBarHelper.framework"
ZIP_PATH="${PWD}/KeynoteProgressBarHelper.framework.zip"

# Your Developer ID (adjust if needed)
DEV_ID="Developer ID Application: Andrea Alberti (9V3X7C8VCK)"

NOTARY_PROFILE="notary-profile"

if [[ -z "$FRAMEWORK_PATH" ]]; then
  echo "Usage: $0 /path/to/${FRAMEWORK_NAME}"
  exit 1
fi

if [[ ! -d "$FRAMEWORK_PATH" ]]; then
  echo "Error: Framework not found at: $FRAMEWORK_PATH"
  exit 1
fi

if [[ "$(basename "$FRAMEWORK_PATH")" != "$FRAMEWORK_NAME" ]]; then
  echo "Warning: Framework name is not ${FRAMEWORK_NAME}"
  echo "         You passed: $(basename "$FRAMEWORK_PATH")"
fi

echo "==> Framework to notarize: $FRAMEWORK_PATH"
echo "==> Using signing identity: $DEV_ID"

# Locate the actual framework binary (usually FrameworkName.framework/FrameworkName)
FRAMEWORK_BINARY="${FRAMEWORK_PATH}/$(basename "$FRAMEWORK_PATH" .framework)"

if [[ ! -f "$FRAMEWORK_BINARY" ]]; then
  echo "Error: Framework binary not found at: $FRAMEWORK_BINARY"
  echo "This framework does not look like a standard macOS framework layout."
  exit 1
fi

echo "==> Cleaning old signatures…"
find "$FRAMEWORK_PATH" -name _CodeSignature -type d -exec rm -rf {} + || true

# Remove quarantine if present (for your own packaging sanity)
echo "==> Removing quarantine attribute (if present)…"
xattr -dr com.apple.quarantine "$FRAMEWORK_PATH" 2>/dev/null || true

echo "==> Signing framework…"
# --timestamp is strongly recommended for Developer ID signing
# --options runtime is generally fine; frameworks typically don’t need entitlements
codesign --force --timestamp --options runtime --sign "$DEV_ID" "$FRAMEWORK_PATH"

echo "==> Verifying code signature (framework)…"
codesign -dv --verbose=4 "$FRAMEWORK_PATH"
codesign -vv --strict "$FRAMEWORK_PATH"

echo "==> Verifying code signature (framework binary)…"
codesign -dv --verbose=4 "$FRAMEWORK_BINARY"
codesign -vv --strict "$FRAMEWORK_BINARY"

echo "==> Creating ZIP archive…"
rm -f "$ZIP_PATH"
# ditto is preferred; preserves bundle structure and metadata correctly
ditto -c -k --keepParent "$FRAMEWORK_PATH" "$ZIP_PATH"

echo "==> Submitting ZIP to Apple Notary Service…"
xcrun notarytool submit "$ZIP_PATH" --keychain-profile "$NOTARY_PROFILE" --wait

echo "==> Gatekeeper assessment (spctl)…"
# spctl can assess frameworks, but results vary slightly by macOS version
spctl --assess --verbose=4 "$FRAMEWORK_PATH" || true

echo
echo "==> Notarization complete!"
echo
echo "Notarized file: $ZIP_PATH"
