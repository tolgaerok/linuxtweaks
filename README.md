![Linux Tweaks](https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/FUN/FUN_IMAGES/1744722407588.png)

# 🫟 LinuxTweaks 2026 {#top}

[![Status: Under Development](https://img.shields.io/badge/Status-Under%20Development-orange)](https://github.com/tolgaerok/linuxtweaks)

**🫟  A simple, no-nonsense system update manager for Fedora...**

<img width="500" height="658" alt="image" src="https://github.com/user-attachments/assets/9a1a78ba-f982-416f-87a1-149c7e30b4ad" />


I built this because I was tired of hunting through different tools to check updates. DNF, Flatpak, firmware all scattered. I wanted one place that just works.

## What It Does

- **Real-time update detection**: DNF packages, Flatpak apps, firmware updates all in one view
- **System tray icon**: Lives in your tray, shows red when updates are available
- **One-click upgrades**: Click "Upgrade" and it handles everything
- **Dry-run mode**: See what would change before actually upgrading
- **Automatic checks**: Configurable intervals (1 min to 1 week)
- **Settings that stick**: Configure once, it remembers

## What my package contains: 

📁 Installation Structure
```bash
LinuxTweaks v6.1.68 Installation Structure
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/
├── etc/
│   ├── sudoers.d/
│   │   └── linuxtweaks                           (sudo permissions)
│   ├── systemd/
│   │   └── user-preset/
│   │       └── 50-linuxtweaks.preset             (enable by default)
│   └── xdg/
│       └── autostart/
│           └── linuxtweaks.desktop               (autostart on login)
│
├── usr/
│   ├── bin/
│   │   ├── linuxtweaks                           (main wrapper)
│   │   ├── linuxtweaks-autostart                 (autostart wrapper)
│   │   ├── linuxtweaks-check                     (check wrapper)
│   │   └── linuxtweaks-upgrade                   (upgrade wrapper)
│   │
│   ├── lib/
│   │   └── linuxtweaks/
│   │       ├── lib/
│   │       │   ├── check.sh                      (check updates logic)
│   │       │   ├── common.sh                     (common functions)
│   │       │   ├── config.sh                     (config helpers)
│   │       │   └── upgrade.sh                    (upgrade logic)
│   │       │
│   │       └── tray/
│   │           ├── __init__.py                   (package init)
│   │           ├── __main__.py                   (entry point)
│   │           ├── app.py                        (main tray app)
│   │           ├── tray.py                       (tray icon)
│   │           ├── settings_dialog.py            (user settings)
│   │           ├── about_dialog.py               (about dialog)
│   │           ├── log_dialog.py                 (log viewer)
│   │           ├── config.py                     (config reader/writer)
│   │           ├── utils.py                      (utilities)
│   │           ├── check_theme.py                (theme handler)
│   │           └── linuxtweaks-icon.png          (icon asset)
│   │
│   └── lib/systemd/user/
│       ├── linuxtweaks.timer                     (30min timer, user-configurable)
│       ├── linuxtweaks.service                   (check updates service)
│       └── linuxtweaks-autostart.service         (tray autostart service)
│
├── usr/share/
│   ├── doc/
│   │   └── linuxtweaks/
│   │       └── README.md                         (documentation)
│   │
│   └── licenses/
│       └── linuxtweaks/
│           └── LICENSE                           (MIT license)
│
└── ~/.config/ (user-specific, created at runtime)
    ├── linuxtweaks/
    │   └── config                                (app settings)
    └── systemd/user/
        └── linuxtweaks.timer                     (user timer override, 1h default)


SERVICE ARCHITECTURE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

System Services (in /usr/lib/systemd/user/):
├── linuxtweaks.timer
│   └── Runs every 30 minutes (default, user-configurable via Settings)
│       └── Triggers: linuxtweaks.service
│
├── linuxtweaks.service
│   └── Runs /usr/lib/linuxtweaks/lib/check.sh
│       └── Checks for: DNF, Flatpak, Firmware, Distrobox updates
│
└── linuxtweaks-autostart.service
    └── Runs /usr/bin/linuxtweaks (tray app)
        └── Starts on: graphical-session.target (login)


FLOW DIAGRAM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

User Login
    ↓
50-linuxtweaks.preset enables services
    ↓
┌───────────────────────────────────────┐
│ linuxtweaks-autostart.service starts  │
│ Runs: /usr/bin/linuxtweaks            │
│ → Starts systemctl services           │
│ → Launches: python3 -m tray           │
│ → Shows: System tray icon             │
└───────────────────────────────────────┘
    ↓
┌───────────────────────────────────────┐
│ linuxtweaks.timer runs every 1h       │
│ (default 30min, user-configurable)    │
└───────────────────────────────────────┘
    ↓
Every interval:
    ↓
┌───────────────────────────────────────┐
│ linuxtweaks.service triggered         │
│ Runs: /usr/lib/linuxtweaks/lib/check.sh
│ Checks all update sources             │
│ Updates tray icon with results        │
│ Shows notifications (if enabled)      │
└───────────────────────────────────────┘
    ↓
User clicks Settings → Changes interval to 1h/6h/12h/etc
    ↓
settings_dialog.py:
  1. Saves CHECK_INTERVAL to ~/.config/linuxtweaks/config
  2. Creates ~/.config/systemd/user/ if missing
  3. Copies system timer to user override location
  4. Modifies OnUnitActiveSec=1h (or selected interval)
  5. Runs: systemctl --user daemon-reload
  6. Runs: systemctl --user restart linuxtweaks.timer
    ↓
Timer now runs at new interval!


CONFIGURATION LEVELS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

System Level (immutable):
  /usr/lib/systemd/user/linuxtweaks.timer
    - OnBootSec=30s (initial check on login)
    - OnUnitActiveSec=30min (default interval)
    - Persistent=true (survives suspend/resume)

User Level (runtime override):
  ~/.config/systemd/user/linuxtweaks.timer (created on first settings change)
    - User's chosen interval (1h, 6h, 12h, etc)
    - Overrides system timer

App Config:
  ~/.config/linuxtweaks/config
    - CHECK_INTERVAL=3600 (user's choice in seconds)
    - Update options (DNF, Flatpak, Firmware, Distrobox)
    - Cleanup options (orphans, cache, journal)
    - Notification settings


FILE PERMISSIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Wrapper scripts (755):
  /usr/bin/linuxtweaks
  /usr/bin/linuxtweaks-autostart
  /usr/bin/linuxtweaks-check
  /usr/bin/linuxtweaks-upgrade

Library scripts (755):
  /usr/lib/linuxtweaks/lib/*.sh

Python files (755):
  /usr/lib/linuxtweaks/tray/*.py

Config files (644):
  /etc/sudoers.d/linuxtweaks (440)
  /etc/xdg/autostart/linuxtweaks.desktop
  /etc/systemd/user-preset/50-linuxtweaks.preset
  /usr/lib/systemd/user/*.{timer,service}

Documentation (644):
  /usr/share/doc/linuxtweaks/README.md
  /usr/share/licenses/linuxtweaks/LICENSE


UNINSTALL CLEANUP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

When removed with: sudo dnf remove linuxtweaks

%postun removes:
  ✓ System services (via %systemd_user_postun)
  ✓ All processes: python3 -m tray, check.sh
  ✓ User config: ~/.config/linuxtweaks/
  ✓ User timer override: ~/.config/systemd/user/linuxtweaks.timer
  ✓ Systemd daemon reload

Result: Clean uninstall, zero traces left
```


## Installation

### Add the Repository

```bash
echo -e "[linuxtweaks]\nname=LinuxTweaks Repository\nbaseurl=http://100.83.30.114:8080/linuxtweaks/\nenabled=1\ngpgcheck=1\ngpgkey=http://100.83.30.114:8080/linuxtweaks/RPM-GPG-KEY" | sudo tee /etc/yum.repos.d/linuxtweaks.repo > /dev/null
```

## 👍 Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/LINUXTWEAKS/POST-INSTALL/install-linuxtweaks.sh | bash
```

### 📥 Install (Clean Slate)

Clean up any old installations first (safe on fresh installs):

```bash
# Stop any old/new services
systemctl --user stop linuxtweaks* 2>/dev/null || true
systemctl --user disable linuxtweaks* 2>/dev/null || true
systemctl --user reset-failed 2>/dev/null || true

# Kill any running processes
pkill -9 -f "python3 -m tray" 2>/dev/null || true
pkill -9 -f "tray.py" 2>/dev/null || true
pkill -9 -f "linuxtweaks" 2>/dev/null || true

# Remove old user-location files (backward compat)
rm -f ~/.config/systemd/user/linuxtweaks*.service
rm -f ~/.config/systemd/user/linuxtweaks*.timer
rm -f ~/.config/systemd/user/app-linuxtweaks@autostart.service
rm -rf ~/.local/lib/linuxtweaks
rm -f ~/.local/bin/linuxtweaks*

# Remove new v6.1.68x user-specific files
rm -rf ~/.config/linuxtweaks
rm -f ~/.config/systemd/user/linuxtweaks.timer

# Reload systemd
systemctl --user daemon-reload

echo "✅ Old installation cleaned up! Enjoy brother"
```

Then install fresh:

<img width="1891" height="609" alt="image" src="https://github.com/user-attachments/assets/63ac9918-7232-43e4-ba92-392542129b89" />


```bash
sudo dnf clean all
sudo dnf check-update
sudo dnf install linuxtweaks -y
```

### 📋 Verify Installation

```bash
dnf info linuxtweaks
```

### 🪓 Uninstall

<img width="1902" height="547" alt="image" src="https://github.com/user-attachments/assets/5f6281e6-d162-4142-a250-54e014c81ada" />

```bash
sudo dnf remove linuxtweaks -y
```

### 📅 View Changelog

```bash
rpm -q --changelog linuxtweaks
```

## Usage

### 🔑 Start the App

<img width="239" height="81" alt="image" src="https://github.com/user-attachments/assets/8a61b967-1b55-4d2a-93bd-fc762305132c" />

```bash
linuxtweaks
```

The app appears in your system tray. Right click the icon to see options.

### From Command Line

```bash
# Manual update check
bash /usr/lib/linuxtweaks/lib/check.sh

# View current state
cat /run/user/$(id -u)/linuxtweaks/dnf_count
```

### Settings
<img width="258" height="295" alt="image" src="https://github.com/user-attachments/assets/de698d80-7f6a-44bc-bfaa-ba2b35735c3c" />

Click **⚙ Settings** in the tray menu to:
- Set check interval (1 min to 1 week)
- Enable/disable Flatpak, Firmware, Distrobox updates
- Auto-answer "yes" to upgrade prompts
- Customize DNF flags (`--best`, `--allowerasing`, etc.)

<img width="500" height="658" alt="image" src="https://github.com/user-attachments/assets/eb095833-16de-477a-ad1d-be6303fceed7" />



## Configuration

Settings stored in: `~/.config/linuxtweaks/config`

```ini
CHECK_INTERVAL=1800         # Time between checks (seconds)
AUTO_YES=true               # Auto-answer yes to upgrades
FLATPAK_USE_SUDO=true
USE_DISTRO_SYNC=true
DNF_ARGUMENTS=--best
INCLUDE_FLATPAK=true
INCLUDE_FIRMWARE=true
INCLUDE_DISTROBOX=true
NOTIFICATIONS=true
CLEANUP_ORPHANS=true
CLEANUP_CACHE=true
CLEANUP_JOURNAL=true
```

## How It Works

1. **Systemd Timer**: Runs check every minute (configurable)
2. **Check Script**: Queries DNF, Flatpak, fwupd for updates
3. **State Files**: Stores counts in `/run/user/$(id -u)/linuxtweaks/`
4. **Tray App**: Reads state, shows icon color (green=up-to-date, red=updates available)
5. **Upgrade**: Runs full upgrade with your configured DNF flags

## 🛠️ Troubleshooting

**App won't start?**
```bash
systemctl --user --no-pager status linuxtweaks.timer
journalctl --user --no-pager -u linuxtweaks.service
```

**Updates not detecting?**
```bash
bash /usr/lib/linuxtweaks/lib/check.sh
ls /run/user/$(id -u)/linuxtweaks/
```

**Upgrade conflicts?**
Go to Settings and add `--allowerasing` to Custom DNF Flags.

## Built For

- **OS**: Fedora 44+
- **Desktop**: KDE Plasma
- **Language**: Python (PyQt5)
- **Init**: Systemd

## Author

**Tolga Erok**  
Hamilton Hill, Perth, Western Australia  
📧 kingtolga@gmail.com  
🐙 [My other GitHub repo's](https://github.com/tolgaerok)

---

## Other Repositories

<div align="center">
  <table style="border-collapse: collapse; width: 100%; border: none;">
    <tr>
      <td align="center" style="border: none;">
        <a href="https://github.com/tolgaerok/fedora-tolga">
          <img src="https://flathub.org/img/distro/fedora.svg" alt="Fedora" style="width: 100%;">
          <br>Fedora
        </a>
      </td>
      <td align="center" style="border: none;">
        <a href="https://github.com/tolgaerok/Debian-tolga">
          <img src="https://flathub.org/img/distro/debian.svg" alt="Debian" style="width: 100%;">
          <br>Debian
        </a>
      </td>
    </tr>
  </table>
</div>

## Stats

<div align="center">
  <a href="https://git.io/streak-stats" target="_blank">
    <img src="http://github-readme-streak-stats.herokuapp.com?user=tolgaerok&theme=dark&background=000000" alt="GitHub Streak">
  </a>
  <br>
  <a href="https://github.com/anuraghazra/github-readme-stats" target="_blank">
    <img src="https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/FUN/FUN_IMAGES/1744722407588.png" alt="Top Languages">
  </a>
</div>

---

[⬆ Back to Top](#top)

---

**Made for my own system. Works great on yours too.**
