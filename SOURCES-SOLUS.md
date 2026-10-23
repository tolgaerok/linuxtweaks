<a id="top"></a>

<div align="center">

# 🌀 Sources and references: Solus

**What I read to bring LinuxTweaks to Solus, and the Solus rules it sticks to.**

[⬅ Back to the README](README.md) · [📚 All sources](SOURCES.md) · [🎩 Fedora sources](SOURCES-FEDORA.md)

</div>

---

The Solus build is the same app with eopkg in place of dnf, packaged the Solus way with `package.yml` and solbuild. The tray, the window, systemd, polkit, the desktop standards and the Health report are shared with Fedora, so they're written up once on the [Fedora page](SOURCES-FEDORA.md). This page is what's different on Solus.

The **Try it yourself** boxes are safe to paste. They only read unless they say otherwise.

## Contents

- [The Solus rules I follow](#-the-solus-rules-i-follow)
- [Packaging: package.yml and solbuild](#-packaging-packageyml-and-solbuild)
- [eopkg: updates and history](#%EF%B8%8F-eopkg-updates-and-history)
- [Offline on Solus](#-offline-on-solus)
- [NVIDIA on Solus](#-nvidia-on-solus)
- [Kernels and boot](#-kernels-and-boot)
- [Health: AppArmor and the report](#%EF%B8%8F-health-apparmor-and-the-report)
- [Memory: no freeze when RAM runs out](#-memory-no-freeze-when-ram-runs-out)
- [Boxes and Extras on Solus](#-boxes-and-extras-on-solus)
- [Signed eopkgs on GitHub](#-signed-eopkgs-on-github)
- [Shared with Fedora](#-shared-with-fedora)

---

## 📏 The Solus rules I follow

- **Packages follow the [Solus packaging practices](https://help.getsol.us/docs/packaging/packaging-practices).** `release` goes up by 1 for every new version or fix and never resets, the generated `pspec_x86_64.xml` goes in with `package.yml`, SPDX licence names, `%install_license` for the licence file, and every build tested in a clean solbuild chroot.
- **Drivers come from the Solus repo**, the way the [Solus NVIDIA guide](https://help.getsol.us/docs/user/hardware/nvidia-gpu-drivers) says. No Fedora repos, no Negativo17, no RPM Fusion, no NVIDIA `.run` installer. That's why there's no GPU tab on Solus.
- **Apps from outside go through Flatpak.** Solus's own [third-party repo](https://help.getsol.us/docs/user/software/third-party/) is being phased out and Solus says Flatpak is preferred.
- **Stateless where Solus is.** The app lives under `/usr`, autostart in `/usr/share/xdg/autostart`, and the background check is switched on with a systemd preset, not by writing into `/etc`.

## 📦 Packaging: package.yml and solbuild

| Source | What I used it for |
|---|---|
| [Solus packaging docs](https://help.getsol.us/docs/packaging/) | Where it all starts |
| [package.yml](https://help.getsol.us/docs/packaging/package.yml) | Every key: `source`, `rundeps`, `install`, `check`, and the `%make_install` and `%install_file` macros |
| [Creating a new package](https://help.getsol.us/docs/packaging/creating-a-new-package) | My first `package.yml` |
| [Packaging practices](https://help.getsol.us/docs/packaging/packaging-practices) | Release bumps, pspec, licences, `rundeps` |
| [monitoring.yaml](https://help.getsol.us/docs/packaging/monitoring.yaml) | Release monitoring and CVE tracking for a package |
| [Testing a package](https://help.getsol.us/docs/packaging/testing-a-package) | Installing your build before anyone else does |
| [Local repository](https://help.getsol.us/docs/packaging/advanced-config/local-repository) | Building against your own packages |
| [solbuild](https://github.com/getsolus/solbuild) | The clean chroot every package is built in |
| [getsolus/packages](https://github.com/getsolus/packages) | Hundreds of real `package.yml` files to learn from |

The install part of my `package.yml`. One Makefile for both distros, told it's Solus:

```yaml
install    : |
    %make_install DISTRO=solus LIBDIR=%libdir%
    %install_file -t $installdir/usr/lib/systemd/user-preset/ $pkgfiles/90-linuxtweaks-updater.preset
    %install_license LICENSE
```

### Try it yourself

**An eopkg is just a zip.** Look inside one without installing it:

```bash
unzip -l linuxtweaks-updater-8.2.59-44-1-x86_64.eopkg
unzip -p linuxtweaks-updater-8.2.59-44-1-x86_64.eopkg metadata.xml | less
```

`metadata.xml` is the package info, `files.xml` lists every file, `install.tar.xz` is the files themselves.

**Learn from a real package.** Any `package.yml` in the Solus repo, `nano` here:

```bash
curl -s https://raw.githubusercontent.com/getsolus/packages/main/packages/n/nano/package.yml
```

## 🛠️ eopkg: updates and history

| Source | What I used it for |
|---|---|
| [Package management basics](https://help.getsol.us/docs/user/package-management/basics) | `eopkg up`, `lu`, `it`, `rm`, `history` |
| [Repository management](https://help.getsol.us/docs/user/package-management/repo-management) | The Solus repo and its index |
| [eopkg](https://github.com/getsolus/eopkg) | How it works inside, and `/var/lib/eopkg/package`, its install database |
| [systemd.unit: StartLimitBurst=](https://www.freedesktop.org/software/systemd/man/latest/systemd.unit.html#StartLimitIntervalSec=interval) | Why the index refresh lost its `Restart=` and start limit. Start limits count the starts you ask for too, so the 4th Check for updates in 5 minutes on flaky wifi got refused |

The tray reads the repo index and the install database as you, no root and no eopkg on every click. Since 8.2.33 the update window checks that database after an install, and shows anything that didn't get its new version instead of saying it all went in.

### Try it yourself

```bash
eopkg lu                         # what's waiting
eopkg history -l 3               # the last 3 things eopkg did
eopkg list-pending               # anything installed but not set up yet
eopkg info linuxtweaks-updater   # version and release you have
```

**Count your packages** and see how eopkg remembers each one, a folder named `name-version-release`:

```bash
ls /var/lib/eopkg/package | wc -l
ls /var/lib/eopkg/package | grep -E '^(bash|linux-current)-'
```

## 📶 Offline on Solus

Same idea as Fedora, done eopkg's way. The Solus journal showed it plain: `eopkg update-repo` with no internet exits 1 with `Failed to resolve 'cdn.getsol.us'`, and the old check said "using the one on disk" and worked out new lists from the old index. Now:

- **NetworkManager not at State 70?** The check doesn't even start, says no internet, and the old lists stay
- **The refresh fails with a getsol.us network error while NM says online?** One more go after 5 seconds, then "the internet dropped out" and it tries again in a minute
- **New lists only when everything answered.** They're written to `.check.new` first and only moved in when eopkg and Flatpak both gave a real answer
- **polkit says no to the refresh** (not at the desktop, not an admin)? It still reads the index on disk, failing every check for that helps nobody
- **Back online** checks straight away, the tray hears NetworkManager go back to 70. After a good check too, unless one finished under 2 minutes ago

Solus has NetworkManager's own internet check on out of the box, it asks getsol.us every 5 minutes. So wifi still up but the internet gone drops State to 60 too, and coming back sets off the check.

| Source | What I used it for |
|---|---|
| [NetworkManager D-Bus types: NMState](https://networkmanager.dev/docs/api/latest/nm-dbus-types.html) | 70 online, 60 site only, 50 local only |
| [NetworkManager.conf: connectivity](https://networkmanager.dev/docs/api/latest/NetworkManager.conf.html) | `uri`, `response` and `interval`, what Solus sets in its own conf file |
| [Flatpak command reference](https://docs.flatpak.org/en/latest/flatpak-command-reference.html) | `remote-ls --updates`, the honest answer offline. `flatpak update` said "Nothing to update" with no internet |

### Try it yourself

```bash
cat /usr/lib/NetworkManager/conf.d/20-connectivity-solus.conf   # Solus's own internet check
nmcli networking connectivity                                    # full, limited, portal or none
busctl get-property org.freedesktop.NetworkManager /org/freedesktop/NetworkManager org.freedesktop.NetworkManager State
```

## 🎮 NVIDIA on Solus

Solus packages the driver itself, matched to your kernel. You install it from GNOME Software or KDE Discover. The [Solus NVIDIA guide](https://help.getsol.us/docs/user/hardware/nvidia-gpu-drivers) says which one:

- **Open kernel modules** if your card is on NVIDIA's list for them (Turing, GTX 16xx and RTX, and newer). My G4's GTX 1650 runs `nvidia-open-current`.
- **580 proprietary** for Maxwell, Pascal and Volta, the last branch with updates for them.
- **470 legacy** only for Kepler, LTS kernel only, and on its way out.
- The `current` or `LTS` package has to match the kernel you run.

The Fedora build's "Same as Solus" settings come straight from Solus's own `/usr/lib/modprobe.d/nvidia.conf`, and Solus explains them in it:

- `NVreg_UsePageAttributeTable=1`: the better memory management method (PAT)
- `NVreg_InitializeSystemMemoryAllocations=0`: memory isn't cleared before the GPU gets it. Solus's own note: potentially faster, *"at the cost of increased security risks"*
- `NVreg_DynamicPowerManagement=0x02` and `NVreg_EnableS0ixPowerManagement=1`: power saving for Turing and newer laptops
- `nvidia-blacklist.conf` blocks nouveau and the new nova driver

| Source | What I used it for |
|---|---|
| [Solus: NVIDIA GPU drivers](https://help.getsol.us/docs/user/hardware/nvidia-gpu-drivers) | Which driver for which card, current vs LTS |
| [NVIDIA open GPU kernel modules](https://github.com/NVIDIA/open-gpu-kernel-modules) | Which cards the open modules run on |
| [NVIDIA: Unix graphics deprecation schedule](https://forums.developer.nvidia.com/t/unix-graphics-feature-deprecation-schedule/60588) | 580 as the last branch for Maxwell, Pascal and Volta |
| [NVIDIA driver README (580)](https://download.nvidia.com/XFree86/Linux-x86_64/580.95.05/README/index.html) | What each `NVreg_` option does |
| [Kernel: nova](https://docs.kernel.org/gpu/nova/index.html) | The in-kernel driver Solus blocks |

### Try it yourself

**Which NVIDIA packages do I have?**

```bash
eopkg li | grep -i nvidia
```

**Solus's own driver settings, with its comments:**

```bash
cat /usr/lib/modprobe.d/nvidia.conf /usr/lib/modprobe.d/nvidia-blacklist.conf
```

**Open modules or proprietary?** `Dual MIT/GPL` is open, `NVIDIA` is proprietary. And is the card new enough for open (7.5 and up)?

```bash
modinfo -F license nvidia
nvidia-smi --query-gpu=name,compute_cap,driver_version --format=csv,noheader
```

**Which driver is the kernel actually using?**

```bash
lspci -k | grep -A3 -E 'VGA|3D'
```

## 🐧 Kernels and boot

Solus boots with clr-boot-manager, not GRUB and grubby, and ships two kernels: `current` and `lts`. The Kernels tab uses it to pick which one boots.

| Source | What I used it for |
|---|---|
| [Solus: boot management](https://help.getsol.us/docs/user/quick-start/boot-management) | clr-boot-manager the Solus way |
| [Solus: add new kernels](https://help.getsol.us/docs/user/quick-start/kernel-management/add-new-kernels) and [remove old ones](https://help.getsol.us/docs/user/quick-start/kernel-management/remove-old-kernels) | current vs LTS |
| [clr-boot-manager](https://github.com/clearlinux/clr-boot-manager) | `list-kernels`, `set-kernel`, `set-timeout` |
| [Kernel: transparent hugepages](https://docs.kernel.org/admin-guide/mm/transhuge.html) | Why Solus's `always` feels snappier |

### Try it yourself

```bash
uname -r                                   # the kernel you're running
ls /usr/lib/kernel                         # what's installed
sudo clr-boot-manager list-kernels         # what can boot, * marks the default
grep -E '^CONFIG_PREEMPT=|^CONFIG_HZ=' /usr/lib/kernel/config-$(uname -r)   # built for a snappy desktop?
cat /sys/kernel/mm/transparent_hugepage/enabled
```

## 🛡️ Health: AppArmor and the report

Solus uses AppArmor where Fedora uses SELinux, and eopkg's pending list where Fedora runs `dnf check`. The rest of Health and the 📋 Report… button are the same file on both, with the same known noise list. That's written up on the [Fedora page](SOURCES-FEDORA.md#-health-and-the-report), with more to try.

After 8.2.59 Solus gets the **Background extras** card too, with one row: KMail. Solus Plasma comes with KMail, and its 6 mail agents start with Akonadi at every login even if you never set up mail, the same thing that froze my Fedora G4 at login. `eopkg remove` takes everything that depends on KMail with it, which on Solus is just Kontact. eopkg's dry run wants root, so the card works out that list itself from eopkg's own installed list in `/var/lib/eopkg/package`, no password. The helper then runs `eopkg remove --dry-run` as root before it removes anything, and stops if KOrganizer or the calendar side would go too.

| Source | What I used it for |
|---|---|
| [AppArmor](https://apparmor.net/) | The AppArmor card, and what a `DENIED` line means |
| [systemd-coredump](https://www.freedesktop.org/software/systemd/man/latest/systemd-coredump.html) | Solus has no coredumpctl, so the Crashes card always said none. Since 8.2.35 it reads the "dumped core" lines in the journal instead. Uninstalling doesn't clear a crash, so the card checks `COREDUMP_EXE` and leaves out programs that are gone, same code as Fedora. Clear and the crash log are the same on both too |
| [ddcutil: i2c permissions](https://www.ddcutil.com/i2c_permissions/) | Solus gives the monitor's i2c devices to whoever's logged in (uaccess), there's no `i2c` group to join |
| `man eopkg` | `remove` takes reverse dependencies with it, `--dry-run` only shows what would happen |
| [eopkg: remove.py](https://github.com/getsolus/eopkg/blob/main/pisi/operations/remove.py) | What the dry run prints, the package list on the line after "to satisfy dependencies:" |

### Try it yourself

```bash
cat /sys/module/apparmor/parameters/enabled                    # Y means it's on
journalctl -b -k -o cat | grep -c 'apparmor="DENIED"'           # how often it blocked something this boot
journalctl --since -7d -t systemd-coredump -o cat | grep 'dumped core'   # crashes, no coredumpctl needed
getfacl -p /dev/i2c-1 | grep user:                              # you, not a group, can talk to the monitor
ddcutil getvcp 10                                               # your monitor's brightness, 0 to 100
```

## 🧠 Memory: no freeze when RAM runs out

The Memory tab's **No freeze when RAM runs out** works on Solus too. Its kernel has the multi-gen LRU fully on (`0x0007`), and systemd-tmpfiles sets `min_ttl_ms` again every boot. The only change from Fedora: no `restorecon`, Solus has no SELinux. The sources are on the [Fedora page](SOURCES-FEDORA.md#-memory-zram-and-sysctl).

```bash
cat /sys/kernel/mm/lru_gen/enabled       # 0x0007 on Solus out of the box
cat /sys/kernel/mm/lru_gen/min_ttl_ms    # 1000 with the switch on
```

## 📦 Boxes and Extras on Solus

Boxes is just distrobox on Solus. The apps that live outside a box moved to **🧩 Extras**: WPS Office's cloud helper fix, **LumineCapture** installed straight on the system so KWin lets it take screenshots, and **MEGAsync** in its own Debian 13 box with MEGA's own repo. That last one keeps Solus clean, and **Update all** in Boxes keeps MEGAsync current with everything else. Removing it deletes the box, your MEGA folder and login stay.

| Source | What I used it for |
|---|---|
| [MEGA desktop app](https://mega.io/desktop) | MEGA's own Debian package and repo, the one that goes in the box |
| [Distrobox](https://distrobox.it/) | `distrobox-export --app` puts MEGAsync in your app menu like it's installed |
| [Solus: third-party software](https://help.getsol.us/docs/user/software/third-party/) | Why apps from outside go in a box or a flatpak, not on Solus itself |

### Try it yourself

```bash
distrobox list                                          # MEGAsync's box shows here once it's in
ls ~/.local/share/applications | grep -i mega           # the menu entry distrobox made
```

## 🔏 Signed eopkgs on GitHub

LinuxTweaks for Solus isn't in the Solus repo, so it updates itself from my GitHub folder. eopkgs aren't signed like RPMs, so each one has a `.asc` signature next to it, made with the same key as my RPMs, and About only installs one that checks out against the key the app ships.

| Source | What I used it for |
|---|---|
| [gpgv](https://www.gnupg.org/documentation/manuals/gnupg/gpgv.html) | Checking a signature against one key only, nothing from your own keyring |
| [GitHub REST API: contents](https://docs.github.com/en/rest/repos/contents) | Finding the newest eopkg and its `.asc` |

### Try it yourself

Check an eopkg the way the app does, against my key only:

```bash
gpgv --keyring /usr/share/linuxtweaks-updater/linuxtweaks-key.gpg \
     linuxtweaks-updater-8.2.59-44-1-x86_64.eopkg.asc linuxtweaks-updater-8.2.59-44-1-x86_64.eopkg
```

`Good signature from "Tolga Erok (LinuxTweaks RPM Signing)"` means it's mine and nobody changed it.

## 🔗 Shared with Fedora

These are written up once, on the [Fedora page](SOURCES-FEDORA.md):

- [systemd: timers, services and sleep](SOURCES-FEDORA.md#%EF%B8%8F-systemd-timers-services-and-sleep)
- [Root without sudo rules: polkit](SOURCES-FEDORA.md#-root-without-sudo-rules-polkit)
- [Desktop standards](SOURCES-FEDORA.md#%EF%B8%8F-desktop-standards)
- [The tray and window: Python and Qt](SOURCES-FEDORA.md#-the-tray-and-window-python-and-qt)
- [Health and the report](SOURCES-FEDORA.md#-health-and-the-report)
- [Drives](SOURCES-FEDORA.md#-drives-schedulers-and-read-ahead), [Memory](SOURCES-FEDORA.md#-memory-zram-and-sysctl) and [Network](SOURCES-FEDORA.md#-network-bbr-cake-and-networkmanager)
- [Bash](SOURCES-FEDORA.md#-bash) and [the look](SOURCES-FEDORA.md#-the-look)
- [CPU scheduler: sched_ext](SOURCES-FEDORA.md#-cpu-scheduler-sched_ext), flash in auto is what Solus starts
- [Boxes: distrobox and LumineCapture](SOURCES-FEDORA.md#-boxes-distrobox-and-luminecapture), where the `.utf8` language fix comes from
- [Nix](SOURCES-FEDORA.md#%EF%B8%8F-nix) and [Extras: WPS Office](SOURCES-FEDORA.md#-extras-wps-office)
- [Restarting services after an update](SOURCES-FEDORA.md#-restarting-services-after-an-update), same window and same careful list
- [A new LinuxTweaks within seconds](SOURCES-FEDORA.md#-a-new-linuxtweaks-within-seconds), on Solus it reads the `Solus` badge on raw GitHub
- [Usage sharing, only if you say yes](SOURCES-FEDORA.md#-usage-sharing-only-if-you-say-yes), same popup and same Worker, the About this PC and What LinuxTweaks does here tick boxes too

## 🔧 Firmware, wake from sleep, clock and pinned Flatpaks

Four cards that came out of my own old scripts, same on Fedora and Solus. Health asks fwupd for firmware updates with `fwupdmgr get-updates --json`, as you and without going online, and **Update in a terminal** runs `fwupdmgr update`. **Wake from sleep** lists every USB thing whose `power/wakeup` is on, and its button writes `/etc/udev/rules.d/90-linuxtweaks-wake.rules` so only keyboards and mice (and the hubs they hang off) can wake the PC. What was on before gets kept so it can all go back. **Clock** reads `timedatectl show` and **Turn it on** is `timedatectl set-ntp true`, timedated asks for the password itself. On the Updates tab, the 🧹 Not needed any more card unpins `.Platform` runtimes that no app runs on with `flatpak pin --remove`, then `flatpak uninstall --unused` takes them.

| Source | What I took from it |
|---|---|
| [fwupdmgr(1)](https://man.archlinux.org/man/fwupdmgr.1) | `get-updates` and `update`, and use `--json` in scripts because the normal output can change |
| [sysfs-devices-power](https://kernel.org/doc/Documentation/ABI/testing/sysfs-devices-power) | `power/wakeup` takes `enabled` or `disabled`, and devices that can't wake the PC don't have it |
| [udev(7)](https://www.freedesktop.org/software/systemd/man/latest/udev.html) | `RUN+=`, `$$` for a `$` and `%%` for a `%` in a rule, `%p` is the device path |
| [timedatectl(1)](https://www.freedesktop.org/software/systemd/man/latest/timedatectl.html) | `show` gives CanNTP, NTP and NTPSynchronized, `set-ntp` switches sync on |
| [flatpak-pin(1)](https://www.mankier.com/1/flatpak-pin) | runtimes you install by hand get pinned and pinned ones never go by themselves, `pin --remove` |
| [flatpak-uninstall(1)](https://www.mankier.com/1/flatpak-uninstall) | `--unused` |

## ⚡ Quick reboot

Plasma hangs on the way out sometimes and its own unit gives it 40s before systemd kills it, so the reboot sat on "a stop job is running for user 1000". The **Quick reboot, don't wait on Plasma** switch in Settings writes `~/.config/systemd/user/plasma-plasmashell.service.d/10-stop-timeout.conf` with `KillSignal=SIGKILL`, so plasmashell gets killed straight off. Off takes the file out. Only your user, no password. Same on Fedora, Solus and AerynOS.

| Source | What I took from it |
|---|---|
| [plasma-plasmashell.service.in](https://invent.kde.org/plasma/plasma-workspace/-/raw/master/shell/plasma-plasmashell.service.in) | Plasma's own unit sets `TimeoutSec=40sec`, that's the 40s |
| [systemd.unit(5)](https://www.freedesktop.org/software/systemd/man/latest/systemd.unit.html) | `~/.config/systemd/user` drop-ins go on top of the unit in `/usr/lib`, updates don't touch them |
| [systemd.kill(5)](https://www.freedesktop.org/software/systemd/man/latest/systemd.kill.html) | `KillSignal=` is the signal sent when the unit stops |
| [systemd.service(5)](https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html) | `TimeoutStopSec=`, and `TimeoutSec=` sets both start and stop |
| [Arch forum, 40s on reboot](https://bbs.archlinux.org/viewtopic.php?id=314567) | plasmashell stuck in the Wayland clipboard code till it got killed |

---

<div align="center">

[⬅ Back to the README](README.md) · [📚 All sources](SOURCES.md) · [🎩 Fedora sources](SOURCES-FEDORA.md) · [⬆ Back to top](#top)

</div>
