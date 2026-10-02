<div align="center">

[![Version](https://img.shields.io/badge/Version-7.5.6-1e81ac)](https://github.com/tolgaerok/linuxtweaks)
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


**🫟 My simple update manager for Fedora.**

I built this because I was sick of hunting through different tools to check for updates. DNF here, Flatpak there. I wanted one place that just works.

### The tray icon and app

<img width="292" height="479" alt="image" src="https://github.com/user-attachments/assets/99139b76-969c-4591-979e-424faffae4ae" />
<img width="429" height="219" alt="image" src="https://github.com/user-attachments/assets/524a2e40-508a-4ed9-9f71-cd19ab47cbd3" />
<img width="980" height="184" alt="tray-badges-and-icons-dark" src="https://github.com/user-attachments/assets/542c928b-db3f-4867-81d0-3b4f2f231d55" />

## What it does

**LinuxTweaks Updater** sits in your system tray and keeps Fedora up to date.

- **Checks in the background.** DNF and Flatpak, every 30 minutes unless you pick something else, and again after the PC wakes up
- **Security fixes stand out.** A 🔴 marks them in the menu, the tooltip and the popup, with how bad they are. It reads Fedora's own advisories that dnf already downloads, nothing extra goes online
- **What changed in a package.** Click any package in the DNF list and you get its advisory and its changelog since your version
- **The icon tells you.** Red with a number when updates are waiting, orange when a reboot is needed, green when you're up to date
- **Popups with buttons.** *Install all*, *DNF only*, *Flatpak only* or *Later*, which reminds you again in 4 hours
- **Installs when you say so.** In a terminal window so you see everything. It asks for your password once
- **Cleans up after.** Tells you when a new kernel needs a reboot, offers to restart services still running old code, lists changed config files (`.rpmnew`), clears old caches and unused packages
- **Weekly maintenance, if you want it.** Cleans the DNF cache, keeps 7 days of journal, runs SSD TRIM if Fedora isn't already doing it. Off until you switch it on
- **What's new.** Shows what changed every time the app itself updates
- **Signed.** Everything in my repo is signed with my LinuxTweaks key

**What it doesn't do.** No sudo rules, no passwordless root. Checks run as you. Weekly maintenance is a normal system timer, and switching it on asks for your password.

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
4. Installs LinuxTweaks Updater, or updates it if you have it. Only my package, the rest of your system is left alone
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

### Coming from dnf-updater, linuxtweaks-dnf-updater or LinuxTweaks 6.x?

Those are all this app under its old names. Run the quick install, it swaps you over.

The old versions left stuff behind. Some of it keeps starting the old app next to the new one, and the old sudo rules in `/etc/sudoers.d` handed out root without a password. Uninstalling the old app doesn't always take them with it, a sudo rule you edited gets kept as a `.rpmsave` copy. The quick install looks for all of it. To do only that part:

```bash
curl -fsSL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/LINUXTWEAKS/POST-INSTALL/install-linuxtweaks.sh | bash -s -- --cleanup
```

It shows you the list and asks first. Looking in `/etc/sudoers.d` needs your password, only root can read it.

If your `/etc/yum.repos.d/linuxtweaks.repo` is from before September 2026, run the quick install again. Older copies didn't check my signature.

### My I/O scheduler app, linuxtweaks-io

Same repo server, same signing key:

```bash
echo -e "[linuxtweaks-io]\nname=LinuxTweaks-IO Repository\nbaseurl=http://100.83.30.114:8080/linuxtweaks-io/\nenabled=1\ngpgcheck=1\ngpgkey=http://100.83.30.114:8080/linuxtweaks/RPM-GPG-KEY" | sudo tee /etc/yum.repos.d/linuxtweaks-io.repo > /dev/null

sudo dnf install --refresh linuxtweaks-io
```

### 📋 Is it installed?

```bash
curl -fsSL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/LINUXTWEAKS/POST-INSTALL/install-linuxtweaks.sh | bash -s -- --check
```

or just `dnf info linuxtweaks-updater`.

### 🪓 Uninstall

In the tray: **About → Uninstall…**, or:

```bash
sudo dnf remove linuxtweaks-updater
```

That takes the app, its timers, the menu launcher and its settings. Your installed packages and updates stay as they are.

### 📅 Changelog

In the tray: **What's new**, or:

```bash
rpm -q --changelog linuxtweaks-updater
```

## Using it

Right click the tray icon:

| Menu item | What it does |
|---|---|
| **🔴 N security fixes** | Only there when a security fix is waiting, with the worst severity |
| **DNF (n)** / **Flatpak (n)** | What's waiting. Click a DNF package to see what changed in it. *Install ... updates only* shows up when both kinds are waiting |
| **Reboot now** | Only there when an update needs a reboot |
| **Run LinuxTweaks Updater** | Installs everything that's waiting |
| **Check for updates** | Checks right now, you always get a popup with the answer |
| **Check interval** | 1 hour, 6 hours, 1 day or 1 week. The 1, 5 and 30 minute ones are for testing, 30 minutes is the default |
| **Notifications** | Popups on or off |
| **Weekly Maintenance** | On or off, asks for your password |
| **What's new** / **Logs** / **About** | Release notes, your update history and my app's log, version, Help and Uninstall |

The full guide is in the app: **About → Help**.

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
4. **Tray.** Watches that folder and redraws the icon, menu and tooltip
5. **Upgrade.** Runs in Konsole, asks for your password once, then offers the reboot or service restarts and cleans up
6. **Maintenance.** `linuxtweaks-updater-maintenance.timer` is a system timer that runs as root once a week, only if you switched it on

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

**Want to see everything it did?** Tray menu **Logs**, or check by hand:
```bash
linuxtweaks-updater-check
```

**`No match for argument: linuxtweaks-updater`?** dnf still has an old copy of my repo's list:
```bash
sudo dnf install --refresh linuxtweaks-updater
```

**Install stops at "Can I reach my repo?"** It tells you which bit is missing. Go through [Set up Tailscale](#-first-time-set-up-tailscale) and check with `tailscale ping 100.83.30.114`.

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
