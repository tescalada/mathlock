# mathlock

A screensaver/lockscreen layer for Xubuntu/XFCE that asks a math problem instead of a password. Built for parents who'd rather their kid practice `7 × 8 = ?` than enter a password every time they come back to the computer.

## How it works

- `xfce4-screensaver` keeps showing the screensaver visuals on idle (unchanged).
- Its built-in password lock is disabled.
- `xss-lock` runs in the background and launches `mathlock` whenever the screensaver activates.
- When the user wakes the screen, `mathlock` is already there waiting — fullscreen, keyboard and pointer grabbed.
- A correct answer (or the configured override string) exits `mathlock`, which `xss-lock` treats as a successful unlock.

## Requirements

- Xubuntu / XFCE on X11 (not Wayland)
- Python 3.10+ with PyGObject + GTK 3 (already present on a stock Xubuntu install)
- `xss-lock` (the installer pulls it in via apt)

## Install

```sh
git clone https://github.com/tescalada/mathlock.git
cd mathlock
./install.sh
```

Then either log out and back in, or start it for the current session:

```sh
xss-lock --transfer-sleep-lock -- /usr/local/bin/mathlock &
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
- `parent_override` — typing this as the answer always unlocks. Useful when the kid is stuck or when an adult needs in.
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
sudo rm /usr/local/bin/mathlock
rm ~/.config/autostart/mathlock-xss.desktop
xfconf-query -c xfce4-screensaver -p /lock/enabled -s true
# kill any running xss-lock so it doesn't try to launch a now-missing locker:
pkill xss-lock
```

Leave `~/.config/mathlock/` alone if you want to keep your config.

## License

MIT
