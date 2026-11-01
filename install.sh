#!/bin/sh
set -e

cd "$(dirname "$0")"
app="$HOME/Applications/OptTab.app"

pkill -x OptTab || true
mkdir -p "$app/Contents/MacOS"
cp Info.plist "$app/Contents/Info.plist"
swiftc -O main.swift -o "$app/Contents/MacOS/OptTab"
codesign -f -s - "$app"
open "$app"

echo "Installed $app. Turn on OptTab in System Settings > Privacy & Security > Accessibility, then restart it."
