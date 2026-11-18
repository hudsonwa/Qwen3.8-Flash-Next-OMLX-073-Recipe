#!/usr/bin/env bash
# Remove the optional launchd login item installed by setup.sh INSTALL_PLIST=1.
# Does not touch the app, the model, the settings or the cache.
set -euo pipefail
PLIST=$HOME/Library/LaunchAgents/com.omlx.flashnext073.plist
if [ -f "$PLIST" ]; then
  launchctl unload "$PLIST" 2>/dev/null || true
  rm -f "$PLIST"
  echo "removed $PLIST"
else
  echo "nothing to remove ($PLIST not present)"
fi
