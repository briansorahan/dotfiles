#!/bin/zsh
#
# One-time setup for the encrypted ~/.zshrc -> OneDrive backup.
# Safe to re-run; it will not overwrite an existing key.

set -euo pipefail

LABEL="local.zshrc-backup"
SRC="$HOME/.zshrc_sensitive"
KEY_DIR="$HOME/.config/age"
KEY_FILE="$KEY_DIR/zshrc-backup.key"
RECIPIENT_FILE="$KEY_DIR/zshrc-backup.pub"
BIN_DIR="$HOME/.local/bin"
SCRIPT="$BIN_DIR/backup-zshrc"
STATE="$HOME/.local/state/zshrc-backup.sha"
CONF="$HOME/.config/zshrc-backup.conf"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG="$HOME/Library/Logs/zshrc-backup.log"

# --- locate age -------------------------------------------------------------
AGE_BIN="$(command -v age || true)"
if [[ -z "$AGE_BIN" ]]; then
  print -u2 "age not found. Install it with:  brew install age"
  exit 1
fi
AGE_KEYGEN="$(command -v age-keygen)"

# --- locate the OneDrive folder ---------------------------------------------
CLOUD="$HOME/Library/CloudStorage"
if [[ -n "${ONEDRIVE_DIR:-}" ]]; then
  OD="$ONEDRIVE_DIR"
else
  OD="$(/usr/bin/find "$CLOUD" -maxdepth 1 -type d -name 'OneDrive*' 2>/dev/null | head -n1)"
fi
if [[ -z "$OD" || ! -d "$OD" ]]; then
  print -u2 "Could not find a OneDrive folder under $CLOUD"
  print -u2 "Re-run with:  ONEDRIVE_DIR=/path/to/OneDrive $0"
  exit 1
fi
DEST_DIR="$OD/Backups/dotfiles"
DEST="$DEST_DIR/zshrc.age"
print "OneDrive target: $DEST"

# --- key --------------------------------------------------------------------
mkdir -p "$KEY_DIR"; chmod 700 "$KEY_DIR"
if [[ -f "$KEY_FILE" ]]; then
  print "Reusing existing key at $KEY_FILE"
else
  "$AGE_KEYGEN" -o "$KEY_FILE" >/dev/null 2>&1
  chmod 600 "$KEY_FILE"
  print "Generated new key at $KEY_FILE"
fi
"$AGE_KEYGEN" -y "$KEY_FILE" > "$RECIPIENT_FILE"
chmod 600 "$RECIPIENT_FILE"

# --- install script and config ----------------------------------------------
mkdir -p "$BIN_DIR" "$DEST_DIR" "${STATE:h}" "${LOG:h}" "${PLIST:h}"

if [[ ! -f "$SCRIPT" ]]; then
  print -u2 "Expected the worker script at $SCRIPT -- copy backup-zshrc there first."
  exit 1
fi
chmod 700 "$SCRIPT"

cat > "$CONF" <<EOF
SRC="$SRC"
AGE_BIN="$AGE_BIN"
RECIPIENT_FILE="$RECIPIENT_FILE"
DEST="$DEST"
STATE="$STATE"
EOF
chmod 600 "$CONF"

# --- launchd agent ----------------------------------------------------------
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>

    <key>ProgramArguments</key>
    <array>
        <string>$SCRIPT</string>
    </array>

    <!-- Fires when the file is written. -->
    <key>WatchPaths</key>
    <array>
        <string>$SRC</string>
    </array>

    <!-- Safety net: re-check every 15 minutes in case a watch is missed. -->
    <key>StartInterval</key>
    <integer>900</integer>

    <!-- Coalesce rapid-fire saves. -->
    <key>ThrottleInterval</key>
    <integer>15</integer>

    <key>RunAtLoad</key>
    <true/>

    <key>StandardOutPath</key>
    <string>$LOG</string>
    <key>StandardErrorPath</key>
    <string>$LOG</string>
</dict>
</plist>
EOF

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
launchctl enable "gui/$(id -u)/$LABEL"

print ""
print "Installed. Public key (safe to share/store anywhere):"
print "  $(<"$RECIPIENT_FILE")"
print ""
print "PRIVATE KEY: $KEY_FILE"
print "  Put a copy in your password manager NOW. Do not put it in OneDrive."
print ""
print "Restore with:"
print "  age -d -i $KEY_FILE -o ~/zshrc.restored '$DEST'"
print ""
print "Log: $LOG"
