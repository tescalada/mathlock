# mathlock

A screensaver/lockscreen layer for Xubuntu/XFCE that asks a math problem instead of a password. Built for parents who'd rather their kid practice `7 × 8 = ?` than enter a password every time they come back to the computer.

## How it works

- `xfce4-screensaver` keeps showing the screensaver visuals on idle (unchanged).
- Its built-in password lock is disabled.
- A small daemon (`mathlock-launcher`) subscribes to `org.xfce.ScreenSaver.ActiveChanged` on the user's session bus. When the screensaver activates, the launcher starts `mathlock` as a subprocess.
- `mathlock` opens fullscreen, grabs keyboard + pointer, and shows a math problem. Digits echo to the screen; letters are kept in a hidden buffer (so a parent can type the override string without the kid seeing it).
- Correct answer (or override string) exits `mathlock` → the lock is gone, desktop is back.

Single daemon. No `xss-lock`, no translator process between them — just one Python listener.

## Requirements

- Xubuntu / XFCE on X11 (not Wayland)
- Python 3.10+ with PyGObject + GTK 3 (already present on a stock Xubuntu install)

## Install

```sh
git clone https://github.com/tescalada/mathlock.git
cd mathlock
./install.sh
```

Per-user install — no sudo required. The locker and the launcher both land in `~/.local/bin/`.

Then either log out and back in, or start the launcher in the current session:

```sh
~/.local/bin/mathlock-launcher &
```

## Configuration

Edit `~/.config/mathlock/config.json`:

```json
{
  "active_set": "mult_to_12",
  "parent_override": "mathlock",
  "problem_sets": {
    "mult_to_12":  { "operations": ["*"], "range": [1, 12] },
    "add_sub_20":  { "operations": ["+", "-"], "range": [1, 20], "no_negative_results": true },
    "mult_to_5":   { "operations": ["*"], "range": [1, 5] }
  }
}
```

- `active_set` — which problem set to draw from. Read fresh each time the locker fires, so changes take effect on the next lock.
- `parent_override` — typing this as the answer always unlocks. Letters don't echo to the screen, so the kid doesn't see what's typed.
- `problem_sets` — define your own:
  - `operations` — any subset of `+`, `-`, `*`.
  - `range` — `[min, max]` for both operands.
  - `no_negative_results` — optional; for subtraction, swap operands so the answer is non-negative.

### Idle timeout

The time before the screensaver (and therefore mathlock) kicks in lives in `xfce4-screensaver`:

```sh
xfconf-query -c xfce4-screensaver -p /saver/idle-activation/delay -s <minutes>
```

## Uninstall

```sh
rm ~/.local/bin/mathlock ~/.local/bin/mathlock-launcher
rm ~/.config/autostart/mathlock.desktop
xfconf-query -c xfce4-screensaver -p /lock/saver-activation/enabled -r
pkill -f mathlock-launcher
```

Leave `~/.config/mathlock/` alone if you want to keep your config.

## License

MIT
