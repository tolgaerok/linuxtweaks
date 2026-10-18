<a id="top"></a>

<div align="center">

# 🎩 Sources and references: Fedora

**Everything I read, borrowed ideas from and kept open in a tab while building LinuxTweaks for Fedora.**

[⬅ Back to the README](README.md) · [📚 All sources](SOURCES.md) · [🌀 Solus sources](SOURCES-SOLUS.md)

</div>

---

LinuxTweaks is built from a lot of reading. Man pages, the Fedora packaging guidelines, the kernel docs, the Arch Wiki (still the best Linux manual there is, even on Fedora) and plenty of trial and error on my own PCs: a G4 desktop with a GTX 1650 and an old ASUS laptop with a GTX 950M. This page lists the lot, grouped by what it helped with, with a small piece of the app next to it so you can see where it ended up.

The **Try it yourself** boxes are safe to paste. Most only read. The few that change something say so, and how to put it back.

If something here helped you too, the people who wrote it deserve the thanks.

## Contents

- [Packaging the RPM](#-packaging-the-rpm)
- [DNF and Flatpak](#-dnf-and-flatpak)
- [Updates that don't go in](#-updates-that-dont-go-in)
- [Offline, and checking the second it's back](#-offline-and-checking-the-second-its-back)
- [Restarting services after an update](#-restarting-services-after-an-update)
- [A new LinuxTweaks within seconds](#-a-new-linuxtweaks-within-seconds)
- [Usage sharing, only if you say yes](#-usage-sharing-only-if-you-say-yes)
- [The GPU tab: NVIDIA, Negativo17 and RPM Fusion](#-the-gpu-tab-nvidia-negativo17-and-rpm-fusion)
- [Health and the report](#-health-and-the-report)
- [systemd: timers, services and sleep](#%EF%B8%8F-systemd-timers-services-and-sleep)
- [Root without sudo rules: polkit](#-root-without-sudo-rules-polkit)
- [Desktop standards](#%EF%B8%8F-desktop-standards)
- [The tray and window: Python and Qt](#-the-tray-and-window-python-and-qt)
- [Drives: schedulers and read-ahead](#-drives-schedulers-and-read-ahead)
- [Memory: zram and sysctl](#-memory-zram-and-sysctl)
- [Network: BBR, CAKE and NetworkManager](#-network-bbr-cake-and-networkmanager)
- [Kernels](#-kernels)
- [CPU scheduler: sched_ext](#-cpu-scheduler-sched_ext)
- [Boxes: distrobox and LumineCapture](#-boxes-distrobox-and-luminecapture)
- [Nix](#%EF%B8%8F-nix)
- [Extras: WPS Office](#-extras-wps-office)
- [Bash](#-bash)
- [The look](#-the-look)
- [My own repo, releases and Tailscale](#-my-own-repo-releases-and-tailscale)

---

## 📦 Packaging the RPM

The spec file is where I spent the most time reading. Getting scriptlets right matters, a bad `%preun` can leave a timer running after the app is gone.

| Source | What I used it for |
|---|---|
| [Fedora Packaging Guidelines](https://docs.fedoraproject.org/en-US/packaging-guidelines/) | The rules for the whole spec: naming, `Obsoletes` when an app is renamed, file ownership |
| [Fedora: Scriptlets](https://docs.fedoraproject.org/en-US/packaging-guidelines/Scriptlets/) | `%post`, `%preun`, `%postun`, `%posttrans`, and telling an install from an upgrade from a removal |
| [Fedora: Systemd](https://docs.fedoraproject.org/en-US/packaging-guidelines/Systemd/) | The `%systemd_post` and `%systemd_preun` macros, and why a package shouldn't switch units on by itself |
| [Fedora: Python](https://docs.fedoraproject.org/en-US/packaging-guidelines/Python/) | `python3dist(...)` style requires |
| [Fedora: Versioning](https://docs.fedoraproject.org/en-US/packaging-guidelines/Versioning/) | Version and Release, and keeping upgrades going forward |
| [Fedora: Packaging tutorial](https://docs.fedoraproject.org/en-US/package-maintainers/Packaging_Tutorial_GNU_Hello/) | Where I started, a whole spec from nothing |
| [RPM spec file reference](https://rpm-software-management.github.io/rpm/manual/spec.html) | Every section and tag |
| [RPM dependencies](https://rpm-software-management.github.io/rpm/manual/dependencies.html) | `Requires(post)` and friends, so a scriptlet's tools are there when it runs |
| [RPM man pages](https://rpm-software-management.github.io/rpm/man/) | `rpmsign` for signing, `rpm -q --changelog` for the What's new window |
| [rpmkeys](https://rpm-software-management.github.io/rpm/man/rpmkeys.8) | Checking a download is signed with my key, in a keyring of its own so the system's keys stay as they are |

How it looks in my spec. The weekly maintenance timer is handled by Fedora's own macros, and the renamed apps are swapped out with `Obsoletes`:

```spec
Requires:       dnf5-command(needs-restarting)
Requires(post): systemd
Obsoletes:      linuxtweaks-io < 2.0

%post
%systemd_post %{name}-maintenance.timer

%preun
%systemd_preun %{name}-maintenance.timer %{name}-maintenance.service
```

### Try it yourself

What's in an RPM, before you install it:

```bash
rpm -qip linuxtweaks-updater-8.2.67-1.fc44.noarch.rpm      # name, version, summary
rpm -qlp linuxtweaks-updater-8.2.67-1.fc44.noarch.rpm      # every file it puts on your PC
rpm -qp --scripts linuxtweaks-updater-8.2.67-1.fc44.noarch.rpm   # what it runs when it installs
rpm -qp --changelog linuxtweaks-updater-8.2.67-1.fc44.noarch.rpm | head   # what's new in it
```

Is it really signed by me? A throwaway keyring, so nothing on your system changes:

```bash
mkdir -p /tmp/keys
rpmkeys --dbpath /tmp/keys --import /usr/share/linuxtweaks-updater/RPM-GPG-KEY-linuxtweaks
rpmkeys --dbpath /tmp/keys --checksig linuxtweaks-updater-8.2.67-1.fc44.noarch.rpm
```

`digests signatures OK` means it's mine and nobody changed it.

## 📡 DNF and Flatpak

The Updates tab is mostly dnf5 and flatpak, run as you, with their output read line by line.

| Source | What I used it for |
|---|---|
| [dnf5 documentation](https://dnf5.readthedocs.io/en/latest/) | The starting point for every dnf command the app runs |
| [dnf5 check-upgrade](https://dnf5.readthedocs.io/en/latest/commands/check-upgrade.8.html) | What's waiting. `check-update` is the same command under its old name |
| [dnf5 advisory](https://dnf5.readthedocs.io/en/latest/commands/advisory.8.html) | Which updates are security fixes and how bad, as JSON |
| [dnf5 needs-restarting](https://dnf5.readthedocs.io/en/latest/dnf5_plugins/needs_restarting.8.html) | Reboot needed or not, and which services still run old code |
| [dnf5.conf](https://dnf5.readthedocs.io/en/latest/dnf5.conf.5.html) | `metadata_expire`, and how a repo decides its list is old |
| [Flatpak command reference](https://docs.flatpak.org/en/latest/flatpak-command-reference.html) | `flatpak remote-ls --updates` and `flatpak update` |
| [Bodhi](https://bodhi.fedoraproject.org/) | Fedora's update system, where the advisories come from |

The check. Fedora's updates list only counts as old after 6 hours, so I tell dnf an hour is enough, and a check you ask for always gets a fresh list:

```bash
dnf_fresh=(--setopt='*.metadata_expire=1h')
[ "$LINUXTWEAKS_UPDATER_MANUAL" = "1" ] && dnf_fresh=(--refresh)
dnf -y "${dnf_fresh[@]}" check-update </dev/null
```

The `-y` and `</dev/null` are there because dnf run as you keeps its own copy of repo keys and can stop to ask about one. Nobody sees that question in a background check.

### Try it yourself

The same questions the app asks, by hand:

```bash
dnf check-upgrade                  # what's waiting
dnf advisory list --security       # which of those are security fixes
dnf needs-restarting -r            # does the last update need a reboot
flatpak remote-ls --updates        # Flatpak apps with an update
rpm -q --changelog firefox | head  # what changed in a package you have
```

## 🧱 Updates that don't go in

dnf can finish happily, exit code 0, and still not install something. It prints `Skipping packages with conflicts` and `Nothing to do`, and the update sits there "waiting" forever. Mine did on the laptop: an old RPM Fusion package (`vlc-plugins-freeworld`) needed x265 4.1, Negativo17 had 4.2, so dnf skipped x265 and everything that needed it. Since 8.2.31 the update window checks with rpm what really went in, and shows what dnf held back and dnf's own reason.

The other half: the count was 2 too many. Under `Obsoleting packages` dnf lists what an update *replaces* (gdk-pixbuf2 under libheif, the same version both sides). Those aren't updates.

| Source | What I used it for |
|---|---|
| [dnf5 upgrade](https://dnf5.readthedocs.io/en/latest/commands/upgrade.8.html) | `--best`, `--skip-broken` and why a skipped package isn't an error |
| [dnf5 check-upgrade](https://dnf5.readthedocs.io/en/latest/commands/check-upgrade.8.html) | The "Obsoleting packages" list and what it means |
| [dnf5 history](https://dnf5.readthedocs.io/en/latest/commands/history.8.html) | What a transaction really did |
| [dnf5 swap](https://dnf5.readthedocs.io/en/latest/commands/swap.8.html) and [distro-sync](https://dnf5.readthedocs.io/en/latest/commands/distro-sync.8.html) | Moving packages from one repo's build to another's |
| [RPM query formats](https://rpm-software-management.github.io/rpm/manual/queryformat.html) | `%{EPOCH}:%{VERSION}-%{RELEASE}`, so the app can compare versions properly |

The check after the install, in the update window. A package that's gone was replaced, that counts as done:

```python
out = subprocess.run(["rpm", "-q", "--qf", "%{NAME} %{EPOCH}:%{VERSION}-%{RELEASE}\n", *names], ...)
held = [r for r in rows if r[0] in have and bare(r[2]) not in have[r[0]]]
```

And in `check.sh`, stop counting at dnf's obsoletes list:

```awk
/^Obsoleting/ { obs = 1 } obs { next }
```

### Try it yourself

Did your last update really install everything? What dnf did, then what's still waiting:

```bash
dnf history list | head -3                 # the last few transactions
dnf history info last | head -20           # what the last one really changed
dnf check-upgrade                          # anything still waiting?
```

What replaces what. Empty means nothing's being swapped:

```bash
dnf check-upgrade | sed -n '/Obsoleting/,$p'
```

Before and after, the way the app checks one package:

```bash
rpm -q --qf '%{NAME} %{EPOCH}:%{VERSION}-%{RELEASE}\n' bash
```

`(none):` means the package has no epoch. Most don't.

## 📶 Offline, and checking the second it's back

A check with no internet used to say "up to date". dnf couldn't reach a single repo, fell back on the old list, and the tray went green. Wrong, and the worst kind of wrong, because you stop looking. Now the check asks NetworkManager first, the way Discover does: State 70 is online for real, wifi off leaves it on 50 while Tailscale and `lo` still look up. Not 70 and it doesn't even try, it says no internet and the old lists stay.

The other half is coming back. The tray listens to NetworkManager on D-Bus, and the moment State goes back to 70 after any failed check it checks straight away. No sitting out the 5 minute retry. Fedora's own connectivity check (`NetworkManager-config-connectivity-fedora`) is what makes "wifi up but no internet" drop to 60 too, so that comes back right as well.

| Source | What I used it for |
|---|---|
| [NetworkManager D-Bus types: NMState](https://networkmanager.dev/docs/api/latest/nm-dbus-types.html) | 70 is `CONNECTED_GLOBAL`, 60 is `CONNECTED_SITE`, 50 is `CONNECTED_LOCAL` |
| [NetworkManager.conf: connectivity](https://networkmanager.dev/docs/api/latest/NetworkManager.conf.html) | How NM checks it can really reach the internet, and how often |
| [dnf5.conf](https://dnf5.readthedocs.io/en/latest/dnf5.conf.5.html) | `retries=2` and `timeout=15`, so a flaky line gets a second go but a dead one doesn't hang the check |
| [QDBusConnection](https://doc.qt.io/qt-5/qdbusconnection.html) | The tray hearing NM's `StateChanged` |

The check, before dnf goes anywhere near the internet:

```bash
st=$(busctl get-property org.freedesktop.NetworkManager /org/freedesktop/NetworkManager \
	org.freedesktop.NetworkManager State 2>/dev/null) || return 0
[ "$st" = "u 70" ]
```

### Try it yourself

```bash
busctl get-property org.freedesktop.NetworkManager /org/freedesktop/NetworkManager org.freedesktop.NetworkManager State
nmcli networking connectivity        # full, limited, portal or none
```

Turn the wifi off and run the first one again, it drops from `u 70`. That's all the tray waits for.

## 🔁 Restarting services after an update

After an update some services still run the old code from before it. The upgrade window lists them under **Still running old code**, with a tick box each. The safe ones are ticked. The ones that cut something off start unticked with an orange line saying why: your internet, bluetooth, VPNs and Tailscale, network shares, docker, podman and VMs. Nothing restarts by itself, you press **Restart ticked** or **Restart all**. Your login screen, dbus, logind and polkit never show up at all, restarting those logs you out or worse.

I looked at how the others do it first. Fedora's own `needs-restarting` only lists them. needrestart asks by default, and its `override_rc` list of "don't restart these" is where most of my careful list comes from. arch-update on CachyOS asks with numbers.

| Source | What I used it for |
|---|---|
| [dnf5 needs-restarting](https://dnf5.readthedocs.io/en/latest/dnf5_plugins/needs_restarting.8.html) | `-s`, which services still run old code |
| [needrestart](https://github.com/liske/needrestart) | Its `override_rc` list in `needrestart.conf`, the services it won't touch without asking |
| [arch-update](https://github.com/Antiz96/arch-update) | How CachyOS asks, numbers, 0 for all, Enter for none |
| [systemctl](https://www.freedesktop.org/software/systemd/man/latest/systemctl.html) | `restart` for each one you ticked, as root through my helper and one password box |

### Try it yourself

```bash
dnf needs-restarting -s        # services still running old code
dnf needs-restarting -r        # does the PC itself need a reboot
```

## 🆕 A new LinuxTweaks within seconds

A new version used to show up at the next update check, and with checks once a week that could be days. Now the tray takes one tiny look every 30 seconds, whatever your check interval. On my tailnet it reads my repo's file list, 538 bytes. Off it, the version badge in this README on raw GitHub. Only when that says something newer does the real check run, with downloads and signatures.

Why not the GitHub API every 30 seconds? It's 60 requests an hour without a login, and a "not modified" answer still counts. Raw GitHub has no limit like that but caches for 5 minutes (`max-age=300`), so worst case it's 5 minutes behind. It gives an ETag, so when nothing changed the answer is a 304 with no body at all.

| Source | What I used it for |
|---|---|
| [GitHub REST API: rate limits](https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api) | 60 an hour unauthenticated, why the 30 second look stays off the API |
| [MDN: conditional requests](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Conditional_requests) | ETag, `If-None-Match` and the 304 |
| [nginx autoindex](https://nginx.org/en/docs/http/ngx_http_autoindex_module.html) | My repo's plain file list, the cheapest thing to read |

### Try it yourself

The badge, then the same again with its ETag. The second one comes back `304` and empty:

```bash
url=https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/README.md
etag=$(curl -sI "$url" | grep -i '^etag' | cut -d' ' -f2 | tr -d '\r')
curl -s "$url" | grep -o 'badge/Version-[0-9.]*'
curl -s -o /dev/null -w '%{http_code}\n' -H "If-None-Match: $etag" "$url"
```

## 📊 Usage sharing, only if you say yes

A day after you get 8.2.65 or newer, a popup asks if you'll send me a tiny hello once a week. Say no, or close it, and it never asks again and nothing is ever sent. Say yes and once a week it sends the LinuxTweaks version, distro and release, desktop, graphics make, roughly how long it's been installed, and how many update checks worked or failed. No name, no machine id, no package lists, no files. **Show me** has the exact line, and the card under Settings shows what went out last, each bit on its own little card. One switch turns it off.

There's no id for your PC at all. That's Fedora's countme idea: each PC says hello once a week, so counting the hellos in a week is counting the PCs. The age bucket is countme's too, 1 to 4. An upgrade shows because the hello after it says what it was before.

The hellos go to a small Cloudflare Worker of mine with a D1 database behind it. Cloudflare tells the Worker the country, that gets stored and the IP doesn't, and the Worker's logs are switched off. The ask first, show everything style is how KDE does it with KUserFeedback.

| Source | What I used it for |
|---|---|
| [Fedora: DNF better counting](https://fedoraproject.org/wiki/Changes/DNF_Better_Counting) | countme: a weekly hello, no id, age buckets |
| [dnf5.conf: countme](https://dnf5.readthedocs.io/en/latest/dnf5.conf.5.html) | The option itself |
| [KUserFeedback](https://invent.kde.org/frameworks/kuserfeedback) | KDE's way: off till you say yes, says what it collects, a switch in settings |
| [Cloudflare Workers](https://developers.cloudflare.com/workers/) and [D1](https://developers.cloudflare.com/d1/) | The Worker that takes the hello and the database it goes in |
| [Workers: Request, cf properties](https://developers.cloudflare.com/workers/runtime-apis/request/) | `request.cf.country`, the country without keeping the IP |
| [Workers Logs](https://developers.cloudflare.com/workers/observability/logs/workers-logs/) | Switched off, logs can keep request details |

### Try it yourself

What your PC would send, without sending anything:

```bash
cd /usr/lib/linuxtweaks-updater && python3 -m tray.usage
```

## 🎮 The GPU tab: NVIDIA, Negativo17 and RPM Fusion

Fedora can't ship the NVIDIA driver or full codecs, so they come from a third party repo. There are two good ones, [Negativo17](https://negativo17.org/nvidia-driver/) and [RPM Fusion](https://rpmfusion.org/Howto/NVIDIA), and they **can't be mixed**. They ship the same things under different names: with both on, updates fail or the driver gets swapped half way. The GPU tab lets you pick one, warns when both are on, and moves you over cleanly.

Then which branch. NVIDIA's 590 and up dropped Maxwell, Pascal and Volta (GTX 900, GTX 10, my laptop's GTX 950M). The 580 branch is their last one, both repos have it, and the tab picks it by itself for those cards.

Then the settings Solus ships in its own nvidia package that Fedora doesn't: faster GPU memory (PAT), no memory zeroing, nova blocked, egl-wayland 1, full preemption and hugepages. That's where the "Same as Solus" button comes from. [The Solus page](SOURCES-SOLUS.md#-nvidia-on-solus) has Solus's own words on each one.

| Source | What I used it for |
|---|---|
| [Negativo17: NVIDIA driver](https://negativo17.org/nvidia-driver/) | His repo, the package names (`nvidia-driver`, `akmod-nvidia`, `nvidia-driver-cuda`, `nvidia-driver-libs.i686`), open vs closed modules, Secure Boot |
| [Negativo17: 580 LTS repository](https://negativo17.org/nvidia-driver-580-lts-repository/) | `fedora-nvidia-580` for Maxwell, Pascal and Volta, and priority 90 so his multimedia repo doesn't pull in a newer driver |
| [Negativo17: Multimedia](https://negativo17.org/multimedia/) | `fedora-multimedia`: full ffmpeg, the codecs, HandBrake, mpv |
| [RPM Fusion: Configuration](https://rpmfusion.org/Configuration) | Turning on free and nonfree |
| [RPM Fusion: NVIDIA howto](https://rpmfusion.org/Howto/NVIDIA) | `akmod-nvidia`, the `-580xx` packages, and waiting for the akmod to build before you reboot |
| [RPM Fusion: Multimedia](https://rpmfusion.org/Howto/Multimedia) | Swapping `ffmpeg-free` for full ffmpeg |
| [Fedora: Enabling RPM Fusion](https://docs.fedoraproject.org/en-US/quick-docs/rpmfusion-setup/) | Fedora's own page on it |
| [Fedora Workstation: third-party repositories](https://docs.fedoraproject.org/en-US/workstation-working-group/third-party-repos/) | What Fedora offers you itself, and that it doesn't support what's in them |
| [NVIDIA: Unix graphics deprecation schedule](https://forums.developer.nvidia.com/t/unix-graphics-feature-deprecation-schedule/60588) | 580 is the last branch for Maxwell, Pascal and Volta |
| [NVIDIA driver README (580)](https://download.nvidia.com/XFree86/Linux-x86_64/580.95.05/README/index.html) | The `NVreg_` options, [power management](https://download.nvidia.com/XFree86/Linux-x86_64/580.95.05/README/powermanagement.html) and the [open kernel modules](https://download.nvidia.com/XFree86/Linux-x86_64/580.95.05/README/kernel_open.html) |
| [NVIDIA open GPU kernel modules](https://github.com/NVIDIA/open-gpu-kernel-modules) | Which cards the open modules support (Turing and newer) |
| [egl-wayland](https://github.com/NVIDIA/egl-wayland) and [egl-wayland2](https://github.com/NVIDIA/egl-wayland2) | The two Wayland bridges, and how the JSON files pick one |
| [Kernel: nova](https://docs.kernel.org/gpu/nova/index.html) | The new in-kernel NVIDIA driver the tab blocks |
| [modprobe.d](https://man7.org/linux/man-pages/man5/modprobe.d.5.html) | Where the driver options and the blacklist go |
| [Arch Wiki: NVIDIA](https://wiki.archlinux.org/title/NVIDIA) | Plain explanations of most of the above |

The rule the tab follows, before anything moves to Negativo17's multimedia: RPM Fusion's `*-freeworld` add-ons pin old libraries, so Fedora's plain version goes back in where there is one, the rest goes:

```bash
for fw in $(rpm -qa --qf '%{NAME}\n' '*-freeworld' | sort -u); do
	plain=${fw%-freeworld}
	if [ -n "$(dnf5 repoquery --available --qf '%{name}\n' "$plain")" ]; then
		dnf swap --allowerasing "$fw" "$plain"
	else
		dnf remove --noautoremove "$fw"
	fi
done
```

A few things I learned the hard way:

- **Never NVIDIA's `.run` installer** on Fedora. RPM Fusion's own page warns it overwrites libraries the packages own.
- **Wait for akmod** after installing or changing the driver. It builds the module for your kernel, up to a few minutes. Reboot too early and you get basic graphics.
- **Secure Boot** needs the module signed with your own key, or turned off. Negativo17's page explains both.
- **PAT only shows up on the closed driver.** On the 580 closed module `UsePageAttributeTable` appears in `/proc/driver/nvidia/params`. The open modules (Turing and up) don't list it.
- **No memory zeroing is a trade.** It's a little faster, but memory the driver hands out isn't wiped first. Solus's own config file says it costs some security. Your call.

### Try it yourself

**Is my card too old for the newest driver?** Below 7.5 means 580 is your last branch:

```bash
nvidia-smi --query-gpu=name,compute_cap,driver_version --format=csv,noheader
```

```
NVIDIA GeForce GTX 950M, 5.0, 580.178.04
```

**Open or closed driver?** `Dual MIT/GPL` is open, `NVIDIA` is closed:

```bash
modinfo -F license nvidia
```

**Which repo did my driver and codecs come from?** dnf remembers for every package:

```bash
dnf repoquery --installed --qf '%{name} %{from_repo}\n' | grep -E 'nvidia|ffmpeg|x265'
```

**Spot a clash before it bites.** Both kinds of repo on, or an RPM Fusion add-on left behind:

```bash
dnf repolist --enabled | grep -iE 'rpmfusion|negativo|multimedia|nvidia'
rpm -qa '*-freeworld'
```

**What's the driver really doing?** The settings from the GPU tab, live:

```bash
grep -E 'PageAttributeTable|InitializeSystemMemory|PreserveVideoMemory' /proc/driver/nvidia/params
```

**Which Wayland bridge loads first?** The lowest number wins, a file in `/etc` with the same name beats the one in `/usr/share`:

```bash
ls /usr/share/egl/egl_external_platform.d/ /etc/egl/egl_external_platform.d/ 2>/dev/null
```

**Laptop with two GPUs?** Which one draws the desktop (`Default: yes`) and the environment that sends an app to the other one:

```bash
switcherooctl list
```

## 🩺 Health and the report

The Health tab is a quick look over the whole PC, read only and no password: failed services, errors, disk, memory, crashes, SELinux, packages, the kernel, logs, autostart and since 8.2.67 Background extras. Since 8.2.26 it has a **📋 Report…** button, Brian's idea: everything it found as plain text, worst first, with the real error lines behind the red and orange cards, to copy into a message or save. Nothing leaves the PC unless you send it.

The hard part is noise. Every desktop logs errors that mean nothing, and a report full of them hides the one that matters. Brian's first report had the same plasmashell line 39 times and his real errors pushed off the end. So the card and the report share one list of known noise, repeats show once with ×N, and the report just says how many it left out.

Started from ssh or sudo there's no screen, Qt gave up and Health counted every one as a crash, 5 in a week on my PC. Now the tray borrows your desktop session's screen from `systemctl --user show-environment`, and says so plainly when there's none.

**Background extras** came from my G4 feeling slow. Nothing was wrong with it, it was just doing things twice: dnf-makecache refreshing every 3 hours while LinuxTweaks checks every 30 minutes, Discover's notifier checking at login, abrt and DrKonqi both catching every crash, and PCP I'd forgotten about. The card only lists what's really there. Switch off disables, never removes, and Undo puts it back. Discover's notifier goes the way KDE's own Autostart settings do it, a copy in `~/.config/autostart` with `Hidden=true`, no password. The rest goes through the tweaks helper, which only knows a fixed list of units for each one.

Logging out was the other one. Plasma stops KWin, and everything still on the desktop (kwallet, the portal, tray apps) falls over with it and dumps core. Those aren't crashes, so since 8.2.34 any dump within 15 seconds of `org.kde.Shutdown` starting is left out.

| Source | What I used it for |
|---|---|
| [journalctl](https://www.freedesktop.org/software/systemd/man/latest/journalctl.html) | `-b -p err` for this boot's errors, `--since` for Count from now |
| [systemd-coredump](https://www.freedesktop.org/software/systemd/man/latest/systemd-coredump.html) | Every crash lands in the journal as "dumped core". Since 8.2.34 the Crashes card and the report read those lines, Solus doesn't have coredumpctl |
| [coredumpctl](https://www.freedesktop.org/software/systemd/man/latest/coredumpctl.html) | Looking at a crash yourself, where your distro has it |
| [df](https://man7.org/linux/man-pages/man1/df.1.html) | The disk card. `-l` for your own drives only, and `timeout 10`: df used to wait on every NFS and SMB share behind it, and my sshfs mount showed the server's disk as mine |
| [systemctl](https://www.freedesktop.org/software/systemd/man/latest/systemctl.html) | `--failed`, `status` for the report, and `reset-failed` behind the Forget them button |
| [sudo](https://www.sudo.ws/docs/man/sudo.man/) | Why `sudo -n true` logs "a password is required" every time it says no, so it counts as noise |
| [DrKonqi](https://invent.kde.org/plasma/drkonqi) | KDE's crash pickup, which times out after 30 minutes on every KDE desktop and isn't a real failed service |
| [ddcutil](https://www.ddcutil.com/) and [its i2c permissions page](https://www.ddcutil.com/i2c_permissions/) | KDE's monitor brightness over DDC, and why powerdevil logs "Permission denied" when screens change |
| [Kernel: i2c-dev](https://docs.kernel.org/i2c/dev-interface.html) | What `/dev/i2c-*` are |
| [Fedora: SELinux](https://docs.fedoraproject.org/en-US/quick-docs/selinux-getting-started/) | The SELinux card and what "denied" means |
| [QClipboard](https://doc.qt.io/qt-5/qclipboard.html) and [QFileDialog](https://doc.qt.io/qt-5/qfiledialog.html) | The report's Copy and Save buttons |
| [freedesktop: Autostart spec](https://specifications.freedesktop.org/autostart-spec/latest/) | Background extras: a file in your own autostart folder wins over the system one, and `Hidden=true` there means it doesn't start |
| [Fedora bug 1187111](https://bugzilla.redhat.com/show_bug.cgi?id=1187111) and [bug 1120368](https://bugzilla.redhat.com/show_bug.cgi?id=1120368) | dnf-makecache stays in Fedora on purpose, and switching it off is fine, dnf gets its lists when it needs them |
| [Fedora Discussion: dnf metadata](https://discussion.fedoraproject.org/t/dnf-cant-be-prevented-from-trying-to-update-metadata/29841) | `systemctl disable --now dnf-makecache.timer`, and that `metadata_expire` decides the rest |

The report reads the noise list straight out of `health.sh`, so the card and the report can never disagree:

```python
m = re.search(r"^noise='(.*)'$", _read(f"{LIBDIR}/health.sh"), re.M)
noise = re.compile(m.group(1))
```

### Try it yourself

**The top 5 things your PC complains about this boot.** Numbers are swapped for N so the same message counts once:

```bash
journalctl -b -p err -o cat --no-pager | sed -E 's/[0-9]+/N/g' | sort | uniq -c | sort -rn | head -5
```

**Count from now, by hand.** Only the errors since you sat down:

```bash
journalctl --since "10 min ago" -p err --no-pager
```

**Was that crash while you were using it, or at shutdown?** Compare the crash times with when each boot ended:

```bash
coredumpctl list --no-pager | tail -5
journalctl --list-boots --no-pager | tail -2
```

Crashes a few seconds before a boot's last line are apps getting killed on the way down. Nothing to fix.

**Crashes from the journal, the way the card reads them.** Works on Solus too, no coredumpctl needed. A logout shows up as `org.kde.Shutdown` right before a bunch of dumps:

```bash
journalctl --since "-7 days" -t systemd-coredump -t systemd -o short --no-pager | grep -E 'dumped core|org\.kde\.Shutdown@'
```

**Your disks without the network ones**, what the disk card looks at:

```bash
df -h -l -x tmpfs -x devtmpfs -x squashfs -x overlay -x efivarfs -x fuse.sshfs -x autofs
```

**Watch sudo log a "no".** This is what used to show up as an error after my release window ran:

```bash
sudo -k; sudo -n true; journalctl -t sudo -n 1 --no-pager -o cat
```

**Forget failed services.** What the Forget them button does. Only clears the red mark, it doesn't change the service:

```bash
systemctl --user --failed
systemctl --user reset-failed
```

**Change your monitor's brightness from the terminal.** The same DDC that KDE's brightness slider uses (install `ddcutil` first, it needs a monitor with DDC/CI on):

```bash
ddcutil detect --brief
ddcutil getvcp 10              # brightness now, 0 to 100
ddcutil setvcp 10 60           # set it to 60
```

## ⚙️ systemd: timers, services and sleep

| Source | What I used it for |
|---|---|
| [systemd.timer](https://www.freedesktop.org/software/systemd/man/latest/systemd.timer.html) | `OnBootSec`, `OnUnitActiveSec`, `Persistent` and `RandomizedDelaySec` for the check timer |
| [systemd.service](https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html) | Oneshot services for the check and the weekly maintenance |
| [systemd-run](https://www.freedesktop.org/software/systemd/man/latest/systemd-run.html) | Starting the upgrade window and the tray in their own units, so closing one doesn't take the other with it |
| [org.freedesktop.login1](https://www.freedesktop.org/software/systemd/man/latest/org.freedesktop.login1.html) | The `PrepareForSleep` signal, so the tray checks again after the PC wakes up |
| [loginctl](https://www.freedesktop.org/software/systemd/man/latest/loginctl.html) | Linger. Up to 8.2.65 the RPM switched it on for every user, which keeps a user's systemd running from boot even with nobody logged in, so other accounts ran the update check every 30 minutes for no one. Since 8.2.66 it switches it back off for the users it turned on, and the check asks `loginctl show-session` for an x11 or wayland session first |
| [journald.conf](https://www.freedesktop.org/software/systemd/man/latest/journald.conf.html) | `SystemMaxUse` for Keep logs up to |
| [sysctl.d](https://www.freedesktop.org/software/systemd/man/latest/sysctl.d.html) | Where my sysctl files go and why they're named `99-zz-` |
| [Arch Wiki: systemd/Timers](https://wiki.archlinux.org/title/Systemd/Timers) | The clearest explanation of timers I found |
| [Arch Wiki: systemd/User](https://wiki.archlinux.org/title/Systemd/User) | User units and how they start |

The check timer:

```ini
[Timer]
OnBootSec=30s
OnUnitActiveSec=30min
Persistent=true
RandomizedDelaySec=5s
```

Hearing the PC wake up, in the tray:

```python
QDBusConnection.systemBus().connect(
    "org.freedesktop.login1", "/org/freedesktop/login1",
    "org.freedesktop.login1.Manager", "PrepareForSleep", self.prepare_for_sleep,
)
```

### Try it yourself

```bash
systemctl --user list-timers                        # my check timer and when it runs next
systemctl --user status linuxtweaks-updater-check.timer
journalctl --user -u linuxtweaks-updater-check.service -n 20   # its last runs
```

Run anything in its own little unit, so closing the terminal doesn't stop it:

```bash
systemd-run --user --collect sleep 60
systemctl --user list-units 'run-*'
```

The smallest service file there is, `~/.config/systemd/user/hello.service`:

```ini
[Unit]
Description=Says hello

[Service]
Type=oneshot
ExecStart=/usr/bin/notify-send "Hello" "from systemd"
```

```bash
systemctl --user daemon-reload && systemctl --user start hello
```

## 🔐 Root without sudo rules: polkit

Older versions of my updater used sudo rules with no password. That's gone. Now every change that needs root goes through a small helper and one polkit password box. The GPU tab got its own helper, `linuxtweaks-updater-gpu`, that only knows its few jobs.

| Source | What I used it for |
|---|---|
| [polkit](https://www.freedesktop.org/software/polkit/docs/latest/polkit.8.html) | How actions and the password box work |
| [pkexec](https://www.freedesktop.org/software/polkit/docs/latest/pkexec.1.html) | Running one helper as root, after the password box |
| [Arch Wiki: Polkit](https://wiki.archlinux.org/title/Polkit) | Writing the `.policy` file, with examples |

Each helper only does its one job and checks everything it's handed. The Drives helper won't write a rule unless it matches exactly what it expects:

```bash
rule='^ACTION=="add\|change", SUBSYSTEM=="block", ENV\{DEVTYPE\}=="disk", ...'
```

### Try it yourself

One command as root, after the normal password box:

```bash
pkexec whoami    # prints root, after the password box
```

A minimal polkit action, it's what lets one of my helpers run without a sudo rule. In `/usr/share/polkit-1/actions/`:

```xml
<action id="org.example.hello">
  <description>Say hello as root</description>
  <message>Hello wants to run as root</message>
  <defaults>
    <allow_active>auth_admin_keep</allow_active>
  </defaults>
  <annotate key="org.freedesktop.policykit.exec.path">/usr/local/bin/hello-helper</annotate>
</action>
```

`auth_admin_keep` remembers your password for a few minutes, so two changes in a row only ask once. That's how Same as Solus turns six things on with one password.

## 🖥️ Desktop standards

| Source | What I used it for |
|---|---|
| [Desktop Notifications spec](https://specifications.freedesktop.org/notification-spec/latest/) | Popups with buttons, and closing an old popup when a newer one comes |
| [notify-send](https://man.archlinux.org/man/notify-send.1) | Sending them from Bash, `-r` to replace one that's still on screen |
| [Desktop Entry spec](https://specifications.freedesktop.org/desktop-entry-spec/latest/) | The menu launcher |
| [Autostart spec](https://specifications.freedesktop.org/autostart-spec/latest/) | Starting the tray when you log in |
| [XDG Base Directory spec](https://specifications.freedesktop.org/basedir-spec/latest/) | Why the results live in `~/.local/state/linuxtweaks-updater/` |

### Try it yourself

A popup with buttons. notify-send waits and prints the one you clicked:

```bash
choice=$(notify-send -A install="Install now" -A later="Later" "3 updates waiting" "Pick one")
echo "you clicked: $choice"
```

`-t 0` keeps it up till you click, `-p` prints its number so you can close it from a script later.

## 🐍 The tray and window: Python and Qt

| Source | What I used it for |
|---|---|
| [PyQt5 reference](https://www.riverbankcomputing.com/static/Docs/PyQt5/) | How the Qt classes look from Python |
| [QSystemTrayIcon](https://doc.qt.io/qt-5/qsystemtrayicon.html) | The tray icon, its tooltip and its menu |
| [QProcess](https://doc.qt.io/qt-5/qprocess.html) | Running dnf and the helpers without freezing the window |
| [QFileSystemWatcher](https://doc.qt.io/qt-5/qfilesystemwatcher.html) | Redrawing the moment a check writes new results. Since 8.2.47 it watches the rpm or eopkg database and Flatpak too, an update done anywhere gets a check a few seconds after, and the Nix tab watches its profile folder and ~/default.nix |
| [QSvgRenderer](https://doc.qt.io/qt-5/qsvgrenderer.html) | The small Fedora, Debian, Arch and Ubuntu logos on the Boxes tab, drawn in the app so every desktop has them |
| [proc(5): /proc/stat btime](https://man7.org/linux/man-pages/man5/proc_stat.5.html) | When this boot started. A Reboot required written before it is about the boot before, so it doesn't show |
| [QDBusConnection](https://doc.qt.io/qt-5/qdbusconnection.html) | Listening to logind |
| [QTimer](https://doc.qt.io/qt-5/qtimer.html) | The countdown to the next check |
| [Qt Style Sheets](https://doc.qt.io/qt-5/stylesheet-reference.html) | The cards, buttons, tabs and the GPU tab's radio buttons |
| [Python subprocess](https://docs.python.org/3/library/subprocess.html), [json](https://docs.python.org/3/library/json.html), [pathlib](https://docs.python.org/3/library/pathlib.html), [re](https://docs.python.org/3/library/re.html) | The small jobs around it |
| [QThread](https://doc.qt.io/qt-5/qthread.html) | Checking for LinuxTweaks updates and downloading them without freezing About |
| [QPainter](https://doc.qt.io/qt-5/qpainter.html) | Drawing the on/off switches and the spinning dots |
| [Python pty](https://docs.python.org/3/library/pty.html) | A pretend terminal, so dnf5 draws its live progress bars in the install window |
| [console_codes](https://man7.org/linux/man-pages/man4/console_codes.4.html) | What `\r`, `ESC[1A` and `ESC[0J` mean, so the window can redraw dnf's bars in place |
| [Python urllib](https://docs.python.org/3/library/urllib.request.html) | Downloading the new RPM from my repo or GitHub |
| [GitHub REST API: contents](https://docs.github.com/en/rest/repos/contents) | Finding the newest RPM in my GitHub folder |
| [QDialog](https://doc.qt.io/qt-5/qdialog.html) and [Qt::WindowFlags](https://doc.qt.io/qt-5/qt.html#WindowType-enum) | The new version popup since 8.2.35, my own window on top with what's new on it, not Plasma's bubble that was gone in 3 seconds |
| [QLayout::SetFixedSize](https://doc.qt.io/qt-5/qlayout.html#SizeConstraint-enum) | So that popup is exactly as tall as what's in it |

The tray doesn't ask for anything, it watches the state folder and redraws when a check is done:

```python
self.file_watcher = QFileSystemWatcher([str(STATE_DIR)])
```

### Try it yourself

The smallest tray icon, save it as `tray.py` and run `python3 tray.py`:

```python
import sys
from PyQt5.QtGui import QIcon
from PyQt5.QtWidgets import QApplication, QMenu, QSystemTrayIcon

app = QApplication(sys.argv)
tray = QSystemTrayIcon(QIcon.fromTheme("system-software-update"))
menu = QMenu()
menu.addAction("Quit", app.quit)
tray.setContextMenu(menu)
tray.setToolTip("Hello from my tray")
tray.show()
app.exec_()
```

Run a command without freezing the window, and read its output as it comes:

```python
from PyQt5.QtCore import QProcess

proc = QProcess()
proc.readyReadStandardOutput.connect(lambda: print(bytes(proc.readAllStandardOutput()).decode()))
proc.finished.connect(lambda code, _: print("done, exit code", code))
proc.start("dnf", ["check-upgrade"])
```

Something every second, like my countdown:

```python
from PyQt5.QtCore import QTimer

timer = QTimer()
timer.timeout.connect(lambda: print("tick"))
timer.start(1000)
```

Why dnf's bars only move in a terminal. Into a pipe it prints a line per finished package, in a pretend terminal it draws its bars:

```python
import pty
pty.spawn(["dnf", "makecache", "--refresh"])
```

A Copy button, like the Health report's. Paste somewhere after running it:

```python
import sys
from PyQt5.QtWidgets import QApplication

app = QApplication(sys.argv)
QApplication.clipboard().setText("hello from my clipboard")
input("copied, paste it somewhere, then press Enter")
```

The newest RPM in my GitHub folder, the same way About looks for it:

```python
import json, urllib.request

url = "https://api.github.com/repos/tolgaerok/linuxtweaks/contents/LINUXTWEAKS/RPM/linuxtweaks-updater%20v7x"
files = json.load(urllib.request.urlopen(url))
print([f["name"] for f in files if f["name"].endswith(".rpm")])
```

## 💽 Drives: schedulers and read-ahead

| Source | What I used it for |
|---|---|
| [Kernel: switching I/O schedulers](https://docs.kernel.org/block/switching-sched.html) | `/sys/block/<drive>/queue/scheduler` and what each scheduler is for |
| [udev](https://www.freedesktop.org/software/systemd/man/latest/udev.html) | Rules that set a drive's scheduler every boot |
| [Arch Wiki: udev](https://wiki.archlinux.org/title/Udev) | Matching a drive by serial number instead of its name |
| [Arch Wiki: Improving performance](https://wiki.archlinux.org/title/Improving_performance) | Schedulers per drive type, and read-ahead |
| [tuned](https://github.com/redhat-performance/tuned) | Why a tuned profile can win over my read-ahead at boot |
| [CachyOS kernels](https://github.com/CachyOS/linux-cachyos) | The `adios` scheduler, only there on CachyOS kernels |

What a Drives tab rule looks like, pinned to the drive's serial so it can't land on the wrong disk (the serial here is made up):

```
ACTION=="add|change", SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", ENV{ID_SERIAL}=="Samsung_SSD_870_EVO_1TB_S1234", ATTR{queue/scheduler}="kyber", ATTR{queue/read_ahead_kb}="512"
```

### Try it yourself

Which scheduler each drive uses, the one in brackets is on:

```bash
grep "" /sys/block/*/queue/scheduler
grep "" /sys/block/*/queue/read_ahead_kb
```

Change one now, it's back to normal after a reboot (a udev rule is what keeps it):

```bash
echo kyber | sudo tee /sys/block/sda/queue/scheduler
echo 256 | sudo tee /sys/block/sda/queue/read_ahead_kb
```

A drive's serial, what my rules match on:

```bash
udevadm info --query=property --name=/dev/sda | grep ID_SERIAL=
```

## 🧠 Memory: zram and sysctl

| Source | What I used it for |
|---|---|
| [Kernel: zram](https://docs.kernel.org/admin-guide/blockdev/zram.html) | What zram is and how compression works |
| [zram-generator](https://github.com/systemd/zram-generator) | The config file Fedora uses for zram |
| [Fedora: SwapOnZRAM](https://fedoraproject.org/wiki/Changes/SwapOnZRAM) | Why Fedora went with zram, and its defaults |
| [Kernel: vm sysctl](https://docs.kernel.org/admin-guide/sysctl/vm.html) | `swappiness`, `page-cluster`, `dirty_bytes`, `vfs_cache_pressure`, the watermarks |
| [Kernel: fs sysctl](https://docs.kernel.org/admin-guide/sysctl/fs.html) | `inotify` file watchers |
| [Kernel: kernel sysctl](https://docs.kernel.org/admin-guide/sysctl/kernel.html) | `panic` and `sysrq`, the safety net |
| [Kernel: transparent hugepages](https://docs.kernel.org/admin-guide/mm/transhuge.html) | `always` vs `madvise`, for the GPU tab's hugepages switch |
| [Kernel: multi-gen LRU](https://docs.kernel.org/admin-guide/mm/multigen_lru.html) | `min_ttl_ms`. 1000 keeps what you used in the last second in RAM, the kernel docs say it stops the freezes when RAM runs out. That's **No freeze when RAM runs out** |
| [tmpfiles.d](https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html) | It's sysfs, gone at reboot, so a `w-` line sets it again every boot |
| [AI-2](https://github.com/ProWoos-Devs/ai-2) | Where the multi-gen LRU idea came from, its boot-tuning.sh. MIT |
| [Arch Wiki: zram](https://wiki.archlinux.org/title/Zram) | Why swappiness above 100 makes sense with zram |
| [Arch Wiki: sysctl](https://wiki.archlinux.org/title/Sysctl) | Sensible values and what they cost |

What the Memory tab writes for zram:

```ini
[zram0]
zram-size = ram * 50 / 100
compression-algorithm = zstd
```

### Try it yourself

```bash
zramctl                          # your zram: size, compression, how much is in it
swapon --show                    # every swap you have
sysctl vm.swappiness             # how keen Linux is to swap
sudo sysctl vm.swappiness=150    # change it till the next boot
free -h                          # memory and swap in use
cat /sys/kernel/mm/transparent_hugepage/enabled   # hugepages: the one in brackets is on
cat /sys/kernel/mm/lru_gen/enabled               # 0x0007 means the multi-gen LRU is fully on
cat /sys/kernel/mm/lru_gen/min_ttl_ms            # 1000 with No freeze on, 0 without
```

## 🌐 Network: BBR, CAKE and NetworkManager

| Source | What I used it for |
|---|---|
| [Kernel: IP sysctl](https://docs.kernel.org/networking/ip-sysctl.html) | `tcp_congestion_control`, buffers, ECN, MTU probing, IPv6 off |
| [BBR](https://github.com/google/bbr) | What BBR does differently |
| [tc-cake](https://man7.org/linux/man-pages/man8/tc-cake.8.html) | Every CAKE option I use |
| [Bufferbloat: CAKE](https://www.bufferbloat.net/projects/codel/wiki/Cake/) | Why it exists, and why the real fix is on the router |
| [Arch Wiki: Advanced traffic control](https://wiki.archlinux.org/title/Advanced_traffic_control) | `tc` and qdiscs in plain words |
| [NetworkManager dispatcher](https://networkmanager.dev/docs/api/latest/NetworkManager-dispatcher.html) | Running CAKE each time a connection comes up |
| [nmcli settings](https://networkmanager.dev/docs/api/latest/nm-settings-nmcli.html) | `wifi.powersave` and its values |

The dispatcher script puts CAKE on a connection when it comes up. Unlimited, so it keeps flows fair and never caps your speed:

```bash
/usr/sbin/tc qdisc replace dev "$IFACE" root cake unlimited diffserv3 \
    triple-isolate rtt ${RTT}ms noatm overhead $OVERHEAD split-gso
```

### Try it yourself

```bash
sysctl net.ipv4.tcp_congestion_control     # bbr or cubic
tc qdisc show                              # cake, fq or fq_codel on each card
nmcli -f GENERAL.DEVICE,GENERAL.TYPE device show   # your network cards
iw dev wlp3s0 get power_save               # Wi-Fi power saving on or off
```

Swap your Wi-Fi card's name in for `wlp3s0`, `ip link` lists them.

## 🐧 Kernels

| Source | What I used it for |
|---|---|
| [grubby](https://github.com/rhboot/grubby) | Showing and setting which kernel boots by default, and adding `preempt=full` and `transparent_hugepage=always` to every kernel |
| [Kernel parameters](https://docs.kernel.org/admin-guide/kernel-parameters.html) | `preempt=`, `transparent_hugepage=` and `rd.driver.blacklist=` |
| [dracut.cmdline](https://man7.org/linux/man-pages/man7/dracut.cmdline.7.html) | Keeping nouveau and nova out of the ramdisk |
| [CachyOS kernels](https://github.com/CachyOS/linux-cachyos) | Keeping a CachyOS kernel as the default when Fedora installs a new one. They're built with full preemption already |

```bash
grubby --set-default "/boot/vmlinuz-$k"
grubby --update-kernel=ALL --remove-args="preempt" --args="preempt=full"
```

### Try it yourself

```bash
uname -r                          # the kernel you're running
ls /lib/modules                   # every kernel you have
sudo grubby --default-kernel      # the one that boots next time
rpm -qa 'kernel*core*'            # which package each one came from
```

**Is my kernel built for a snappy desktop?** `CONFIG_PREEMPT=y` is full preemption built in, the CachyOS way. Fedora's own kernel has `PREEMPT_DYNAMIC` and you pick with `preempt=` on the command line:

```bash
grep -E '^CONFIG_PREEMPT(_DYNAMIC)?=|^CONFIG_HZ=' /lib/modules/$(uname -r)/config
tr ' ' '\n' < /proc/cmdline | grep -E 'preempt|transparent|blacklist'
```

## ⚡ CPU scheduler: sched_ext

Linux 6.12 and up can swap the CPU scheduler for a BPF one while the PC runs, and back again if it misbehaves. The Kernels tab's CPU scheduler card is my scx-picker.sh with dropdowns: pick a scheduler and a mode, Apply, and **Keep it after a reboot** writes scx_loader's config. Solus runs **flash** in auto out of the box.

| Source | What I used it for |
|---|---|
| [Kernel: sched_ext](https://docs.kernel.org/scheduler/sched-ext.html) | What sched_ext is, and why a broken scheduler just falls back to the normal one |
| [sched-ext/scx](https://github.com/sched-ext/scx) | The schedulers themselves, what each is for, and scx_loader with its `scxctl` |
| [sched-ext/scx-loader](https://github.com/sched-ext/scx-loader) | scx_loader and `scxctl`, what the card talks to |
| [CachyOS addons COPR](https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos-addons/) | Fedora hasn't packaged the schedulers, `scx-scheds` and `scx-tools` come from here |
| [Steam Deck and lavd](https://github.com/sched-ext/scx/tree/main/scheds/rust/scx_lavd) | Why lavd is the one for games and laptops |

What Apply runs, as root through my helper:

```bash
scxctl switch --sched lavd --mode gaming || scxctl start --sched lavd --mode gaming
```

### Try it yourself

```bash
scxctl get                       # what's running now
scxctl list                      # what you could pick
cat /sys/kernel/sched_ext/state  # enabled means a sched_ext scheduler is in charge
cat /etc/scx_loader/config.toml  # what starts at boot, if you kept one
```

## 📦 Boxes: distrobox and LumineCapture

My lt-boxes and solus-distrobox.sh as a tab. On Fedora LumineCapture sits under Boxes in **🧰 Apps**. On Solus it moved to Extras along with MEGAsync, see the [Solus page](SOURCES-SOLUS.md#-boxes-and-extras-on-solus). Distrobox runs another distro in a podman container that shares your home folder, your screen and your sound, so a Debian app feels like it's on your PC. Rootless podman needs your own uid range in `/etc/subuid` and `/etc/subgid`, that's the one bit that asks for a password.

| Source | What I used it for |
|---|---|
| [Distrobox](https://distrobox.it/) and [its GitHub](https://github.com/89luca89/distrobox) | create, enter, stop, rm, and `--pre-init-hooks` |
| [Podman: rootless](https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md) | Why boxes need a subuid and subgid range |
| [newuidmap](https://man7.org/linux/man-pages/man1/newuidmap.1.html) and [capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) | Fedora gives newuidmap a file capability, not setuid. Both at once and the kernel logs "has both setuid-root and effective capabilities" and podman dies with "open of uid_map failed". Set up distrobox takes the setuid off, only when podman really fails |
| [Toolbx images](https://github.com/toolbx-images/images) | The Debian and Arch images made for this, Fedora's comes from quay.io/fedora |
| [podman system reset](https://docs.podman.io/en/latest/markdown/podman-system-reset.1.html) | Start boxes fresh. Files from an old id range can't be deleted by you any more, so the folder goes as root after |
| [resolved.conf](https://www.freedesktop.org/software/systemd/man/latest/resolved.conf.html) | `DNS=` and `Domains=~.`, extra DNS next to the router. resolved asks both and takes the first answer, home network names still work |
| [locale-gen](https://manpages.debian.org/bookworm/locales/locale-gen.8.en.html) | Solus writes `en_AU.utf8`, Debian and Arch want `en_AU.UTF-8`, so the box builds yours first |
| [LumineCapture](https://github.com/Netflate/LumineCapture) | Screenshots with OCR. Only a .deb, unpacked into /usr/local |
| [KWin: restricted interfaces](https://invent.kde.org/plasma/kwin) | KWin only lets an app take screenshots when its real path matches a .desktop file that asks for `org.kde.KWin.ScreenShot2`, so LumineCapture can't live in a box |

### Try it yourself

```bash
distrobox list                          # your boxes
grep "^$USER:" /etc/subuid /etc/subgid  # the uid range podman needs
podman unshare cat /proc/self/uid_map  # podman can start boxes if this prints your range
ls -l /usr/bin/newuidmap; getcap /usr/bin/newuidmap   # an s in -rwsr AND a cap_setuid is the broken mix on Fedora
distrobox enter fedora -- cat /etc/os-release | head -2   # run one thing in a box
type box-update                         # what box-update does, once Boxes set it up
```

## ❄️ Nix

The Nix package manager in single user mode, everything under `/nix` and `~/.nix-profile`, next to dnf or eopkg and never in their way. The Nix tab runs my install-nix-package-manager.sh in a terminal so you can watch it.

Install Nix finishes in its own terminal, then that one closes and a new one opens straight in `nix-shell ~/default.nix`, started with `setsid -f` so the old window closing doesn't take it along. A fresh `bash -i` in the old window didn't give a working nix on either distro.

Try without installing fetches first, then opens nix-shell's own shell. A fresh bash after it read `.bashrc` again, and Solus's resets PATH, so the program was gone. nix-shell puts it back after `.bashrc`. Look it up opens `--new-window` in Vivaldi, Chrome, Firefox and friends, a tab behind LinuxTweaks looked like nothing happened.

| Source | What I used it for |
|---|---|
| [Nix: download](https://nixos.org/download/) | The `--no-daemon` single user install |
| [nix-shell](https://nix.dev/manual/nix/latest/command-ref/nix-shell) | `-p` to try one program, or your whole `~/default.nix`, without installing |
| [nix-env](https://nix.dev/manual/nix/latest/command-ref/nix-env) | `-iA` to keep one, `-q` for what you kept, `-e` to remove, `-u` to update them |
| [xdg-settings](https://portland.freedesktop.org/doc/xdg-settings.html) | Which browser is yours, so Look it up opens a new window of it |
| [nix-collect-garbage](https://nix.dev/manual/nix/latest/command-ref/nix-collect-garbage) | Free up space |
| [NixOS packages search](https://search.nixos.org/packages) | Finding the right name |
| [setsid](https://man7.org/linux/man-pages/man1/setsid.1.html) | The new nix-shell terminal in its own session, so it outlives the install one |
| [glibcLocales](https://wiki.nixos.org/wiki/Locales) | Nix programs can't read the system's locales, `LOCALE_ARCHIVE` points them at Nix's own |

### Try it yourself

```bash
nix --version
nix-env -q                        # what you kept for good
nix-env -qaP btop                 # find a package's name
nix-shell -p cowsay --run "cowsay hi"   # try one, gone again after
```

## 🧩 Extras: WPS Office

wpscloudsvr in the WPS Office flatpak keeps segfaulting (a null pointer in `libqingbangong.so`), and Health counted it every time. The Extras switch bind mounts `/dev/null` over it so it never starts. Flatpak updates move WPS to a new folder, so a `.path` unit watches for that and masks the new one, and a boot unit does it again after a restart. From my mask-wps-cloudsvr.sh.

| Source | What I used it for |
|---|---|
| [mount: bind mounts](https://man7.org/linux/man-pages/man8/mount.8.html) | `/dev/null` over one file, gone again with umount or a reboot |
| [systemd.path](https://www.freedesktop.org/software/systemd/man/latest/systemd.path.html) | `PathChanged=` on the WPS flatpak folder, to catch updates |
| [flatpak info](https://docs.flatpak.org/en/latest/flatpak-command-reference.html#flatpak-info) | `--show-location`, where this WPS lives right now |

### Try it yourself

```bash
flatpak info --show-location com.wps.Office
findmnt | grep wpscloudsvr                               # masked if it's listed
systemctl status linuxtweaks-wps-mask.path --no-pager    # the update watcher
```

## 🐚 Bash

| Source | What I used it for |
|---|---|
| [Bash manual](https://www.gnu.org/software/bash/manual/bash.html) | Everything, more than once |
| [flock](https://man7.org/linux/man-pages/man1/flock.1.html) | One check at a time, so the tray and the timer don't run over each other |
| [ShellCheck](https://www.shellcheck.net/) | Catching my mistakes before they ship |

```bash
exec {check_lock}>"$STATE_DIR/.check.lock"
flock -n "$check_lock" || exit 0
```

### Try it yourself

Only one copy of a script at a time:

```bash
exec {lock}>/tmp/my-script.lock
flock -n "$lock" || { echo "already running"; exit 0; }
echo "working…"; sleep 10
```

Check what you're handed before using it, like every one of my root helpers does:

```bash
size="$1"
[[ $size =~ ^[0-9]+$ ]] && ((size >= 10 && size <= 150)) || { echo "not a size: $size"; exit 2; }
echo "ok, $size"
```

Read `key=value` lines into variables:

```bash
while IFS='=' read -r key value; do
    echo "$key is $value"
done < <(printf 'swappiness=180\nsize=50\n')
```

Count how often each line shows up, the trick behind the Health card's ×N:

```bash
printf 'apple\npear\napple\napple\n' | sort | uniq -c | sort -rn
```

## 🎨 The look

| Source | What I used it for |
|---|---|
| [Nord](https://www.nordtheme.com/docs/colors-and-palettes) | Every colour in the window |
| [Shields.io](https://shields.io/) | The badges at the top of the README. Since 8.2.36 the Fedora and Solus tags next to the name in the window use the same two blues |
| [Qt Style Sheets: border-radius](https://doc.qt.io/qt-5/stylesheet-reference.html#border-radius) | Rounding a plain QLabel into that tag, no picture needed |

## 🔗 My own repo, releases and Tailscale

Each release is built and signed on my Fedora laptop, uploaded to my repo server, and the signed RPM goes into this GitHub repo too, so About can find it. When I release from the desktop on Solus, which has no rpmbuild, my release window tars the project over to the laptop and builds it there over `ssh -t`. gpg asks with `--pinentry-mode loopback`, a plain passphrase line my window can catch, not its full screen box.

| Source | What I used it for |
|---|---|
| [createrepo_c](https://github.com/rpm-software-management/createrepo_c) | Turning a folder of RPMs into a repo dnf can read |
| [RPM man pages](https://rpm-software-management.github.io/rpm/man/) | `rpmsign`, signing every package with my key |
| [rpmbuild](https://rpm-software-management.github.io/rpm/man/rpmbuild.1) | Building it, with a throwaway `_topdir` for test builds |
| [gpg: pinentry-mode](https://www.gnupg.org/documentation/manuals/gnupg/GPG-Esoteric-Options.html) | `loopback`, signing over ssh with the passphrase asked in my own window |
| [Tailscale: sharing](https://tailscale.com/kb/1084/sharing) | Sharing only my repo server with friends, nothing else |

### Try it yourself

A test build that doesn't touch your real `~/rpmbuild`:

```bash
rpmbuild --define "_topdir /tmp/test-rpm" -bb my.spec
```

Is the repo serving what I think it is? Fresh metadata, the way a client sees it:

```bash
dnf -q --refresh --repo linuxtweaks repoquery --qf '%{version}-%{release}\n' linuxtweaks-updater
```

---

<div align="center">

[⬅ Back to the README](README.md) · [📚 All sources](SOURCES.md) · [🌀 Solus sources](SOURCES-SOLUS.md) · [⬆ Back to top](#top)

</div>
