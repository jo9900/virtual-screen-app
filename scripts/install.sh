#!/bin/bash
# Builds virtual-screen and installs it as a LaunchAgent for the current user.
# Any arguments are passed to virtual-screen, e.g. --resolution 3840x2160.
# Run from a logged-in desktop session (Terminal), not over SSH.
set -euo pipefail

LABEL="local.virtualscreen"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN="$HOME/.local/bin/virtual-screen"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG="$HOME/Library/Logs/virtual-screen.log"
DOMAIN="gui/$(id -u)"

swift build -c release --package-path "$ROOT"
"$ROOT/.build/release/virtual-screen" "$@" --dry-run >/dev/null

mkdir -p "$(dirname "$BIN")" "$(dirname "$PLIST")" "$(dirname "$LOG")"

if launchctl print "$DOMAIN/$LABEL" >/dev/null 2>&1; then
    launchctl bootout "$DOMAIN/$LABEL"
    for _ in $(seq 50); do
        launchctl print "$DOMAIN/$LABEL" >/dev/null 2>&1 || break
        sleep 0.1
    done
fi

install -m 755 "$ROOT/.build/release/virtual-screen" "$BIN"

{
    cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>$BIN</string>
EOF
    for arg in "$@"; do
        printf '        <string>%s</string>\n' "$arg"
    done
    cat <<EOF
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>
    <key>ThrottleInterval</key>
    <integer>10</integer>
    <key>LimitLoadToSessionType</key>
    <string>Aqua</string>
    <key>ProcessType</key>
    <string>Interactive</string>
    <key>StandardOutPath</key>
    <string>$LOG</string>
    <key>StandardErrorPath</key>
    <string>$LOG</string>
</dict>
</plist>
EOF
} > "$PLIST"
plutil -lint "$PLIST" >/dev/null

launchctl bootstrap "$DOMAIN" "$PLIST"

echo "Installed $LABEL ($("$BIN" "$@" --dry-run))"
echo "Log:  $LOG"
echo "Stop: launchctl bootout $DOMAIN/$LABEL"
