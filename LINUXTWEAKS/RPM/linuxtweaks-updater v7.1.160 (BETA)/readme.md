# 🫟 LinuxTweaks DNF-Updater

**A real system update manager for Fedora that actually works.**

Version 7.1.157 | GPL-3.0-or-later | [GitHub](https://github.com/tolgaerok/linuxtweaks)

---

## What This Is

DNF-Updater is a system tray application that handles package updates for Fedora. It combines DNF packages, Flatpak apps, and firmware updates into one place instead of hunting through different tools.

Built for KDE Plasma on Fedora, it survives suspend/resume cycles (unlike a lot of update tools), shows exactly what needs updating in real time, and lets you run upgrades or just preview what would change.

Set it once, forget about it.

---

## Why You Probably Want This

- **One place for everything**: DNF packages, Flatpak apps, firmware—no more juggling multiple update tools
- **Systemd timers that work**: Survives sleep/suspend without breaking (a real problem with Qt timers)
- **See what's coming**: Real-time detection shows exactly which packages need updates
- **Your choice how to upgrade**: One-click upgrade or dry-run to preview changes
- **Set an interval and go**: Checks automatically (30 minutes default, configurable)
- **Built in, stays out of the way**: System tray integration means it runs quietly in the background

---

## Install

**From RPM (Fedora 44+):**
```bash
sudo dnf install linuxtweaks-dnf-updater-7.1.157-1.fc44.noarch.rpm
```

Then launch from your applications menu or run:
```bash
dnf-updater
```

First launch sets up the systemd timer and autostart. Nothing else needed.

---

## How to Use

**First time:**
1. Launch `dnf-updater` from applications or terminal
2. The app appears in your system tray (bottom right by default in KDE)
3. Systemd timer starts automatically for periodic checks

**Checking for updates:**
- Click the tray icon to see what needs updating
- Current count badge on the icon (red dot = updates available, green checkmark = up to date)

**Running an upgrade:**
- Click "📥 Run DNF-Updater" from the tray menu
- A terminal opens showing the upgrade process
- You'll be prompted to confirm before installing anything
- Post-upgrade cleanup (orphaned packages, stale cache) runs automatically

**Adjusting settings:**
- Right-click the tray icon
- Configure check interval (1 hour, 6 hours, 1 day, 1 week)
- Toggle notifications on/off

---

## What Happens Under the Hood

**On launch:**
- Checks for existing instance (prevents multiple tray windows)
- Enables systemd user services for automatic checking
- Loads last known update state

**When checking for updates:**
- Runs `dnf check-update` to scan available DNF updates
- Runs `flatpak remote-ls --updates` for Flatpak updates
- Shows results in the tray tooltip

**When upgrading:**
- Prevents multiple concurrent upgrades (lock file with process verification)
- Runs `dnf upgrade -y` for packages
- Runs `flatpak update -y` for apps
- Cleans DNF and Flatpak caches
- Removes orphaned packages if any exist
- Restarts the tray app to refresh the UI
- Sends desktop notifications at key points

---

## What's Installed

```
/usr/bin/dnf-updater                    Main launcher (tray app)
/usr/bin/dnf-updater-check              Background check script
/usr/bin/dnf-updater-upgrade            Upgrade runner (called from tray)

/usr/lib/dnf-updater/lib/               Core shell scripts
  ├── check.sh                          Scans for available updates
  ├── full_upgrade.sh                   Orchestrates the upgrade
  ├── update.sh                         Runs dnf and flatpak updates
  ├── orphan_packages.sh                Removes unused packages
  ├── packages_cache.sh                 Cleans caches
  ├── restart_services.sh               Restarts services after upgrade
  └── [others]                          Firmware, kernel reboot, etc.

/usr/lib/dnf-updater/tray/              Python tray application
  └── tray.py                           PyQt5 system tray UI

/usr/lib/systemd/user/                  Background timers
  ├── dnf-updater-check.timer           Runs checks on schedule
  ├── dnf-updater-check.service         The check script
  └── dnf-updater-autostart.service     Starts tray on login

/etc/sudoers.d/dnf-updater              Allows password-less sudo for updates
/etc/xdg/autostart/                     Desktop autostart on login
/usr/share/applications/                Application menu entry
```

---

## Requirements

- **Fedora 44+** (may work on RHEL-based systems)
- **KDE Plasma** (or any DE with a system tray)
- **Python 3** with PyQt5
- **sudo** access (for package management)
- Membership in the `wheel` group (passwordless sudo)

---

## Configuration

All settings are stored in `~/.local/state/dnf-updater/` after first run:
- `check_interval` — Time between automatic checks (default: 1800 seconds = 30 minutes)
- `notifications_enabled` — Desktop notification toggle (default: enabled)
- `last_updates_check_*` — Cache files for update lists
- `last_update_run` — Date of last upgrade

---

## Troubleshooting

**Multiple instances won't launch:**
- If the tray app is already open, clicking the launcher notifies you instead of opening a second window
- If an upgrade is running, clicking launcher shows a notification

**Upgrade blocked with "already running":**
- A previous upgrade may have crashed, leaving a stale lock
- The app detects this and cleans up automatically on next run
- You'll get a desktop notification if this happens

**Notifications aren't appearing:**
- Check that `notify-send` is installed: `dnf install libnotify`
- Toggle notifications off then back on in the tray menu

**Systemd timer not working:**
- First launch should enable it automatically
- Manual enable: `systemctl --user enable dnf-updater-check.timer`
- Manual start: `systemctl --user start dnf-updater-check.timer`

---

## What Changed in 7.1.157

- Fixed debug spam from tray app
- Improved stale lock detection (process verification with PID)
- Added instance detection in main launcher
- Desktop notifications for all critical events
- Better handling of already-running upgrades
- Enhanced user feedback with notification icons

---

## License

GPL-3.0-or-later

---

## Author

**Tolga Erok**  
📧 kingtolga@gmail.com  
📡 [github.com/tolgaerok/linuxtweaks](https://github.com/tolgaerok/linuxtweaks)

Built in Hamilton Hill, Western Australia for Fedora 44 on KDE Plasma.
