#!/usr/bin/env bash
#
# notarize_app.sh — Sign, notarize, and staple an AppleScript .app (clean staged copy)
#
# This version fixes:
#   codesign: resource fork, Finder information, or similar detritus not allowed
#
# by staging the app into a mktemp directory using:
#   ditto --norsrc --noextattr
# plus:
#   dot_clean + xattr -cr
#
# Usage:
#   ./notarize_app.sh "/path/to/Add Progress Bar to Keynote.app"
#
# Requirements:
#   - Developer ID Application cert in keychain
#   - notarytool credentials stored:
#       xcrun notarytool store-credentials "notary-profile" ...
#

#!/usr/bin/env bash
#
# notarize_app.sh — Sign, notarize, and staple an AppleScript .app (clean staged copy)
#
# Usage:
#   ./notarize_app.sh "/path/to/Add Progress Bar to Keynote.app"
#

set -euo pipefail

APP_PATH=${1:-}
KEEP_STAGING=0
if [[ "${2:-}" == "--keep-staging" ]]; then
  KEEP_STAGING=1
fi
APP_EXPECTED_NAME="Add Progress Bar to Keynote.app"

DEV_ID="Developer ID Application: Andrea Alberti (9V3X7C8VCK)"
NOTARY_PROFILE="notary-profile"

if [[ -z "$APP_PATH" ]]; then
  echo "Usage: $0 \"/path/to/${APP_EXPECTED_NAME}\""
  exit 1
fi

if [[ ! -d "$APP_PATH" ]]; then
  echo "Error: App not found at: $APP_PATH"
  exit 1
fi

APP_NAME="$(basename "$APP_PATH" .app)"
DMG_NAME="${APP_NAME}"
DMG_FILE_NAME="$(printf '%s' "$APP_NAME" | tr -s '[:space:]' '_' )"
DMG_PATH="${PWD}/${DMG_FILE_NAME}.dmg"

# Space-safe mktemp prefix
SAFE_APP_NAME="$(printf '%s' "$APP_NAME" | tr -cs '[:alnum:]._-' '_' )"
STAGING_DIR="$(mktemp -d -t "notarize_${SAFE_APP_NAME}_XXXXXX")"

cleanup() {
  if [[ "$KEEP_STAGING" -eq 1 ]]; then
    echo
    echo "==> Keeping staging directory for debugging:"
    echo "    \"$STAGING_DIR\""
    echo
  else
    rm -rf "$STAGING_DIR"
  fi
}
trap cleanup EXIT

STAGED_APP_PATH="${STAGING_DIR}/${APP_NAME}.app"

# DMG build folder (mounted content)
DMG_ROOT="${STAGING_DIR}/dmgroot"
mkdir -p "$DMG_ROOT"

FRAMEWORK_PATH="${STAGED_APP_PATH}/Contents/Frameworks/KeynoteProgressBarHelper.framework"
FRAMEWORK_BINARY="${FRAMEWORK_PATH}/KeynoteProgressBarHelper"

echo "==> Input app:   \"$APP_PATH\""
echo "==> Staging dir: \"$STAGING_DIR\""
echo "==> Staged app:  \"$STAGED_APP_PATH\""
echo "==> DMG output:  \"$DMG_PATH\""
echo "==> Signing ID:  \"$DEV_ID\""
echo

# --- Stage app cleanly (strip resource forks & xattrs) ---
echo "==> Copying app to staging (stripping resource forks + xattrs)…"
ditto --norsrc --noextattr "$APP_PATH" "$STAGED_APP_PATH"

echo "==> Cleaning AppleDouble files + remaining xattrs…"
dot_clean -m "$STAGED_APP_PATH" 2>/dev/null || true
xattr -cr "$STAGED_APP_PATH" 2>/dev/null || true

echo "==> Cleaning old signatures…"
find "$STAGED_APP_PATH" -name _CodeSignature -type d -exec rm -rf {} + || true

# --- Sign embedded framework first ---
if [[ -d "$FRAMEWORK_PATH" ]]; then
  echo "==> Found embedded framework:"
  echo "    \"$FRAMEWORK_PATH\""

  if [[ ! -f "$FRAMEWORK_BINARY" ]]; then
    echo "Error: Expected framework binary not found at:"
    echo "  \"$FRAMEWORK_BINARY\""
    exit 1
  fi

  echo "==> Cleaning old signatures inside embedded framework…"
  find "$FRAMEWORK_PATH" -name _CodeSignature -type d -exec rm -rf {} + || true

  echo "==> Signing embedded framework…"
  codesign --force --timestamp --options runtime \
    --sign "$DEV_ID" \
    "$FRAMEWORK_PATH"

  echo "==> Verifying embedded framework signature…"
  codesign -vv --strict --verbose=4 "$FRAMEWORK_PATH"
  codesign -vv --strict --verbose=4 "$FRAMEWORK_BINARY"
  echo
fi

# --- Sign app ---
echo "==> Signing AppleScript app…"
codesign --force --timestamp --options runtime \
  --sign "$DEV_ID" \
  "$STAGED_APP_PATH"

echo "==> Verifying app signature…"
codesign -vv --deep --strict --verbose=4 "$STAGED_APP_PATH"

# --- Build DMG root contents ---
echo "==> Preparing DMG contents…"
ditto --norsrc --noextattr "$STAGED_APP_PATH" "${DMG_ROOT}/${APP_NAME}.app"

# Nice UX: Applications symlink
ln -sf /Applications "${DMG_ROOT}/Applications"

# Ensure clean metadata in DMG root
dot_clean -m "$DMG_ROOT" 2>/dev/null || true
xattr -cr "$DMG_ROOT" 2>/dev/null || true

# --- Create DMG ---
echo "==> Creating DMG…"
rm -f "$DMG_PATH"

# Choose a size with slack (hdiutil will fail if too small).
# This uses du to estimate; add overhead.
DMG_SIZE_MB=$(du -sm "$DMG_ROOT" | awk '{print $1 + 50}')  # +50 MB overhead

hdiutil create \
  -volname "$DMG_NAME" \
  -srcfolder "$DMG_ROOT" \
  -fs HFS+ \
  -format UDZO \
  -imagekey zlib-level=9 \
  -size "${DMG_SIZE_MB}m" \
  "$DMG_PATH"

# --- Sign DMG (recommended) ---
echo "==> Signing DMG…"
codesign --force --timestamp --sign "$DEV_ID" "$DMG_PATH"

echo "==> Verifying DMG signature…"
codesign -vv --strict --verbose=4 "$DMG_PATH"

# --- Notarize DMG ---
echo "==> Submitting DMG to Apple Notary Service…"
xcrun notarytool submit "$DMG_PATH" --keychain-profile "$NOTARY_PROFILE" --wait

# --- Staple DMG ---
echo "==> Stapling ticket to DMG…"
xcrun stapler staple "$DMG_PATH"

echo "==> Validating stapled ticket…"
xcrun stapler validate "$DMG_PATH"

# --- Gatekeeper check ---
echo "==> Gatekeeper assessment…"
spctl --assess --verbose=4 "$DMG_PATH"

echo
echo "==> ✅ Done!"
echo "Deliver: \"$DMG_PATH\""