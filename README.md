<div align="center">

[![Version](https://img.shields.io/badge/Version-8.1.2-1e81ac)](https://github.com/tolgaerok/linuxtweaks)
[![Fedora](https://img.shields.io/badge/Fedora-44%2B-51A2DA?logo=fedora&logoColor=white)](https://fedoraproject.org)
[![KDE Plasma](https://img.shields.io/badge/KDE_Plasma-6-1D99F3?logo=kde&logoColor=white)](https://kde.org/plasma-desktop)
[![Python](https://img.shields.io/badge/Python-3-3776AB?logo=python&logoColor=white)](https://www.python.org)
[![PyQt5](https://img.shields.io/badge/PyQt5-GUI-41CD52?logo=qt&logoColor=white)](https://www.riverbankcomputing.com/software/pyqt)
[![Bash](https://img.shields.io/badge/Bash-scripts-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash)

[![RPM](https://img.shields.io/badge/RPM-GPG_signed-2e3440?logo=gnuprivacyguard&logoColor=white)](#installation)
[![License](https://img.shields.io/badge/License-GPL--3.0--or--later-blue)](https://github.com/tolgaerok/linuxtweaks/blob/main/LICENSE)
[![Status](https://img.shields.io/badge/Status-Active-brightgreen)](https://github.com/tolgaerok/linuxtweaks)
[![Last commit](https://img.shields.io/github/last-commit/tolgaerok/linuxtweaks)](https://github.com/tolgaerok/linuxtweaks/commits/main)
[![Stars](https://img.shields.io/github/stars/tolgaerok/linuxtweaks?style=flat)](https://github.com/tolgaerok/linuxtweaks/stargazers)

</div>

----------------

![Linux Tweaks](https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/FUN/FUN_IMAGES/1744722407588.png)
[![Status: Under Development](https://img.shields.io/badge/Status-Under%20Development-orange)](https://github.com/tolgaerok/linuxtweaks)

# 🫟 LinuxTweaks 2026 {#top}


**🫟 My one app for keeping Fedora up to date and running well.**

It started as my update manager, because I was sick of hunting through different tools to check for updates. DNF here, Flatpak there. Then my tweak scripts moved in, one tab each. Now it's one place for all of it, and it just works.

### The tray icon and app


<img width="730" height="707" alt="image" src="https://github.com/user-attachments/assets/dae91ae8-89c4-4a63-9461-bad671bbfde3" />
<img width="770" height="797" alt="image" src="https://github.com/user-attachments/assets/2d4c4c51-4c46-4382-baf3-30906675f62b" />
<img width="890" height="812" alt="image" src="https://github.com/user-attachments/assets/2c017dfe-a325-4901-931b-455c6fca0b82" />
<img width="852" height="1027" alt="image" src="https://github.com/user-attachments/assets/220a035d-e202-4ea0-a31b-b830f8cf27ad" />
<img width="389" height="224" alt="image" src="https://github.com/user-attachments/assets/3fa4476d-7c39-40ab-a5ea-73a6a03fb755" />

<img width="980" height="184" alt="tray-badges-and-icons-dark" src="https://github.com/user-attachments/assets/542c928b-db3f-4867-81d0-3b4f2f231d55" />

## What it does

**LinuxTweaks** sits in your system tray. Left click it for the window, every part is its own tab.

### 🫟 Updates

- **Checks in the background.** DNF and Flatpak, every 30 minutes unless you pick something else, and straight after the PC wakes up
- **Security fixes stand out.** A 🔴 marks them in the tooltip, the popup and the window, with how bad they are. It reads Fedora's own advisories that dnf already downloads, nothing extra goes online
- **What changed in a package.** Everything waiting is in one window, a card per update. Click a DNF one and you get its advisory and its changelog since your version
- **The icon tells you.** Red with a number when updates are waiting, orange when a reboot is needed, green when you're up to date, yellow while it checks
- **Popups with buttons.** *Install all*, *DNF only*, *Flatpak only* or *Later*, which reminds you again in 4 hours
- **Installs when you say so.** In its own window: the steps, a progress bar and dnf's own output as it goes. One password box that says what it's for
- **Cleans up after.** A card for each thing left: reboot for a new kernel, restart services still running old code, remove packages nothing needs, compare changed config files (`.rpmnew`)
- **Weekly maintenance, if you want it.** Cleans the DNF cache, trims the journal, runs SSD TRIM if Fedora isn't already doing it
- **Keep logs up to.** How much disk the system journal may take. 500 MB holds weeks, Fedora lets it grow to 4 GB

### 💽 Drives

Every real drive on a card, with its I/O scheduler and read-ahead and a dropdown to change each one. A change works straight away and stays after a reboot, for that exact drive. This used to be my LinuxTweaks-IO app.

### 🧠 Memory

Compressed swap in RAM (zram) and how eagerly Linux uses it: size, compression and swappiness, with **Recommended for this pc** and a **What these mean** button that explains every setting in plain words. Under it, **Desktop tweaks**: smooth big file copies, more file watchers for big projects, and a safety net for kernel crashes.

### 🌐 Network

What your connection uses right now, and switches for faster TCP (BBR), bigger buffers, CAKE on Wi-Fi and wired, Wi-Fi power saving off and IPv6 off. Every switch says what it does.

### 🐧 Kernels

Every installed kernel, which one you're running and which one boots by default. Make another one the default, remove old ones safely, and pick which new kernels take over when they install, so a Fedora kernel update doesn't push out your CachyOS one.

### 🩺 Health

A quick look over the whole PC: failed services, errors, disk space, memory, crashes, SELinux, packages, the kernel, the logs and autostart, each green, orange or red. Where there's a fix the card has a button for it.

### What it doesn't do

- **No sudo rules, no passwordless root.** Checks run as you. Every change that needs root asks for your password first, through a small helper that only does that one job and checks everything it's handed
- **Nothing changes by itself.** Every tab shows your PC as it is. A tweak only happens when you flip it
- **Signed.** Everything in my repo is signed with my LinuxTweaks key

<img width="1909" height="1022" alt="image" src="https://github.com/user-attachments/assets/a6050385-cdc3-478c-94af-7b40fd16c85b" />
<img width="1165" height="699" alt="image" src="https://github.com/user-attachments/assets/e2b0f145-09a5-45af-bc42-025f2af7c991" />


## Installation

> **Heads up.** My repo runs on my own server over Tailscale (`100.83.30.114`). Your PC needs Tailscale and access to my server to reach it. If it can't, the install stops straight away, tells you what's missing and changes nothing.

### 🔐 First time? Set up Tailscale

Tailscale is a private network between your PCs. It's free for personal use and takes about 5 minutes.

**1.** Make a free account at [tailscale.com](https://tailscale.com). Google, Microsoft or GitHub login all work.

**2.** Add Tailscale's own repo and install it:

```bash
sudo dnf config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
sudo dnf install tailscale
```

**3.** Start it, and have it start with the PC:

```bash
sudo systemctl enable --now tailscaled
```

**4.** Log in. It prints a link, open it in your browser and log in with the account from step 1:

```bash
sudo tailscale up
```

**5.** Send me the email you log in to Tailscale with. I share my repo server with you, you get an email from Tailscale, click accept. You only see my repo server, nothing else of mine, and I can't see your PCs.

**6.** Check you can see it:

```bash
tailscale ping 100.83.30.114
```

`pong` means you're in. Now do the quick install below.

### 👍 Quick install

```bash
curl -fsSL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/LINUXTWEAKS/POST-INSTALL/install-linuxtweaks.sh | bash
```

What it does, in order:

1. Checks it can reach my repo
2. Writes `/etc/yum.repos.d/linuxtweaks.repo` with the signature check on
3. Looks for anything my older apps left behind, shows you the list and asks before removing anything
4. Installs LinuxTweaks, or updates it if you have it. Only my package, the rest of your system is left alone
5. Starts the tray and shows you what's on and what's off

dnf asks once to import my signing key. Its ID is `F75286EAE1540626`.

The same script does a few more things. Put the option after `bash -s --`, everything after the `--` goes to my script. Any questions and the sudo password still come from your keyboard, not the pipe.

Only look, changes nothing:

```bash
curl -fsSL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/LINUXTWEAKS/POST-INSTALL/install-linuxtweaks.sh | bash -s -- --check
```

Only clear out what my older apps left behind. Shows you the list and asks first:

```bash
curl -fsSL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/LINUXTWEAKS/POST-INSTALL/install-linuxtweaks.sh | bash -s -- --cleanup
```

Uninstall it. Asks first, then asks about the repo file:

```bash
curl -fsSL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/LINUXTWEAKS/POST-INSTALL/install-linuxtweaks.sh | bash -s -- --remove
```

Fake updates in the tray, to see how it looks. Here 3 dnf and 20 flatpak, one of them a pretend security fix:

```bash
curl -fsSL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/LINUXTWEAKS/POST-INSTALL/install-linuxtweaks.sh | bash -s -- --fake 3 20
```

Put the real update list back after a fake test:

```bash
curl -fsSL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/LINUXTWEAKS/POST-INSTALL/install-linuxtweaks.sh | bash -s -- --restore
```

Rather have a copy on your PC? Download it once and run it with any of the options above:

```bash
curl -fsSLO https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/LINUXTWEAKS/POST-INSTALL/install-linuxtweaks.sh
bash install-linuxtweaks.sh --check
```

### 🖖 Or by hand

Add my repo:

```bash
echo -e "[linuxtweaks]\nname=LinuxTweaks Repository\nbaseurl=http://100.83.30.114:8080/linuxtweaks/\nenabled=1\ngpgcheck=1\ngpgkey=http://100.83.30.114:8080/linuxtweaks/RPM-GPG-KEY\nmetadata_expire=1h" | sudo tee /etc/yum.repos.d/linuxtweaks.repo > /dev/null
```

Install it. dnf asks once to import my key, answer **y**:

```bash
sudo dnf install --refresh linuxtweaks-updater
linuxtweaks-updater
```

From then on it starts by itself when you log in, and new versions come with a normal `sudo dnf upgrade`.

The package and the commands are still called `linuxtweaks-updater` for now, the app itself is LinuxTweaks.

### Coming from dnf-updater, linuxtweaks-dnf-updater, LinuxTweaks 6.x or LinuxTweaks-IO?

Those are all this app under old names. A normal update swaps you over, or run the quick install.

**LinuxTweaks-IO**, my I/O scheduler app, is the 💽 Drives tab now. The update removes the old app for you. Your scheduler picks stay, it's the same rules file, only the old window and its tray icon go.

The older updater versions left stuff behind. Some of it keeps starting the old app next to the new one, and the old sudo rules in `/etc/sudoers.d` handed out root without a password. Uninstalling the old app doesn't always take them with it, a sudo rule you edited gets kept as a `.rpmsave` copy. The quick install looks for all of it. To do only that part:

```bash
curl -fsSL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/LINUXTWEAKS/POST-INSTALL/install-linuxtweaks.sh | bash -s -- --cleanup
```

It shows you the list and asks first. Looking in `/etc/sudoers.d` needs your password, only root can read it.

If your `/etc/yum.repos.d/linuxtweaks.repo` is from before September 2026, run the quick install again. Older copies didn't check my signature.

### 📋 Is it installed?

```bash
curl -fsSL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/LINUXTWEAKS/POST-INSTALL/install-linuxtweaks.sh | bash -s -- --check
```

or just `dnf info linuxtweaks-updater`.

### 🪓 Uninstall

In the window: **About → Uninstall…**, or:

```bash
sudo dnf remove linuxtweaks-updater
```

That takes the app, its timers, the menu launcher and its settings. Your installed packages stay as they are, and so do the tweaks you made. They're your system settings, not part of the app. To undo one by hand, see [Undo a tweak](#undo-a-tweak).

### 📅 Changelog

In the window: **What's new**, or:

```bash
rpm -q --changelog linuxtweaks-updater
```

## Using it

**Left click** the tray icon for the LinuxTweaks window, click again to close it. Drag it to any size, the tabs scroll when they don't fit. Along the bottom on every tab: **What's new**, **Logs** and **About**, which has the full guide under **Help**.

| Tab | What's in it |
|---|---|
| **🫟 Updates** | What's waiting with Install updates…, See them and Check now. Reboot needed or not. Settings: check every, popups, weekly maintenance, keep logs up to |
| **💽 Drives** | A card per drive: scheduler and read-ahead dropdowns, 🔒 *kept at boot* when your pick is saved. Scheduler info explains each one |
| **🧠 Memory** | What zram and swappiness are now, change them, Recommended for this pc, What these mean. Desktop tweaks switches under it |
| **🌐 Network** | Your connection right now, switches for BBR, buffers, CAKE, Wi-Fi power saving and IPv6 |
| **🐧 Kernels** | Every kernel, Show which one boots, Boot by default, Remove, and which new kernels take over |
| **🩺 Health** | Ten checks on cards, Check again, and a fix button where there is one |

**Right click** the tray icon for the short menu:

| Menu item | What it does |
|---|---|
| **Status line** | Updates waiting or up to date, and the security fixes |
| **Reboot now** | Only there when an update needs a reboot |
| **Install updates…** | Opens Available updates, pick Install all, DNF only or Flatpak only |
| **Check for updates** | Checks right now, you always get a popup with the answer |
| **Open LinuxTweaks** | The window |
| **Exit** | Closes the tray until you log in again |

### 💽 Why your drive picks go by serial number

Linux names your drives at boot: sda, sdb and so on. Usually in the same order, but not always. A USB disk plugged in at boot, or a cable moved to another port, is enough to shuffle them, and a pick saved for "sda" would land on the wrong drive. A serial number never changes, so your pick stays with that exact drive. Drives without a serial are matched by name.

`adios` only exists on CachyOS kernels. Boot another kernel and that drive keeps the kernel's own pick for that boot.

If a tuned profile sets read-ahead (Fedora's throughput-performance does), tuned applies it at boot after mine and wins. The Drives tab tells you when that's the case.

### 🌐 About CAKE and bufferbloat

CAKE on your PC keeps the flows it sends fair, so one big upload doesn't make calls lag. It's unlimited, it never caps your speed. The real fix for lag while downloading is SQM on the router, CAKE set to your real internet speed, if your router has it. A speed cap on the PC itself also slows your LAN and NAS copies, so I don't put one there.

### Undo a tweak

Turning a switch off in the app is the easy way. By hand, delete the file and reboot:

| Tweak | File |
|---|---|
| Drive schedulers and read-ahead | `/etc/udev/rules.d/99-linuxtweaks-io-schedulers.rules` |
| zram size and compression | `/etc/systemd/zram-generator.conf` (a `.bak` copy of your old one sits next to it) |
| Swappiness and memory | `/etc/sysctl.d/99-zz-memtune.conf` |
| Network and Desktop tweaks | `/etc/sysctl.d/99-zz-desktop-performance.conf` |
| CAKE | `/etc/NetworkManager/dispatcher.d/90-cake` |
| Keep Wi-Fi awake | `/etc/NetworkManager/conf.d/wifi-powersave-off.conf` |
| Keep logs up to | `/etc/systemd/journald.conf.d/10-size.conf` |

Check what each drive uses with `grep "" /sys/block/*/queue/scheduler`, the one in `[brackets]` is in use.

### From the terminal

```bash
linuxtweaks-updater                     # start the tray, you can close the terminal after
linuxtweaks-updater --foreground        # start it and keep its output in the terminal
linuxtweaks-updater-check               # check and list what's waiting
linuxtweaks-updater-upgrade             # install everything
linuxtweaks-updater-upgrade --dnf       # DNF only
linuxtweaks-updater-upgrade --flatpak   # Flatpak only
```

## How it works

1. **Timer.** `linuxtweaks-updater-check.timer` is a user timer, it runs the check as you
2. **Check.** `dnf check-update` and `flatpak remote-ls --updates`, then `dnf advisory` for the security fixes and `dnf needs-restarting` for a reboot. No root needed
3. **State.** The results go in `~/.local/state/linuxtweaks-updater/`
4. **Tray.** Watches that folder and redraws the icon, tooltip and window. It hears from systemd when the PC wakes up and checks again as soon as the network is back
5. **Upgrade.** The install window. dnf runs as root through a small helper and one polkit password box, Flatpak runs as you. With the tray closed, the popup still opens the terminal upgrade
6. **Tweaks.** Every tab that changes something has its own small root helper in `/usr/lib/linuxtweaks-updater/bin/` and its own polkit password box. Each helper does only its job and refuses anything it didn't expect
7. **Maintenance.** `linuxtweaks-updater-maintenance.timer` is a system timer that runs as root once a week, only if you switched it on

## 🛠️ Troubleshooting

**No tray icon?**
```bash
linuxtweaks-updater
```
It tells you if it just started or was already running. To see what it prints while it runs:
```bash
linuxtweaks-updater --foreground
```

**Checks not running?**
```bash
systemctl --user --no-pager status linuxtweaks-updater-check.timer
journalctl --user --no-pager -u linuxtweaks-updater-check.service
```

**Weekly maintenance not running?** It's a system timer, so no `--user`:
```bash
systemctl --no-pager status linuxtweaks-updater-maintenance.timer
```

**Want to see everything it did?** **Logs** in the window, or check by hand:
```bash
linuxtweaks-updater-check
```

**`No match for argument: linuxtweaks-updater`?** dnf still has an old copy of my repo's list:
```bash
sudo dnf install --refresh linuxtweaks-updater
```

**Install stops at "Can I reach my repo?"** It tells you which bit is missing. Go through [Set up Tailscale](#-first-time-set-up-tailscale) and check with `tailscale ping 100.83.30.114`.

**A change says "the password box was cancelled".** Nothing changed. Try again and type your password. It's remembered for about 5 minutes after.

**Memory won't restart zram.** What's in swap wouldn't fit in your free RAM. Close a few big apps, or change it right after a reboot. Swappiness on its own always works.

## Built for

- **OS**: Fedora 44+
- **Desktop**: KDE Plasma
- **Language**: Python (PyQt5) + Bash
- **Init**: Systemd

## Author

**Tolga Erok**  
Hamilton Hill, Perth, Western Australia  
📧 kingtolga@gmail.com  
🐙 [My other GitHub repos](https://github.com/tolgaerok)

---

## Other repositories

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

[⬆ Back to top](#top)

---

**Made for my own system. Works great on yours too.**
