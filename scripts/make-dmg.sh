#!/bin/bash
# Usage: make-dmg.sh <path/to/MeCabChan.app> <output.dmg> [signing identity]
# Creates a compressed DMG with the app and an /Applications link, and signs it if an identity is given.
set -euo pipefail

APP="$1"
DMG="$2"
IDENTITY="${3:-}"

STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT

ditto "$APP" "$STAGING/$(basename "$APP")"
ln -s /Applications "$STAGING/Applications"

rm -f "$DMG"
hdiutil create -volname "MeCabChan" -srcfolder "$STAGING" -fs HFS+ -format UDZO -ov "$DMG"

if [[ -n "$IDENTITY" ]]; then
    codesign --force --timestamp --sign "$IDENTITY" "$DMG"
fi
