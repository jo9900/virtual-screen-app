#!/bin/bash
# Stops the LaunchAgent and removes everything install.sh added, except the log.
# Safe to run over SSH.
set -euo pipefail

LABEL="local.virtualscreen"
BIN="$HOME/.local/bin/virtual-screen"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
rm -f "$PLIST" "$BIN"

echo "Uninstalled $LABEL. The log is kept at $HOME/Library/Logs/virtual-screen.log"
