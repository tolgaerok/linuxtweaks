<a id="top"></a>

<div align="center">

![Linux Tweaks](https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/FUN/FUN_IMAGES/1744722407588.png)

# 🫟 LinuxTweaks 2026

**My one app for keeping Fedora and Solus up to date and running well.**

[![Fedora](https://img.shields.io/badge/Version-8.2.61-51A2DA?label=Fedora%2044%2B&logo=fedora&logoColor=white)](#-fedora)
[![Solus](https://img.shields.io/badge/Solus-8.2.56-5294E2?label=Solus%204.9&logo=solus&logoColor=white)](#-solus)
[![KDE Plasma](https://img.shields.io/badge/KDE_Plasma-6-1D99F3?logo=kde&logoColor=white)](https://kde.org/plasma-desktop)
[![Python](https://img.shields.io/badge/Python-3-3776AB?logo=python&logoColor=white)](https://www.python.org)
[![PyQt5](https://img.shields.io/badge/PyQt5-GUI-41CD52?logo=qt&logoColor=white)](https://www.riverbankcomputing.com/software/pyqt)
[![Bash](https://img.shields.io/badge/Bash-scripts-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash)

[![RPM](https://img.shields.io/badge/RPM-GPG_signed-2e3440?logo=gnuprivacyguard&logoColor=white)](#-fedora)
[![eopkg](https://img.shields.io/badge/eopkg-GPG_signed-2e3440?logo=gnuprivacyguard&logoColor=white)](#-solus)
[![License](https://img.shields.io/badge/License-GPL--3.0--or--later-blue)](https://github.com/tolgaerok/linuxtweaks/blob/main/LICENSE)
[![Status](https://img.shields.io/badge/Status-Active-brightgreen)](https://github.com/tolgaerok/linuxtweaks)
[![Last commit](https://img.shields.io/github/last-commit/tolgaerok/linuxtweaks)](https://github.com/tolgaerok/linuxtweaks/commits/main)
[![Stars](https://img.shields.io/github/stars/tolgaerok/linuxtweaks?style=flat)](https://github.com/tolgaerok/linuxtweaks/stargazers)

[What it does](#what-it-does) · [Install](#installation) · [Using it](#using-it) · [How it works](#how-it-works) · [Troubleshooting](#%EF%B8%8F-troubleshooting) · [Sources](SOURCES.md)

</div>

---

It started as my update manager, because I was sick of hunting through different tools to check for updates. DNF here, Flatpak there. Then my tweak scripts moved in, one tab each. Now it's one place for all of it, and it just works.

It runs on **Fedora** and on **Solus**. Same app, same tabs, same look. Underneath, Fedora gets dnf and an RPM, Solus gets eopkg and a proper Solus package built with solbuild. Where the two distros do things differently, the app does it their way.

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

**LinuxTweaks** sits in your system tray. Left click it for the window, every part is its own tab. The little **Fedora** or **Solus** tag next to the name tells you which build you've got, it's in About and the new version popup too.

| Tab | In short |
|---|---|
| 🫟 **Updates** | DNF (Fedora) or eopkg (Solus) and Flatpak in one place, security fixes marked, installs when you say so |
| 💽 **Drives** | I/O scheduler and read-ahead per drive, kept after a reboot |
| 🧠 **Memory** | zram, swappiness and a few desktop tweaks, explained in plain words |
| 🌐 **Network** | BBR, bigger buffers, CAKE, Wi-Fi power saving, IPv6 |
| 🐧 **Kernels** | Pick the default kernel, remove old ones safely |
| 🎮 **GPU** | Fedora only: where the NVIDIA driver comes from, the right branch for your card, and the tweaks Solus ships |
| 📦 **Boxes** | Fedora, Debian or Arch in a box with distrobox, and LumineCapture for screenshots with OCR |
| ❄️ **Nix** | The Nix package manager next to yours: install a program for good, or try it without installing |
| 🧩 **Extras** | Fixes for one app or one problem, each with its own switch. First up: WPS Office's crashing cloud helper |
| 🩺 **Health** | A quick look over the whole PC, with a fix button where there is one, and a report you can send |

### 🫟 Updates

- **Checks in the background.** DNF or eopkg and Flatpak, every 30 minutes unless you pick something else, and straight after the PC wakes up. New updates show up within the hour
- **Security fixes stand out.** Grouped by how bad they are, the worst first: Critical, Important, Moderate, then Low, each a card filled in its colour. On Fedora it reads the advisories dnf already downloads, on Solus the security releases in the eopkg index. Nothing extra goes online
- **What changed in a package.** Everything waiting is in one window, a card per update, A to Z. The versions read old in yellow, a blue arrow, new in green. Click a DNF or eopkg one for its advisory and its changelog since your version
- **The icon tells you.** Red with a number when updates are waiting, orange when a reboot is needed, green when you're up to date, yellow while it checks
- **Popups that show you first.** *📦 Show updates* opens the list of what's waiting, and you install from there. *Later…* opens a small window to pick when I remind you, 1 hour to 2 days with − and +. It remembers your pick
- **Installs when you say so.** In its own window: the steps, a progress bar and dnf's or eopkg's own live output, its download bars moving like in a terminal. One password box that says what it's for. Afterwards it checks what really went in, so anything the package manager held back shows up with its reason instead of a fake "all done"
- **Spinning dots** whenever it's busy: checking, a password job, Apply, installing
- **Cleans up after.** A card for each thing left: reboot for a new kernel, restart services still running old code, remove packages nothing needs, compare changed config files (`.rpmnew` on Fedora, `.newconfig` on Solus)
- **Weekly maintenance, if you want it.** Cleans the package cache, trims the journal, runs SSD TRIM if your distro isn't already doing it
- **Keep logs up to.** How much disk the system journal may take. 500 MB holds weeks, out of the box it can grow to 4 GB

Updated somewhere else, a terminal or Discover? The tray watches the package database and checks again a few seconds after, so the dot goes green straight away. **Reboot required** goes as soon as you've rebooted, it doesn't wait for the next check.

### 💽 Drives

Every real drive on a card, with its I/O scheduler and read-ahead and a dropdown to change each one. A change works straight away and stays after a reboot, for that exact drive. This used to be my LinuxTweaks-IO app.

### 🧠 Memory

Compressed swap in RAM (zram) and how eagerly Linux uses it: size, compression and swappiness, with **Recommended for this pc** and a **What these mean** button that explains every setting in plain words. Under it, **Desktop tweaks**: smooth big file copies, more file watchers for big projects, and a safety net for kernel crashes.

### 🌐 Network

What your connection uses right now, and switches for faster TCP (BBR), bigger buffers, CAKE on Wi-Fi and wired, Wi-Fi power saving off and IPv6 off. Every switch says what it does.

### 🐧 Kernels

Every installed kernel, which one you're running and which one boots by default. Make another one the default and remove old ones safely. On Fedora that's grubby, and you can pick which new kernels take over when they install, so a Fedora kernel update doesn't push out your CachyOS one. On Solus it's clr-boot-manager with its `current` and `lts` kernels.

Under them, **⚡ CPU scheduler (sched_ext)**: pick an scx scheduler and a mode from dropdowns, like a drive's scheduler in Drives. Each one says what it's good for, ★ says what suits this PC (lavd on a laptop, flash on a desktop), and **Keep it after a reboot** decides if it's just for now or saved. **flash** in auto is the Solus default. It needs `scx-scheds` and `scx-tools`. Solus has them, on Fedora they come from the CachyOS addons COPR (`sudo dnf copr enable bieszczaders/kernel-cachyos-addons`). From my scx-picker.sh.

### 🎮 GPU (Fedora only)

NVIDIA on Fedora comes from a third party repo: Negativo17 or RPM Fusion. Never both, they ship the same things under different names, and the tab warns you with a red box if both are on and moves you over to one cleanly. It picks the right driver branch for your card (the 580 branch for GTX 900 and 10 series, the newest for everything after), switches Negativo17's multimedia repo on or off, and has the tweaks Solus ships in its own NVIDIA package, with **Apply all tweaks** to turn them on with one password. Each one says *Needs reboot* or *Needs log out*, and greys out when your driver doesn't have it.

Solus doesn't get this tab. Solus packages its own NVIDIA driver, you install it from the Software Center the way the [Solus NVIDIA guide](https://help.getsol.us/docs/user/hardware/nvidia-gpu-drivers) says, and it already has those tweaks.

### 📦 Boxes

My lt-boxes window as a tab. Distrobox runs other Linux distros in a box that shares your home folder: make a Fedora 44, Debian 13 or Arch box, open a terminal in it, update it, stop it or delete it, or **Update all** of them. **Set up distrobox** installs distrobox and podman, gives you a uid and gid range nobody else on the PC has and adds `box-update` to `~/.bashrc.d`, all with one password. Then it tests podman for real. If podman can't start because `newuidmap` has setuid and capabilities both (Fedora's kernel says no to that, it broke every box on Alex's PC), it fixes that and tests again. It leaves a PC where podman already works alone. A uid or gid range shorter than 65536 gets made 65536, apt in Debian and Ubuntu boxes needs gid 65534 in it, but never over another user's range. It also clears out layers podman can't read or delete any more, and if your router stops answering name lookups it adds Cloudflare and Quad9 next to it, so boxes can still download. A box whose first setup fails gets taken away again, with why.

Boxes and images made under an old id range can't be opened, made or deleted any more. **Start boxes fresh…** clears podman out and starts again clean: every box and downloaded image goes, your home folder stays. It asks first, and Create tells you when that's what you need. A chip says when podman can't read its boxes. The chip at the top says **podman ready** or **podman can't start**, and **Create** runs the setup first, so a broken PC fixes itself. Debian and Arch boxes get your language built in first, Solus spells it differently and distrobox chokes on that.

Each box shows its distro's logo. Making and updating boxes, Update all, Set up and Start fresh run in a real terminal, so you see everything and type your password there. It says Done or what went wrong, and the tab refreshes when you close it.

**🧰 Apps** is for apps that have to live on the real system, not in a box. First one: **LumineCapture**, screenshots with OCR, installed straight on your system so KWin lets it capture. One row with what you have, what's newest and if KWin allows it, **Copy shortcut** for System Settings, and Install, Update or Remove. More apps go here later.

### ❄️ Nix

The Nix package manager, single user, next to eopkg or dnf. Thousands of extra programs your distro doesn't have, all in your home folder, nothing in /usr. **Install Nix** sets it up in a terminal so you can watch.

Then type a program's name, like `btop`:

- **Install for good** runs `nix-env -iA nixpkgs.btop` in a terminal, and it's there in every new terminal after
- **Try without installing** gets it for one terminal only, tells you when it's ready, and it's gone again when you close that terminal
- **🔍 Look it up** opens the NixOS package search in a new browser window, for when you're not sure of the name

**Installed for good** lists what you kept with its version and a **Remove** button, plus **Update them** and **Free up space**. Nix and glibc-locales have no Remove, Nix needs them. **🐚 nix-shell** shows what's in your `~/default.nix`, a set you use together, with **Edit default.nix** and **Open nix-shell**. The tab refreshes by itself when Nix installs, or a program goes in or out. Save `~/default.nix` and it builds straight away, with a line saying it's ready or what's wrong. A **nixpkgs channel** chip, and **🔧 Fix Nix** shows up when part of Nix is missing. Installing Nix ends with a fresh shell in that terminal, Nix works there straight away.

### 🧩 Extras

Fixes for one app or one problem, each with its own switch, and off always puts it back. First one: **Stop WPS Office's cloud helper crashing**. wpscloudsvr in the WPS flatpak keeps segfaulting, so /dev/null goes in its place and it never starts. WPS works fine, you only lose its cloud sync, and it's put back by itself after a reboot or a WPS update.

### 🩺 Health

A quick look over the whole PC: failed services, errors, disk space, memory, crashes, SELinux on Fedora or AppArmor on Solus, packages, the kernel, the logs and autostart, each green, orange or red. Where there's a fix the card has a button for it. Known noise that every desktop logs is left out, so are the apps that fall over when you log out, and a network share never counts as your disk.

**📋 Report…** puts it all in plain text, worst first, with the real error lines behind the red and orange cards. Copy it into a message or save it, nothing leaves the PC unless you send it. Brian's idea, thanks Brian.

### What it doesn't do

- **No sudo rules, no passwordless root.** Checks run as you. Every change that needs root asks for your password first, through a small helper that only does that one job and checks everything it's handed
- **Nothing changes by itself.** Every tab shows your PC as it is. A tweak only happens when you flip it
- **Signed.** Every RPM and every eopkg is signed with my LinuxTweaks key, and the app checks that before it installs a new version of itself

## Installation

Pick yours: [🎩 Fedora](#-fedora) · [🌀 Solus](#-solus)

### 🎩 Fedora

> [!NOTE]
> My repo runs on my own server over Tailscale (`100.83.30.114`). Your PC needs Tailscale and access to my server to reach it. If it can't, the install stops straight away, tells you what's missing and changes nothing. No access to my server? [Install the RPM file](#-no-tailscale-install-the-rpm-file) instead.

#### 🔐 First time? Set up Tailscale

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

#### 👍 Quick install

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

#### 🖖 Or by hand

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

#### 📦 No Tailscale? Install the RPM file

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

When a new one's out you get a popup in the LinuxTweaks look with what's new right on it, once per version. **See what's new** opens About with Install ready, **Later** leaves it till you go looking.

#### Coming from an older name?

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

### 🌀 Solus

LinuxTweaks for Solus isn't in the Solus repo, it's a signed eopkg in my GitHub folder. It's built the Solus way, with `package.yml` and solbuild, to the [Solus packaging practices](https://help.getsol.us/docs/packaging/packaging-practices). This finds the newest one, downloads it with its signature, checks the signature against my key and only then installs it:

```bash
cd /tmp && url=$(curl -fsSL "https://api.github.com/repos/tolgaerok/linuxtweaks/contents/LINUXTWEAKS/EOPKG/SOLUS" | grep -o '"download_url": *"[^"]*\.eopkg"' | cut -d'"' -f4 | sort -V | tail -1) && curl -fLO "$url" && curl -fLO "$url.asc" && curl -fsSLo linuxtweaks-key.gpg https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/LINUXTWEAKS/KEYS/linuxtweaks-key.gpg && gpgv --keyring ./linuxtweaks-key.gpg linuxtweaks-updater-*.eopkg.asc linuxtweaks-updater-*.eopkg && sudo eopkg it ./linuxtweaks-updater-*.eopkg
```

`Good signature from "Tolga Erok (LinuxTweaks RPM Signing)"` means it's mine and nobody changed it. Anything else and it stops before installing. Then start it:

```bash
linuxtweaks-updater
```

From then on it starts by itself when you log in. New versions come from **About → Check for LinuxTweaks updates**: it finds the newest eopkg in my GitHub folder, checks its signature against the key that comes with the app, and installs it with one password box. One that isn't signed by me never gets installed. A new one pops up once in the LinuxTweaks look with what's new on it.

The NVIDIA driver, codecs and the rest of your system stay the Solus way: from the Solus repo, and apps from outside through Flatpak, as [Solus recommends](https://help.getsol.us/docs/user/software/third-party/).

### 📋 Installed? Uninstall? What's new?

| | Fedora | Solus |
|---|---|---|
| **Is it installed?** | `dnf info linuxtweaks-updater`, or the quick install with `--check` | `eopkg info linuxtweaks-updater` |
| **Which build?** | A blue **Fedora** tag next to the name | A blue **Solus** tag next to the name |
| **Uninstall** | **About → Uninstall…**, or `sudo dnf remove linuxtweaks-updater` | **About → Uninstall…**, it clears your settings first |
| **Changelog** | **What's new**, or `rpm -q --changelog linuxtweaks-updater` | **What's new**, or `less /usr/share/doc/linuxtweaks-updater/CHANGELOG` |

Uninstalling takes the app, its timers, the menu launcher and its settings. Your installed packages stay as they are, and so do the tweaks you made. They're your system settings, not part of the app. To undo one by hand, see [Undo a tweak](#undo-a-tweak).

## Using it

**Left click** the tray icon for the LinuxTweaks window, click again to close it. Drag it to any size, the tabs scroll when they don't fit, and the scrollbar always shows so you know there's more. Top right on every tab: **What's new**, **Logs** and **About**, which has **Check for LinuxTweaks updates** and the full guide under **Help**. Dots spin next to the name while anything is busy.

| Tab | What's in it |
|---|---|
| **🫟 Updates** | What's waiting with Install updates…, See them and Check now. Reboot needed or not. Settings: check every, popups, weekly maintenance, keep logs up to. Closing Available updates brings you back here |
| **💽 Drives** | A card per drive: scheduler and read-ahead dropdowns, 🔒 *kept at boot* when your pick is saved. Scheduler info explains each one |
| **🧠 Memory** | What zram and swappiness are now, change them, Recommended for this pc, What these mean. Desktop tweaks switches under it |
| **🌐 Network** | Your connection right now, switches for BBR, buffers, CAKE, Wi-Fi power saving and IPv6 |
| **🐧 Kernels** | Every kernel, Show which one boots, Boot by default, Remove, and on Fedora which new kernels take over. Under them the CPU scheduler: scx scheduler and mode, Apply, Keep it after a reboot, Back to the default |
| **🎮 GPU** | Fedora only. Where the driver comes from, the branch, multimedia, and the tweaks with Apply all tweaks |
| **📦 Boxes** | Distrobox: what's set up, My boxes with their logos and Open terminal, Update, Stop and Delete, New box, and Apps like LumineCapture |
| **❄️ Nix** | Install a program for good or try it without installing, Look it up, what's installed with Remove, Update them, Free up space, and nix-shell with your ~/default.nix. Refreshes by itself, Fix Nix when part of it's missing |
| **🧩 Extras** | One switch per fix, with what it does and how. WPS Office's cloud helper for now |
| **🩺 Health** | Ten checks on cards, Check again, Count from now, 📋 Report…, and a fix button where there is one |

**Right click** the tray icon for the short menu:

| Menu item | What it does |
|---|---|
| **Status line** | Updates waiting or up to date, and the security fixes |
| **Reboot now** | Only there when an update needs a reboot |
| **Install updates…** | Opens Available updates, pick Install all, DNF (or eopkg) only or Flatpak only |
| **Check for updates** | Checks right now with a fresh list, you always get a popup with the answer |
| **Open LinuxTweaks** | The window |
| **Exit** | Closes the tray until you log in again |

### From the terminal

```bash
linuxtweaks-updater                     # start the tray, you can close the terminal after
linuxtweaks-updater --foreground        # start it and keep its output in the terminal
linuxtweaks-updater-check               # check and list what's waiting
linuxtweaks-updater-upgrade             # install everything
linuxtweaks-updater-upgrade --dnf       # DNF only (Fedora)
linuxtweaks-updater-upgrade --eopkg     # eopkg only (Solus)
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
| CPU scheduler kept after a reboot | `/etc/scx_loader/config.toml` |
| Extra DNS for boxes | `/etc/systemd/resolved.conf.d/90-linuxtweaks-dns.conf`, then `sudo systemctl restart systemd-resolved` |
| WPS Office's cloud helper | `linuxtweaks-wps-mask-boot.service` and `linuxtweaks-wps-mask.path` in `/etc/systemd/system`, `sudo systemctl disable --now` them first |
| GPU tweaks (Fedora) | `/etc/modprobe.d/linuxtweaks-nvidia.conf`, and `preempt=full` / `transparent_hugepage=always` come off with `sudo grubby --update-kernel=ALL --remove-args="preempt transparent_hugepage"` |

The same files on Fedora and Solus.

Check what each drive uses with `grep "" /sys/block/*/queue/scheduler`, the one in `[brackets]` is in use.

## How it works

1. **Timer.** `linuxtweaks-updater-check.timer` is a user timer, it runs the check as you
2. **Check.** Fedora: `dnf check-update`, `dnf advisory` for the security fixes and `dnf needs-restarting` for a reboot. Solus: the eopkg repo index and install database, read as you. Then `flatpak remote-ls --updates`. No root needed. A list older than an hour gets downloaded again, Check for updates always gets a fresh one
3. **State.** The results go in `~/.local/state/linuxtweaks-updater/`
4. **Tray.** Watches that folder and redraws the icon, tooltip and window. It hears from systemd when the PC wakes up and checks again as soon as the network is back
5. **Upgrade.** The popup opens Available updates, and you start the install window from there. dnf or eopkg runs as root through a small helper and one polkit password box, Flatpak runs as you. Both run in a pretend terminal (`linuxtweaks-updater-pty`) so their progress bars move live, and the window redraws them in place. With the tray closed, clicking the popup starts it first
6. **Updating itself.** Fedora: About checks my repo, then GitHub, and the RPM is checked against my key twice, once by the app in a keyring of its own and once by the root helper, before dnf installs it. Solus: About checks my GitHub folder and the eopkg's `.asc` signature is checked with `gpgv` against my key only, before eopkg installs it
7. **A clean start.** Every install or upgrade clears a snooze, popup clicks nobody picked up and Health's Count from now. Your settings stay
8. **Tweaks.** Every tab that changes something has its own small root helper in `/usr/lib/linuxtweaks-updater/bin/` (`/usr/lib64/` on Solus) and its own polkit password box. Each helper does only its job and refuses anything it didn't expect
9. **Maintenance.** `linuxtweaks-updater-maintenance.timer` is a system timer that runs as root once a week, only if you switched it on

Everything I read and leaned on to build it is on its own pages: **[Sources and references](SOURCES.md)**, split into [Fedora](SOURCES-FEDORA.md) and [Solus](SOURCES-SOLUS.md).

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
| **OS** | Fedora 44+ and Solus 4.9 |
| **Packages** | RPM (dnf) and eopkg (built with solbuild) |
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

**Made for my own systems, Fedora and Solus. Works great on yours too.**

[⬆ Back to top](#top)

</div>
