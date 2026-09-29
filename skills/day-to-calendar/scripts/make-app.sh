#!/bin/sh
# make-app.sh: builds DayCal.app from daycal.swift. Claude's own app cannot ask macOS for calendar access
# (no calendar usage line in its Info.plist, so macOS refuses without ever showing a prompt), so the tool
# runs as its own tiny app that carries the line. Click Allow once; the grant is tied to this build's
# signature, so rebuild only when daycal.swift changes (and expect to click Allow again).
set -e
here=$(cd "$(dirname "$0")" && pwd)
app="$here/DayCal.app"
rm -rf "$app"
mkdir -p "$app/Contents/MacOS"
swiftc -O -target "$(uname -m)-apple-macos14" "$here/daycal.swift" -o "$app/Contents/MacOS/DayCal"
cat > "$app/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>io.github.jrejl.daycal</string>
<key>CFBundleName</key><string>DayCal</string>
<key>CFBundleExecutable</key><string>DayCal</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>1.0</string>
<key>LSUIElement</key><true/>
<key>LSMinimumSystemVersion</key><string>14.0</string>
<key>NSCalendarsFullAccessUsageDescription</key><string>DayCal writes a short summary of each day you worked into its own calendar.</string>
<key>NSCalendarsUsageDescription</key><string>DayCal writes a short summary of each day you worked into its own calendar.</string>
</dict></plist>
PLIST
codesign --force -s - "$app"
echo "built $app"
