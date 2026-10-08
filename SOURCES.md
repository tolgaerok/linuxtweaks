<a id="top"></a>

<div align="center">

# 📚 Sources and references

**Everything I read, borrowed ideas from and kept open in a tab while building LinuxTweaks.**

[⬅ Back to the README](README.md)

</div>

---

LinuxTweaks is built from a lot of reading. Man pages, the Fedora packaging guidelines, the kernel docs, the Arch Wiki (still the best Linux manual there is, even on Fedora) and plenty of trial and error on my own PCs. This page lists the lot, grouped by what it helped with, with a small piece of the app next to it so you can see where it ended up.

If something here helped you too, the people who wrote it deserve the thanks.

## Contents

- [Packaging the RPM](#-packaging-the-rpm)
- [DNF and Flatpak](#-dnf-and-flatpak)
- [systemd: timers, services and sleep](#%EF%B8%8F-systemd-timers-services-and-sleep)
- [Root without sudo rules: polkit](#-root-without-sudo-rules-polkit)
- [Desktop standards](#%EF%B8%8F-desktop-standards)
- [The tray and window: Python and Qt](#-the-tray-and-window-python-and-qt)
- [Drives: schedulers and read-ahead](#-drives-schedulers-and-read-ahead)
- [Memory: zram and sysctl](#-memory-zram-and-sysctl)
- [Network: BBR, CAKE and NetworkManager](#-network-bbr-cake-and-networkmanager)
- [Kernels](#-kernels)
- [Bash](#-bash)
- [The look](#-the-look)
- [My own repo and Tailscale](#-my-own-repo-and-tailscale)

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
rpm -qip linuxtweaks-updater-8.2.4-1.fc44.noarch.rpm      # name, version, summary
rpm -qlp linuxtweaks-updater-8.2.4-1.fc44.noarch.rpm      # every file it puts on your PC
rpm -qp --scripts linuxtweaks-updater-8.2.4-1.fc44.noarch.rpm   # what it runs when it installs
```

Is it really signed by me? A throwaway keyring, so nothing on your system changes:

```bash
mkdir -p /tmp/keys
rpmkeys --dbpath /tmp/keys --import /usr/share/linuxtweaks-updater/RPM-GPG-KEY-linuxtweaks
rpmkeys --dbpath /tmp/keys --checksig linuxtweaks-updater-8.2.4-1.fc44.noarch.rpm
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

## ⚙️ systemd: timers, services and sleep

| Source | What I used it for |
|---|---|
| [systemd.timer](https://www.freedesktop.org/software/systemd/man/latest/systemd.timer.html) | `OnBootSec`, `OnUnitActiveSec`, `Persistent` and `RandomizedDelaySec` for the check timer |
| [systemd.service](https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html) | Oneshot services for the check and the weekly maintenance |
| [systemd-run](https://www.freedesktop.org/software/systemd/man/latest/systemd-run.html) | Starting the upgrade window and the tray in their own units, so closing one doesn't take the other with it |
| [org.freedesktop.login1](https://www.freedesktop.org/software/systemd/man/latest/org.freedesktop.login1.html) | The `PrepareForSleep` signal, so the tray checks again after the PC wakes up |
| [loginctl](https://www.freedesktop.org/software/systemd/man/latest/loginctl.html) | Linger, so a user timer keeps its schedule between logins |
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

Older versions of my updater used sudo rules with no password. That's gone. Now every change that needs root goes through a small helper and one polkit password box.

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

`auth_admin_keep` remembers your password for a few minutes, so two changes in a row only ask once.

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
| [QFileSystemWatcher](https://doc.qt.io/qt-5/qfilesystemwatcher.html) | Redrawing the moment a check writes new results |
| [QDBusConnection](https://doc.qt.io/qt-5/qdbusconnection.html) | Listening to logind |
| [QTimer](https://doc.qt.io/qt-5/qtimer.html) | The countdown to the next check |
| [Qt Style Sheets](https://doc.qt.io/qt-5/stylesheet-reference.html) | The cards, buttons and tabs |
| [Python subprocess](https://docs.python.org/3/library/subprocess.html), [json](https://docs.python.org/3/library/json.html), [pathlib](https://docs.python.org/3/library/pathlib.html) | The small jobs around it |
| [QThread](https://doc.qt.io/qt-5/qthread.html) | Checking for LinuxTweaks updates and downloading them without freezing About |
| [QPainter](https://doc.qt.io/qt-5/qpainter.html) | Drawing the on/off switches and the spinning dots |
| [Python pty](https://docs.python.org/3/library/pty.html) | A pretend terminal, so dnf5 draws its live progress bars in the install window |
| [console_codes](https://man7.org/linux/man-pages/man4/console_codes.4.html) | What `\r`, `ESC[1A` and `ESC[0J` mean, so the window can redraw dnf's bars in place |
| [Python urllib](https://docs.python.org/3/library/urllib.request.html) | Downloading the new RPM from my repo or GitHub |
| [GitHub REST API: contents](https://docs.github.com/en/rest/repos/contents) | Finding the newest RPM in my GitHub folder |

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
| [grubby](https://github.com/rhboot/grubby) | Showing and setting which kernel boots by default |
| [CachyOS kernels](https://github.com/CachyOS/linux-cachyos) | Keeping a CachyOS kernel as the default when Fedora installs a new one |

```bash
grubby --set-default "/boot/vmlinuz-$k"
```

### Try it yourself

```bash
uname -r                          # the kernel you're running
ls /lib/modules                   # every kernel you have
sudo grubby --default-kernel      # the one that boots next time
rpm -qa 'kernel*core*'            # which package each one came from
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

## 🎨 The look

| Source | What I used it for |
|---|---|
| [Nord](https://www.nordtheme.com/docs/colors-and-palettes) | Every colour in the window |
| [Shields.io](https://shields.io/) | The badges at the top of the README |

## 🔗 My own repo and Tailscale

| Source | What I used it for |
|---|---|
| [createrepo_c](https://github.com/rpm-software-management/createrepo_c) | Turning a folder of RPMs into a repo dnf can read |
| [RPM man pages](https://rpm-software-management.github.io/rpm/man/) | `rpmsign`, signing every package with my key |
| [Tailscale: sharing](https://tailscale.com/kb/1084/sharing) | Sharing only my repo server with friends, nothing else |

---

<div align="center">

[⬅ Back to the README](README.md) · [⬆ Back to top](#top)

</div>
