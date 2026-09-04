# ![1744722407588](image/README/1744722407588.png)Linux Tweaks - UNDER CONSTRUCTION !!!!

---

# LinuxTweaks v6.0.2

**A simple, no-nonsense system update manager for Fedora.**

I built this because I was tired of hunting through different tools to check updates. DNF, Flatpak, firmware—all scattered. I wanted one place that just works.

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
#### don't use echo -e "[linuxtweaks]\nname=LinuxTweaks Repository\nbaseurl=http://100.83.30.114:8080/linuxtweaks/\nenabled=1\ngpgcheck=0" | sudo tee /etc/yum.repos.d/linuxtweaks.repo > /dev/null

# NEW
echo -e "[linuxtweaks]\nname=LinuxTweaks Repository\nbaseurl=http://100.83.30.114:8080/linuxtweaks/\nenabled=1\ngpgcheck=1\ngpgkey=http://100.83.30.114:8080/linuxtweaks/RPM-GPG-KEY" | sudo tee /etc/yum.repos.d/linuxtweaks.repo > /dev/null
```

### Install

```bash
sudo dnf install linuxtweaks
```

### Verify Installation

```bash
dnf info linuxtweaks
```

### Check Available Repositories

```bash
sudo dnf repolist | grep linuxtweaks
```

## Usage

### Start the App

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
- Customize DNF flags (--best, --allowerasing, etc.)

## Repository Information

### View Repository List

```bash
sudo dnf repolist
```

### View All Packages

```bash
sudo dnf search linuxtweaks
```

### Check for Updates

```bash
sudo dnf check-update
```

## Configuration

Settings stored in: `~/.config/linuxtweaks/config`

```ini
CHECK_INTERVAL=1800         => time intervals
AUTO_YES=true
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

## Troubleshooting

**App won't start?**
```bash
# Check systemd service
systemctl --user --no-pager status linuxtweaks.timer
journalctl --user --no-pager -u linuxtweaks.service
```

**Updates not detecting?**
```bash
# Manual check
bash /usr/lib64/linuxtweaks/lib/check.sh

# Check state files
ls /run/user/$(id -u)/linuxtweaks/
```

**Upgrade conflicts?**
Go to Settings => Custom DNF Flags and add: `--allowerasing`

## Built For

- **OS**: Fedora 44+
- **Desktop**: KDE Plasma
- **Language**: Python (PyQt5)
- **Init System**: Systemd

## Author

**Tolga Erok**  
Hamilton Hill, Perth, Western Australia  
Email: kingtolga@gmail.com  
GitHub: https://github.com/tolgaerok/linuxtweaks

---

**Made for my own system. Works great on yours too.**
