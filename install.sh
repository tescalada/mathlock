#!/usr/bin/env bash
# Install mathlock for the current user on Xubuntu/XFCE.
#
# Per-user install — no sudo. Everything lives under $HOME.
#
# Architecture: xfce4-screensaver shows the screensaver visuals on idle
# (unchanged). A small daemon (~/.local/bin/mathlock-launcher) subscribes
# to xfce4-screensaver's `ActiveChanged` DBus signal and launches mathlock
# fullscreen + input-grabbed when the saver activates.
#
# - Installs ~/.local/bin/mathlock (the locker).
# - Installs ~/.local/bin/mathlock-launcher (the DBus listener daemon).
# - Seeds ~/.config/mathlock/config.json if missing (won't overwrite).
# - Installs an autostart entry that runs the launcher on login.
# - Disables xfce4-screensaver's built-in password lock so its only role
#   becomes drawing the screensaver visuals.
#
# After install, log out and back in (or start the launcher manually in
# the current session) for the autostart entry to take effect.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MATHLOCK_BIN="$HOME/.local/bin/mathlock"
MATHLOCK_LAUNCHER="$HOME/.local/bin/mathlock-launcher"

echo "=== mathlock installer ==="

echo "Installing $MATHLOCK_BIN..."
mkdir -p "$HOME/.local/bin"
install -m 755 "$REPO_DIR/bin/mathlock" "$MATHLOCK_BIN"

echo "Installing $MATHLOCK_LAUNCHER..."
install -m 755 "$REPO_DIR/bin/mathlock-launcher" "$MATHLOCK_LAUNCHER"

echo "Installing autostart entry..."
mkdir -p "$HOME/.config/autostart"
sed "s|@MATHLOCK_LAUNCHER@|$MATHLOCK_LAUNCHER|g" \
    "$REPO_DIR/autostart/mathlock.desktop" \
    > "$HOME/.config/autostart/mathlock.desktop"
chmod 644 "$HOME/.config/autostart/mathlock.desktop"

mkdir -p "$HOME/.config/mathlock"
if [ ! -f "$HOME/.config/mathlock/config.json" ]; then
    install -m 600 "$REPO_DIR/examples/config.json" \
        "$HOME/.config/mathlock/config.json"
    echo "Wrote $HOME/.config/mathlock/config.json (edit to taste)."
else
    echo "$HOME/.config/mathlock/config.json already exists; leaving it alone."
fi

# Disable xfce4-screensaver's lock-on-screensaver-activation. The saver visuals
# still play; only the password dialog is suppressed, leaving mathlock to do
# the actual locking (via mathlock-launcher catching the DBus signal).
echo "Disabling xfce4-screensaver's built-in lock..."
xfconf-query -c xfce4-screensaver -p /lock/saver-activation/enabled \
    -s false --create -t bool

cat <<EOF

Done.

To activate without rebooting, run in the graphical session:
    $MATHLOCK_LAUNCHER &

Otherwise the autostart entry will pick it up on next login.

Knobs:
  - idle timeout (minutes):
      xfconf-query -c xfce4-screensaver -p /saver/idle-activation/delay -s <N>
  - active problem set / parent override:
      edit ~/.config/mathlock/config.json
EOF
