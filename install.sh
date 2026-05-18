#!/usr/bin/env bash
# Install mathlock on the current user's Xubuntu/XFCE system.
#
# - Installs /usr/local/bin/mathlock (the locker).
# - Seeds ~/.config/mathlock/config.json if missing (won't overwrite).
# - Installs an autostart entry that runs `xss-lock -- mathlock`.
# - Installs the `xss-lock` package if absent.
# - Disables xfce4-screensaver's built-in password lock so its only role
#   becomes drawing the screensaver visuals.
#
# After install, log out and back in (or start xss-lock manually in the
# current session) for the autostart entry to take effect.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== mathlock installer ==="

if ! command -v xss-lock >/dev/null 2>&1; then
    echo "Installing xss-lock..."
    sudo apt update
    sudo apt install -y xss-lock
fi

echo "Installing /usr/local/bin/mathlock..."
sudo install -m 755 "$REPO_DIR/bin/mathlock" /usr/local/bin/mathlock

echo "Installing autostart entry..."
mkdir -p "$HOME/.config/autostart"
install -m 644 "$REPO_DIR/autostart/mathlock-xss.desktop" \
    "$HOME/.config/autostart/mathlock-xss.desktop"

mkdir -p "$HOME/.config/mathlock"
if [ ! -f "$HOME/.config/mathlock/config.json" ]; then
    install -m 600 "$REPO_DIR/examples/config.json" \
        "$HOME/.config/mathlock/config.json"
    echo "Wrote $HOME/.config/mathlock/config.json (edit to taste)."
else
    echo "$HOME/.config/mathlock/config.json already exists; leaving it alone."
fi

# Disable xfce4-screensaver's built-in password lock dialog. The screensaver
# visuals still play; the lock-on-activate behavior is what gets turned off,
# leaving xss-lock to do the actual locking via mathlock.
#
# Key name may vary by xfce4-screensaver version; verify afterward with:
#     xfconf-query -c xfce4-screensaver -lv
echo "Disabling xfce4-screensaver's built-in lock..."
xfconf-query -c xfce4-screensaver -p /lock/enabled -s false --create -t bool || true

cat <<'EOF'

Done.

To activate without rebooting, run in the graphical session:
    xss-lock --transfer-sleep-lock -- /usr/local/bin/mathlock &

Otherwise the autostart entry will pick it up on next login.

Knobs:
  - idle timeout (minutes):
      xfconf-query -c xfce4-screensaver -p /saver/idle-activation/delay -s <N>
  - active problem set / parent override:
      edit ~/.config/mathlock/config.json
EOF
