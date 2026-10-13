#!/usr/bin/env bash
#
# Build a signed + notarized + stapled drag-to-Applications .dmg from a
# notarized Tubecrate.app. Run Scripts/notarize.sh first so build/Tubecrate.app
# is signed, notarized, and stapled.
#
# Usage:
#   ./Scripts/make-dmg.sh [version]
#
set -euo pipefail
cd "$(dirname "$0")/.."
source "Scripts/_notary.sh"

VERSION="${1:-1.0}"
TEAM_ID="${TEAM_ID:?set TEAM_ID to your Apple Developer team ID}"
NOTARY_PROFILE="${NOTARY_PROFILE:-tubecrate}"
APP="build/Tubecrate.app"
DMG="build/Tubecrate-${VERSION}.dmg"
STAGE="$(mktemp -d)/Tubecrate"

[[ -d "$APP" ]] || { echo "✗ $APP not found — run Scripts/notarize.sh first." >&2; exit 1; }

SIGN_IDENTITY="${SIGN_IDENTITY:-$(security find-identity -v -p codesigning \
  | grep "Developer ID Application" | grep "${TEAM_ID}" | head -1 \
  | sed -E 's/.*"(.*)"/\1/')}"

echo "▸ Staging disk image contents…"
mkdir -p "$STAGE"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"

echo "▸ Creating compressed .dmg…"
rm -f "$DMG"
hdiutil create -volname "Tubecrate" -srcfolder "$STAGE" -ov -format UDZO "$DMG" >/dev/null

if [[ -n "${SIGN_IDENTITY}" ]]; then
  echo "▸ Signing .dmg (${SIGN_IDENTITY})…"
  codesign --force --sign "${SIGN_IDENTITY}" "$DMG"

  echo "▸ Notarizing .dmg…"
  notarize_file "$DMG"

  echo "▸ Stapling .dmg…"
  xcrun stapler staple "$DMG"
else
  echo "⚠ No Developer ID identity — .dmg is unsigned (app inside keeps its own ticket)."
fi

echo "✅ ${DMG}"
echo "   sha256: $(shasum -a 256 "$DMG" | awk '{print $1}')"
