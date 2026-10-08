<a id="top"></a>

<div align="center">

![Linux Tweaks](https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/FUN/FUN_IMAGES/1744722407588.png)

# 🫟 LinuxTweaks 2026

**My one app for keeping Fedora up to date and running well.**

[![Version](https://img.shields.io/badge/Version-8.2.4-1e81ac)](https://github.com/tolgaerok/linuxtweaks)
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

[What it does](#what-it-does) · [Install](#installation) · [Using it](#using-it) · [How it works](#how-it-works) · [Troubleshooting](#%EF%B8%8F-troubleshooting) · [Sources](SOURCES.md)

</div>

---

It started as my update manager, because I was sick of hunting through different tools to check for updates. DNF here, Flatpak there. Then my tweak scripts moved in, one tab each. Now it's one place for all of it, and it just works.

<div align="center">

<img width="770" alt="LinuxTweaks window" src="https://github.com/user-attachments/assets/2d4c4c51-4c46-4382-baf3-30906675f62b" />

<img width="730" alt="Updates" src="https://github.com/user-attachments/assets/dae91ae8-89c4-4a63-9461-bad671bbfde3" />

<img width="980" alt="Tray icons, light and dark" src="https://github.com/user-attachments/assets/542c928b-db3f-4867-81d0-3b4f2f231d55" />

</div>

<details>
<summary><b>More screenshots</b></summary>
<br>

<img width="890" alt="image" src="https://github.com/user-attachments/assets/2c017dfe-a325-4901-931b-455c6fca0b82" />
<img width="852" alt="image" src="https://github.com/user-attachments/assets/220a035d-e202-4ea0-a31b-b830f8cf27ad" />
<img width="389" alt="image" src="https://github.com/user-attachments/assets/3fa4476d-7c39-40ab-a5ea-73a6a03fb755" />
<img width="1909" alt="image" src="https://github.com/user-attachments/assets/a6050385-cdc3-478c-94af-7b40fd16c85b" />
<img width="1165" alt="image" src="https://github.com/user-attachments/assets/e2b0f145-09a5-45af-bc42-025f2af7c991" />

</details>

## What it does

**LinuxTweaks** sits in your system tray. Left click it for the window, every part is its own tab.

| Tab | In short |
|---|---|
| 🫟 **Updates** | DNF and Flatpak in one place, security fixes marked, installs when you say so |
| 💽 **Drives** | I/O scheduler and read-ahead per drive, kept after a reboot |
| 🧠 **Memory** | zram, swappiness and a few desktop tweaks, explained in plain words |
| 🌐 **Network** | BBR, bigger buffers, CAKE, Wi-Fi power saving, IPv6 |
| 🐧 **Kernels** | Pick the default kernel, remove old ones safely |
| 🩺 **Health** | A quick look over the whole PC, with a fix button where there is one |

### 🫟 Updates

- **Checks in the background.** DNF and Flatpak, every 30 minutes unless you pick something else, and straight after the PC wakes up. New Fedora updates show up within the hour
- **Security fixes stand out.** Grouped by how bad they are, the worst first: Critical, Important, Moderate, then Low, each a card filled in its colour. It reads Fedora's own advisories that dnf already downloads, nothing extra goes online
- **What changed in a package.** Everything waiting is in one window, a card per update, A to Z. The versions read old in yellow, a blue arrow, new in green. Click a DNF one for its advisory and its changelog since your version
- **The icon tells you.** Red with a number when updates are waiting, orange when a reboot is needed, green when you're up to date, yellow while it checks
- **Popups with buttons.** *Install all*, *DNF only*, *Flatpak only* or *Later…*, which opens a small window to pick when I remind you, 1 hour to 2 days with − and +. It remembers your pick
- **Installs when you say so.** In its own window: the steps, a progress bar and dnf's own live output, its download bars moving like in a terminal. One password box that says what it's for
- **Spinning dots** whenever it's busy: checking, a password job, Apply, installing
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

## Installation

> [!NOTE]
> My repo runs on my own server over Tailscale (`100.83.30.114`). Your PC needs Tailscale and access to my server to reach it. If it can't, the install stops straight away, tells you what's missing and changes nothing. No access to my server? [Install the RPM file](#-no-tailscale-install-the-rpm-file) instead.

### 🔐 First time? Set up Tailscale

Tailscale is a private network between your PCs. It's free for personal use and takes about 5 minutes.

<details>
<summary><b>The six steps</b></summary>
<br>

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

</details>

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

<details>
<summary><b>More things the same script does</b></summary>
<br>

Put the option after `bash -s --`, everything after the `--` goes to my script. Any questions and the sudo password still come from your keyboard, not the pipe.

| Option | What it does |
|---|---|
| `--check` | Only looks, changes nothing |
| `--cleanup` | Only clears out what my older apps left behind. Shows you the list and asks first |
| `--remove` | Uninstalls it. Asks first, then asks about the repo file |
| `--fake 3 20` | Fake updates in the tray to see how it looks, here 3 dnf and 20 flatpak, one a pretend security fix |
| `--restore` | Puts the real update list back after a fake test |

For example:

```bash
curl -fsSL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/LINUXTWEAKS/POST-INSTALL/install-linuxtweaks.sh | bash -s -- --check
```

Rather have a copy on your PC? Download it once and run it with any of the options:

```bash
curl -fsSLO https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/LINUXTWEAKS/POST-INSTALL/install-linuxtweaks.sh
bash install-linuxtweaks.sh --check
```

</details>

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

From then on it starts by itself when you log in, and new versions come with a normal `sudo dnf upgrade`. The package and the commands are still called `linuxtweaks-updater` for now, the app itself is LinuxTweaks.

### 📦 No Tailscale? Install the RPM file

The same signed RPM is here on GitHub. This finds the newest one in my folder, downloads the real file, shows you it's an RPM and installs it:

```bash
url=$(curl -fsSL "https://api.github.com/repos/tolgaerok/linuxtweaks/contents/LINUXTWEAKS/RPM/linuxtweaks-updater%20v7x" | grep -o '"download_url": *"[^"]*\.rpm"' | cut -d'"' -f4 | sort -V | tail -1) && curl -fLO "$url" && file linuxtweaks-updater-*.rpm && sudo dnf install ./linuxtweaks-updater-*.rpm
```

`file` should say `RPM v3.0 bin linuxtweaks-updater-…` before dnf starts.

> [!WARNING]
> **Don't save it from the GitHub page.** Right click → Save, or a `github.com/…/blob/…` link, gets you the web page with an `.rpm` name, and dnf says `not a rpm`. In the browser use the **Download raw file** button on the file's page instead. A broken one says `HTML document` when you run `file` on it, delete it and download it again.

**Use a terminal, not Yum Extender.** Yumex crashes with `Transaction has to be resolved first` when something's wrong, and hides the real reason. `sudo dnf install` tells you.

**Had my repo before?** If `/etc/yum.repos.d/linuxtweaks.repo` is there and you can't reach my server, dnf won't install anything at all. Take it out first:

```bash
sudo rm -f /etc/yum.repos.d/linuxtweaks.repo /etc/yum.repos.d/linuxtweaks-io.repo
```

Without my repo, LinuxTweaks updates itself from **About → Check for LinuxTweaks updates** (from 8.2.0 on). It looks in my repo first and on GitHub when it can't reach that, downloads the new version, checks it's signed with my key, the key comes with the app, and installs it with one password box. A download that isn't signed by me never gets installed. Your other updates work as normal.

### Coming from an older name?

dnf-updater, linuxtweaks-dnf-updater, LinuxTweaks 6.x and LinuxTweaks-IO are all this app under old names. A normal update swaps you over, or run the quick install.

<details>
<summary><b>What the old versions left behind</b></summary>
<br>

**LinuxTweaks-IO**, my I/O scheduler app, is the 💽 Drives tab now. The update removes the old app for you. Your scheduler picks stay, it's the same rules file, only the old window and its tray icon go.

The older updater versions left stuff behind. Some of it keeps starting the old app next to the new one, and the old sudo rules in `/etc/sudoers.d` handed out root without a password. Uninstalling the old app doesn't always take them with it, a sudo rule you edited gets kept as a `.rpmsave` copy. The quick install looks for all of it. To do only that part:

```bash
curl -fsSL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/LINUXTWEAKS/POST-INSTALL/install-linuxtweaks.sh | bash -s -- --cleanup
```

It shows you the list and asks first. Looking in `/etc/sudoers.d` needs your password, only root can read it.

If your `/etc/yum.repos.d/linuxtweaks.repo` is from before September 2026, run the quick install again. Older copies didn't check my signature.

</details>

### 📋 Installed? Uninstall? What's new?

| | |
|---|---|
| **Is it installed?** | `dnf info linuxtweaks-updater`, or the quick install with `--check` |
| **Uninstall** | In the window: **About → Uninstall…**, or `sudo dnf remove linuxtweaks-updater` |
| **Changelog** | In the window: **What's new**, or `rpm -q --changelog linuxtweaks-updater` |

Uninstalling takes the app, its timers, the menu launcher and its settings. Your installed packages stay as they are, and so do the tweaks you made. They're your system settings, not part of the app. To undo one by hand, see [Undo a tweak](#undo-a-tweak).

## Using it

**Left click** the tray icon for the LinuxTweaks window, click again to close it. Drag it to any size, the tabs scroll when they don't fit. Top right on every tab: **What's new**, **Logs** and **About**, which has **Check for LinuxTweaks updates** and the full guide under **Help**. Dots spin next to the name while anything is busy.

| Tab | What's in it |
|---|---|
| **🫟 Updates** | What's waiting with Install updates…, See them and Check now. Reboot needed or not. Settings: check every, popups, weekly maintenance, keep logs up to. Closing Available updates brings you back here |
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
| **Check for updates** | Checks right now with a fresh list, you always get a popup with the answer |
| **Open LinuxTweaks** | The window |
| **Exit** | Closes the tray until you log in again |

### From the terminal

```bash
linuxtweaks-updater                     # start the tray, you can close the terminal after
linuxtweaks-updater --foreground        # start it and keep its output in the terminal
linuxtweaks-updater-check               # check and list what's waiting
linuxtweaks-updater-upgrade             # install everything
linuxtweaks-updater-upgrade --dnf       # DNF only
linuxtweaks-updater-upgrade --flatpak   # Flatpak only
```

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

## How it works

1. **Timer.** `linuxtweaks-updater-check.timer` is a user timer, it runs the check as you
2. **Check.** `dnf check-update` and `flatpak remote-ls --updates`, then `dnf advisory` for the security fixes and `dnf needs-restarting` for a reboot. No root needed. A list older than an hour gets downloaded again, Check for updates always gets a fresh one
3. **State.** The results go in `~/.local/state/linuxtweaks-updater/`
4. **Tray.** Watches that folder and redraws the icon, tooltip and window. It hears from systemd when the PC wakes up and checks again as soon as the network is back
5. **Upgrade.** The install window. dnf runs as root through a small helper and one polkit password box, Flatpak runs as you. Both run in a pretend terminal (`linuxtweaks-updater-pty`) so their progress bars move live, and the window redraws them in place. With the tray closed, the popup still opens the terminal upgrade
6. **Updating itself.** About checks my repo, then GitHub. The RPM is checked against my key twice, once by the app in a keyring of its own and once by the root helper, before dnf installs it
7. **A clean start.** Every install or upgrade clears a snooze, popup clicks nobody picked up and Health's Count from now. Your settings stay
8. **Tweaks.** Every tab that changes something has its own small root helper in `/usr/lib/linuxtweaks-updater/bin/` and its own polkit password box. Each helper does only its job and refuses anything it didn't expect
9. **Maintenance.** `linuxtweaks-updater-maintenance.timer` is a system timer that runs as root once a week, only if you switched it on

Everything I read and leaned on to build it is on its own page: **[Sources and references](SOURCES.md)**.

## 🛠️ Troubleshooting

<details>
<summary><b>No tray icon?</b></summary>

```bash
linuxtweaks-updater
```
It tells you if it just started or was already running. To see what it prints while it runs:
```bash
linuxtweaks-updater --foreground
```
</details>

<details>
<summary><b>Checks not running?</b></summary>

```bash
systemctl --user --no-pager status linuxtweaks-updater-check.timer
journalctl --user --no-pager -u linuxtweaks-updater-check.service
```
</details>

<details>
<summary><b>Weekly maintenance not running?</b></summary>

It's a system timer, so no `--user`:
```bash
systemctl --no-pager status linuxtweaks-updater-maintenance.timer
```
</details>

<details>
<summary><b>Want to see everything it did?</b></summary>

**Logs** in the window, or check by hand:
```bash
linuxtweaks-updater-check
```
</details>

<details>
<summary><b><code>No match for argument: linuxtweaks-updater</code>?</b></summary>

dnf still has an old copy of my repo's list:
```bash
sudo dnf install --refresh linuxtweaks-updater
```
</details>

<details>
<summary><b>Install stops at "Can I reach my repo?"</b></summary>

It tells you which bit is missing. Go through [Set up Tailscale](#-first-time-set-up-tailscale) and check with `tailscale ping 100.83.30.114`.
</details>

<details>
<summary><b>A change says "the password box was cancelled"</b></summary>

Nothing changed. Try again and type your password. It's remembered for about 5 minutes after.
</details>

<details>
<summary><b>Memory won't restart zram</b></summary>

What's in swap wouldn't fit in your free RAM. Close a few big apps, or change it right after a reboot. Swappiness on its own always works.
</details>

## Built for

| | |
|---|---|
| **OS** | Fedora 44+ |
| **Desktop** | KDE Plasma 6 |
| **Language** | Python (PyQt5) and Bash |
| **Init** | systemd |

## Author

**Tolga Erok**
Hamilton Hill, Perth, Western Australia
📧 kingtolga@gmail.com
🐙 [My other GitHub repos](https://github.com/tolgaerok)

### Other repositories

<div align="center">
  <table>
    <tr>
      <td align="center">
        <a href="https://github.com/tolgaerok/fedora-tolga">
          <img src="https://flathub.org/img/distro/fedora.svg" alt="Fedora" width="160">
          <br>Fedora
        </a>
      </td>
      <td align="center">
        <a href="https://github.com/tolgaerok/Debian-tolga">
          <img src="https://flathub.org/img/distro/debian.svg" alt="Debian" width="160">
          <br>Debian
        </a>
      </td>
    </tr>
  </table>
</div>

### Stats

<div align="center">
  <a href="https://git.io/streak-stats" target="_blank">
    <img src="http://github-readme-streak-stats.herokuapp.com?user=tolgaerok&theme=dark&background=000000" alt="GitHub Streak">
  </a>
</div>

---

<div align="center">

**Made for my own system. Works great on yours too.**

[⬆ Back to top](#top)

</div>
