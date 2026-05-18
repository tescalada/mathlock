#!/usr/bin/env bash
# Install mathlock for the current user on Xubuntu/XFCE.
#
# Per-user install — only `sudo` is for `apt install xss-lock`. The locker
# itself lands in ~/.local/bin, so no system-wide write is needed.
#
# - Installs ~/.local/bin/mathlock (the locker).
# - Seeds ~/.config/mathlock/config.json if missing (won't overwrite).
# - Installs an autostart entry pointing at ~/.local/bin/mathlock.
# - Installs the `xss-lock` package if absent.
# - Disables xfce4-screensaver's built-in password lock so its only role
#   becomes drawing the screensaver visuals.
#
# After install, log out and back in (or start xss-lock manually in the
# current session) for the autostart entry to take effect.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MATHLOCK_BIN="$HOME/.local/bin/mathlock"

echo "=== mathlock installer ==="

if ! command -v xss-lock >/dev/null 2>&1; then
    echo "Installing xss-lock..."
    sudo apt update
    sudo apt install -y xss-lock
fi

echo "Installing $MATHLOCK_BIN..."
mkdir -p "$HOME/.local/bin"
install -m 755 "$REPO_DIR/bin/mathlock" "$MATHLOCK_BIN"

echo "Installing autostart entry..."
mkdir -p "$HOME/.config/autostart"
sed "s|@MATHLOCK_BIN@|$MATHLOCK_BIN|g" \
    "$REPO_DIR/autostart/mathlock-xss.desktop" \
    > "$HOME/.config/autostart/mathlock-xss.desktop"
chmod 644 "$HOME/.config/autostart/mathlock-xss.desktop"

mkdir -p "$HOME/.config/mathlock"
if [ ! -f "$HOME/.config/mathlock/config.json" ]; then
    install -m 600 "$REPO_DIR/examples/config.json" \
        "$HOME/.config/mathlock/config.json"
    echo "Wrote $HOME/.config/mathlock/config.json (edit to taste)."
else
    echo "$HOME/.config/mathlock/config.json already exists; leaving it alone."
fi

# Disable xfce4-screensaver's lock-on-screensaver-activation. The saver visuals
# still play; only the password dialog is suppressed, leaving xss-lock to do
# the actual locking via mathlock.
echo "Disabling xfce4-screensaver's built-in lock..."
xfconf-query -c xfce4-screensaver -p /lock/saver-activation/enabled \
    -s false --create -t bool

cat <<EOF

Done.

To activate without rebooting, run in the graphical session:
    xss-lock --transfer-sleep-lock -- $MATHLOCK_BIN &

Otherwise the autostart entry will pick it up on next login.

Knobs:
  - idle timeout (minutes):
      xfconf-query -c xfce4-screensaver -p /saver/idle-activation/delay -s <N>
  - active problem set / parent override:
      edit ~/.config/mathlock/config.json
EOF
