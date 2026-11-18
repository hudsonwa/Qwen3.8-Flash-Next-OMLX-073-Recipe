#!/usr/bin/env bash
# Optional boot-persistence: KeepAlive launchd agent for the oMLX app.
# The app owns the server child; KeepAlive on the APP is the supported path
# (KeepAliving the python child directly fights the app's own supervisor).
set -euo pipefail
LABEL=com.omlx.flashnext073
PLIST=$HOME/Library/LaunchAgents/${LABEL}.plist
mkdir -p $HOME/Library/LaunchAgents $(dirname $HOME/.omlx/logs)/.
cat > "$PLIST" <<XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>${LABEL}</string>
  <key>ProgramArguments</key><array>
    <string>/usr/bin/open</string><string>-gj</string>
    <string>${HOME}/Applications/oMLX.app</string>
  </array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><dict>
    <key>SuccessfulExit</key><false/>
    <key>AfterInitialDemand</key><true/>
  </dict>
  <key>ThrottleInterval</key><integer>60</integer>
  <key>StandardOutPath</key><string>${HOME}/.omlx/logs/launchd.log</string>
  <key>StandardErrorPath</key><string>${HOME}/.omlx/logs/launchd.log</string>
</dict></plist>
XML
launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"
echo "installed $PLIST (KeepAlive = relaunch `open -gj` when the app exits nonzero)"
echo 'note: oMLX app auto-starts the server via its own setting; the plist only re-opens the app.'
