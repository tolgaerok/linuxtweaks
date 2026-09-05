![Linux Tweaks](https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/FUN/FUN_IMAGES/1744722407588.png)

# 🫟 LinuxTweaks 2026 {#top}

[![Status: Under Development](https://img.shields.io/badge/Status-Under%20Development-orange)](https://github.com/tolgaerok/linuxtweaks)

**A simple, no-nonsense system update manager for Fedora.**

I built this because I was tired of hunting through different tools to check updates. DNF, Flatpak, firmware all scattered. I wanted one place that just works.

## What It Does

- **Real-time update detection**: DNF packages, Flatpak apps, firmware updates all in one view
- **System tray icon**: Lives in your tray, shows red when updates are available
- **One-click upgrades**: Click "Upgrade" and it handles everything
- **Dry-run mode**: See what would change before actually upgrading
- **Automatic checks**: Configurable intervals (1 min to 1 week)
- **Settings that stick**: Configure once, it remembers

## Installation

### Add the Repository

```bash
echo -e "[linuxtweaks]\nname=LinuxTweaks Repository\nbaseurl=http://100.83.30.114:8080/linuxtweaks/\nenabled=1\ngpgcheck=1\ngpgkey=http://100.83.30.114:8080/linuxtweaks/RPM-GPG-KEY" | sudo tee /etc/yum.repos.d/linuxtweaks.repo > /dev/null
```

### 📥 Install (Clean Slate)

Clean up any old installations first (safe on fresh installs):

```bash
# Stop any old services
systemctl --user stop linuxtweaks* 2>/dev/null || true
systemctl --user disable linuxtweaks* 2>/dev/null || true
systemctl --user reset-failed 2>/dev/null || true

# Kill any running processes
pkill -9 -f "tray.py" 2>/dev/null || true
pkill -9 -f "linuxtweaks" 2>/dev/null || true

# Remove old user-location files
rm -f ~/.config/systemd/user/linuxtweaks*.service
rm -f ~/.config/systemd/user/linuxtweaks*.timer
rm -f ~/.config/systemd/user/app-linuxtweaks@autostart.service
rm -rf ~/.config/linuxtweaks
rm -rf ~/.local/lib/linuxtweaks
rm -f ~/.local/bin/linuxtweaks*

# Reload systemd
systemctl --user daemon-reload

echo "✅ Old installation cleaned up! Enjoy brother"
```

Then install fresh:

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

```bash
sudo dnf remove linuxtweaks -y
```

### 📅 View Changelog

```bash
rpm -q --changelog linuxtweaks
```

## Usage

### 🔑 Start the App

```bash
linuxtweaks
```

The app appears in your system tray. Click the icon to see options.

### From Command Line

```bash
# Manual update check
bash /usr/lib64/linuxtweaks/lib/check.sh

# View current state
cat /run/user/$(id -u)/linuxtweaks/dnf_count
```

### Settings

Click **⚙ Settings** in the tray menu to:
- Set check interval (1 min to 1 week)
- Enable/disable Flatpak, Firmware, Distrobox updates
- Auto-answer "yes" to upgrade prompts
- Customize DNF flags (`--best`, `--allowerasing`, etc.)

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
bash /usr/lib64/linuxtweaks/lib/check.sh
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
