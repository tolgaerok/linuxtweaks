<a id="top"></a>

<div align="center">

# 🪨 Sources and references: AerynOS

**What I read to bring LinuxTweaks to AerynOS, and the moss stuff I had to dig out of the source myself.**

[⬅ Back to the README](README.md) · [📚 All sources](SOURCES.md) · [🎩 Fedora sources](SOURCES-FEDORA.md) · [🌀 Solus sources](SOURCES-SOLUS.md)

</div>

---

The AerynOS build is the Solus one moved over. Same tray, same tabs, same Nord look, but moss under it instead of eopkg, a `stone.yaml` built with boulder instead of `package.yml` and solbuild, and PyQt6 because AerynOS has no PyQt5 at all. The tray, the window, systemd, polkit, the desktop standards and the Health report are shared, so they're written up once on the [Fedora page](SOURCES-FEDORA.md). This page is what's different on AerynOS.

AerynOS moves fast and the docs are behind moss in places, so a lot of what's here I checked in the moss source ([os-tools](https://github.com/AerynOS/os-tools)) and on my own box. Where I did, the link goes to the exact commit I read.

The **Try it yourself** boxes are safe to paste. They only read unless they say otherwise.

## Contents

- [The AerynOS rules I follow](#-the-aerynos-rules-i-follow)
- [Packaging: stone.yaml and boulder](#-packaging-stoneyaml-and-boulder)
- [moss: updates and states](#%EF%B8%8F-moss-updates-and-states)
- [The new moss commands (0.26.10)](#-the-new-moss-commands-02610)
- [Old states that won't read](#-old-states-that-wont-read)
- [My own moss repo on your pc](#-my-own-moss-repo-on-your-pc)
- [Kernels and the boot menu](#-kernels-and-the-boot-menu)
- [What AerynOS does its own way](#-what-aerynos-does-its-own-way)
- [Signed stones on GitHub](#-signed-stones-on-github)
- [Quick reboot and the chime](#-quick-reboot-and-the-chime)
- [Shared with Fedora](#-shared-with-fedora)

---

## 📏 The AerynOS rules I follow

- **Packages follow the [AerynOS packaging docs](https://aerynos.com/packaging/).** A proper `stone.yaml`, the upstream tarball with its sha256, SPDX licence names, and `release` goes up by 1 for every build that goes out. It never resets, not even for a new version.
- **`/usr` is the OS, `/etc` is yours.** AerynOS is [stateless](https://aerynos.com/aerynos/philosophy/): the app lives under `/usr`, its defaults go in `/usr/share/defaults` like [AerynOS says](https://aerynos.com/users/system-management/configuration-locations/), and the background check gets switched on with a systemd preset, not by writing into `/etc`.
- **Every change is a moss state.** Nothing I do gets around that. Updates, removes and kernel changes all go through moss so you can always go back.
- **Every remove does a dry run first.** `moss remove kalk` wanted to take 281 packages with it because the Plasma pkgset needs kalk. So LinuxTweaks only goes ahead when the dry run takes just what you asked for.
- **It stays my own package.** The AerynOS recipes repo doesn't take anything made with AI tools ([their policy](https://github.com/AerynOS/recipes/blob/main/PACKAGING_POLICY.md)), so this never goes to them as a PR. It lives in my GitHub folder as a signed stone.

## 📦 Packaging: stone.yaml and boulder

| Source | What I used it for |
|---|---|
| [AerynOS packaging docs](https://aerynos.com/packaging/) | Where it all starts |
| [Recipe metadata](https://aerynos.com/packaging/recipes/metadata/) | `name`, `version`, `release`, `homepage` and `license` are a must |
| [Upstreams](https://aerynos.com/packaging/recipes/upstreams/) | A tarball upstream with its sha256. boulder takes a `file://` one and still checks the sum |
| [Build deps](https://aerynos.com/packaging/recipes/build-deps/) | `binary()`, `python()`, `pkgconfig()` and the rest |
| [Misc macros](https://aerynos.com/packaging/macros/misc/) | `%make_install`, `%install_file` |
| [Monitoring](https://aerynos.com/packaging/recipes/monitoring/) | `monitoring.yaml` for release and CVE tracking |
| [Basic workflow](https://aerynos.com/packaging/workflow/basic-workflow/) | Building, then a local repo with `moss index` and its `stone.index` |
| [os-tools: boulder/data/macros](https://github.com/AerynOS/os-tools) | Every macro there is, when the docs don't say |
| [AerynOS/recipes README](https://raw.githubusercontent.com/AerynOS/recipes/main/README.md) | `just bump` puts the release up. Nothing says when, so I do it on every build |

boulder runs as you, no sudo. It builds in a clean container with no network, it only needs subuid and subgid set for you, and AerynOS does that already. The install part of my `stone.yaml`, same Makefile as Fedora and Solus:

```yaml
install     : |
    %make_install LIBDIR=%(libdir)

    # the background check is on for every user, moss runs the preset
    %install_file %(pkgdir)/90-linuxtweaks-updater.preset -t %(installroot)%(prefix)/lib/systemd/user-preset/

    %install_file LICENSE -t %(installroot)%(datadir)/licenses/%(name)/
```

The stone it makes is named `name-version-release-build-arch.stone`, so `linuxtweaks-updater-1.0.9-10-1-x86_64.stone` is version 1.0.9, release 10, build 1.

### Try it yourself

**Learn from a real recipe.** Any `stone.yaml` in the AerynOS repo, `nano` here:

```bash
curl -s https://raw.githubusercontent.com/AerynOS/recipes/main/n/nano/stone.yaml
```

**Look inside a stone** without installing it. moss keeps its scratch in `./.moss` of wherever you run it, so do it in a temp folder:

```bash
cd "$(mktemp -d)" && moss extract /path/to/linuxtweaks-updater-1.0.9-10-1-x86_64.stone && ls
```

(on moss 0.26.10 and up it's `moss pkg extract --output-dir . <file>`)

## 🛠️ moss: updates and states

| Source | What I used it for |
|---|---|
| [moss state management](https://aerynos.com/users/system-management/moss-state-management/) | sync, states and going back to one |
| [General FAQ](https://aerynos.com/faq/general-faq/) | A new kernel needs a reboot |
| [os-tools: cli/pkg/list.rs](https://raw.githubusercontent.com/aerynOS/os-tools/7630acf727195fba7cac4bdb76cbe8bdb25aad73/moss/src/cli/pkg/list.rs) | What `moss list sync` prints: `name ver-rel => ver-rel - summary`, that's the line the tray reads |
| [os-tools: client/install.rs](https://raw.githubusercontent.com/AerynOS/os-tools/3d9f9fa58075e01270587296181dc96f7c3fb94a/moss/src/client/install.rs) | moss only installs names from a repo, never a file you hand it |

The check is split in two. A root unit does `moss repo update`, and my polkit rule lets you start just that unit. Then the tray runs `moss list sync` as you to see what's waiting. Installing is `sudo moss sync -u -y`, which refreshes the index first and does the lot in one new state.

moss has no orphan list like eopkg did. Every sync is a new state instead, so the Kernels tab has a **States** card: go back to an older one, or tidy away everything past the newest 5. **Reboot needed** compares the state you booted with the one that's active now, because moss doesn't keep an install date per package. After an update the clean step runs `moss cache prune`, which only drops downloads no state uses any more.

### Try it yourself

```bash
moss list sync               # what's waiting
moss state list              # every state, newest first
moss state active            # the one you're on   (0.26.10: moss state get-active)
moss info linuxtweaks-updater   # version and release you have, and any others moss can see
```

**Go back to an older state.** This one changes things. You can go forward again the same way, and a kernel change still needs a reboot:

```bash
sudo moss state activate 35
```

## 🔀 The new moss commands (0.26.10)

moss 0.26.10 renamed most of its commands and kept no aliases. LinuxTweaks asks `moss pkg --help` once: if it works it's the new moss, if it errors it's the old one. `lib/moss.sh` and `tray/moss_cli.py` hand out the right words for either, so the same build works on both.

| Old (0.26.8) | New (0.26.10) |
|---|---|
| `moss install` | `moss pkg add` |
| `moss remove --dry-run` | `moss pkg remove --dry-run` |
| `moss info` | `moss pkg info` (one name only) |
| `moss extract -o` | `moss pkg extract --output-dir` |
| `moss state active` | `moss state get-active` (just a number) |
| `moss state query` | `moss state info` |
| `moss state prune -k 10` | `moss state remove -k 10` |
| `moss index <folder>` | `moss index -i <folder>` |

| Source | What I took from it |
|---|---|
| [aerynOS/recipes#2982](https://github.com/aerynOS/recipes/pull/2982) | moss 0.26.8 to 0.26.10, merged 23 Oct, and it says it breaks `moss index` and `moss inspect` |
| [aerynOS/os-tools#196](https://github.com/aerynOS/os-tools/issues/196) | Why: the system model, and `state prune` turned into `state remove -k` |
| [cli.rs @ 7630acf](https://raw.githubusercontent.com/aerynOS/os-tools/7630acf727195fba7cac4bdb76cbe8bdb25aad73/moss/src/cli.rs) | The old names are gone. `-y` is still global, `--yes-all` isn't |
| [cli/pkg.rs @ 7630acf](https://raw.githubusercontent.com/aerynOS/os-tools/7630acf727195fba7cac4bdb76cbe8bdb25aad73/moss/src/cli/pkg.rs) | `pkg add`, `pkg remove --dry-run`, `pkg info`, `pkg extract --output-dir` with no `-o` |
| [cli/state.rs @ 7630acf](https://raw.githubusercontent.com/aerynOS/os-tools/7630acf727195fba7cac4bdb76cbe8bdb25aad73/moss/src/cli/state.rs) | `state get-active`, `state info <id>`, `state remove -k`, and `state list` shows the active one twice |
| [cli/index.rs @ 7630acf](https://raw.githubusercontent.com/aerynOS/os-tools/7630acf727195fba7cac4bdb76cbe8bdb25aad73/moss/src/cli/index.rs) | `moss index -i <dir>`, a plain folder doesn't work any more |
| [os-tools 7630acf...3b6dd70](https://github.com/aerynOS/os-tools/compare/7630acf727195fba7cac4bdb76cbe8bdb25aad73...3b6dd701f3c0293fba8e027eac51d5c97abf6775) | The recipe moved on to 3b6dd70. One commit, `pkg inspect` is just `inspect` again, nothing LinuxTweaks uses |

### Try it yourself

Which moss have you got?

```bash
moss version
moss pkg --help >/dev/null 2>&1 && echo "new moss" || echo "old moss"
```

## 🧱 Old states that won't read

This one bit me on 24 Oct. I was rebuilding LinuxTweaks a lot on my own box and half my states started saying

```
Error: state: client: No metadata found for package "f6aa63dd..."
```

Every Install state was broken and every Remove state was fine. My install takes the old LinuxTweaks out and puts the new one in, so each go makes two states. The Remove one doesn't have LinuxTweaks in it at all, the Install one does.

Here's why. moss knows every package in a state by the stone's sha256, not by its name. That hash is the package id. For the active state it reads the install db, for any other state it looks the hash up in the repo indexes. If the stone isn't in any index any more, you get "No metadata found". I was breaking it two ways:

1. My install deleted the old stone from my local repo before running `moss index`, so the old hash was gone straight away
2. I kept rebuilding on the same version and release, so every build was `linuxtweaks-updater-1.0.8-9-1-x86_64.stone` with different insides and a new hash

Pruning down to 3 states every update only hides it. Bumping by 10 doesn't do anything special either, the release just has to change on every build, so a bump of 1 does it. The old stones have to stay in an index somewhere too, one build per index, and that's the next section.

| Source | What I took from it |
|---|---|
| [cli/state.rs @ 3d9f9fa](https://raw.githubusercontent.com/AerynOS/os-tools/3d9f9fa58075e01270587296181dc96f7c3fb94a/moss/src/cli/state.rs) | `state query` looks every package up with `resolve_package` |
| [client/mod.rs @ 3d9f9fa](https://raw.githubusercontent.com/AerynOS/os-tools/3d9f9fa58075e01270587296181dc96f7c3fb94a/moss/src/client/mod.rs) | Only the active state gets the install db, old states go to the repos |
| [registry/plugin/active.rs @ 3d9f9fa](https://raw.githubusercontent.com/AerynOS/os-tools/3d9f9fa58075e01270587296181dc96f7c3fb94a/moss/src/registry/plugin/active.rs) | The install db only answers for what's in the active state |
| [registry/mod.rs @ 3d9f9fa](https://raw.githubusercontent.com/AerynOS/os-tools/3d9f9fa58075e01270587296181dc96f7c3fb94a/moss/src/registry/mod.rs) | Repos get sorted by priority, and `MissingMetadata` is the "No metadata found" error |
| On my box | `/.moss/db/install` (table `meta`) and `/.moss/db/state` (table `state_selections`) are sqlite. `package_id` in a state is the stone's sha256 |

3d9f9fa is the commit my moss 0.26.8 was built from (`moss version` says so).

### Try it yourself

**Find any broken states.** Only reads:

```bash
for s in $(moss state list | awk '/^State/ {print $2}' | tr -d '#'); do
    if moss state query "$s" 2>&1 | grep -q "No metadata found"; then
        echo "state $s: broken"
    else
        echo "state $s: ok"
    fi
done
```

(on 0.26.10 swap `state query` for `state info`)

**Throw the broken ones out.** This one changes things and you can't undo it, so check the numbers first. It's what I did:

```bash
sudo moss state remove 24 26 28 30 32 33
```

**See the hash moss uses for a package.** Needs `sqlite3`, reads only:

```bash
sqlite3 -readonly "file:/.moss/db/install?immutable=1" \
  "select package, version_identifier, source_release from meta where name = 'linuxtweaks-updater'"
```

## 🏠 My own moss repo on your pc

moss only installs by name from a repo, never a file. So LinuxTweaks has its own little repo on the pc, `/var/lib/linuxtweaks-updater/repo`, called `linuxtweaks-local` at priority 100. An update from the tray checks my signature first, then `lib/local_repo.sh` drops the stone in there, runs `moss index`, and moss takes the old one out and puts the new one in. If the new one won't go in, it goes back to the state from before.

The old builds have to stay readable too, and here's the catch: one index only ever holds one build of a package. `moss index` keeps the newest release and quietly drops the rest. I found that the hard way, my first go put all the old ones in one `repo-old` and the oldest states broke again after the next release. So now every old build gets its own folder, `/var/lib/linuxtweaks-updater/repo-old/1.0.9-10/` and so on, and its own repo, `linuxtweaks-old-1_0_9-10` at priority 1. moss turns anything in a repo name that isn't a letter, a number or `-` into `_` ([repository/mod.rs](https://raw.githubusercontent.com/AerynOS/os-tools/3d9f9fa58075e01270587296181dc96f7c3fb94a/moss/src/repository/mod.rs)), so the dots go. They're only there so old states still read, the newest at 100 always wins.

An old build goes once no state uses it any more. `local_repo.sh` reads that out of moss's own dbs, so when you prune states their old LinuxTweaks builds and repos go with them. The root refresh that runs before every check does `local_repo.sh --old-only` first, so it all comes right on the next check, whatever LinuxTweaks did the last install.

A new pc gets its first LinuxTweaks straight from my GitHub repo, and that only keeps the newest. So on an update `local_repo.sh` also looks in moss's download cache for any of my stones a state still uses and copies them into repo-old. moss keeps them there named by their sha256, `/.moss/cache/downloads/v1/<first 5>/<last 5>/<sha256>`, and `moss cache prune` leaves alone anything a state still needs.

Two more guards: my build script puts the release up by itself if that version and release was built already, and `local_repo.sh` won't take a different build under a name it already has.

| Source | What I took from it |
|---|---|
| [Basic workflow](https://aerynos.com/packaging/workflow/basic-workflow/) | A local repo is just a folder of stones with a `stone.index` from `moss index` |
| [client/index.rs @ 3d9f9fa](https://raw.githubusercontent.com/AerynOS/os-tools/3d9f9fa58075e01270587296181dc96f7c3fb94a/moss/src/client/index.rs) | "dupes by keeping the latest release", one build per package in an index, so one repo per old build |
| [client/sync.rs @ 3d9f9fa](https://raw.githubusercontent.com/AerynOS/os-tools/3d9f9fa58075e01270587296181dc96f7c3fb94a/moss/src/client/sync.rs) | sync takes `by_name(...).next()` with no release compare, the repo priority decides |
| [client/install.rs @ 3d9f9fa](https://raw.githubusercontent.com/AerynOS/os-tools/3d9f9fa58075e01270587296181dc96f7c3fb94a/moss/src/client/install.rs) | Install takes the first hit too, "First only, pre-sorted" |
| [registry/mod.rs @ 3d9f9fa](https://raw.githubusercontent.com/AerynOS/os-tools/3d9f9fa58075e01270587296181dc96f7c3fb94a/moss/src/registry/mod.rs) | Repos get sorted by priority, highest first |

### Try it yourself

```bash
moss repo list                             # linuxtweaks-local [100] and a linuxtweaks-old-1_0_9-10 style [1] for each old build
ls /var/lib/linuxtweaks-updater/repo       # only the newest
ls /var/lib/linuxtweaks-updater/repo-old   # a folder for every old build a state still uses
```

**Doing the same for your own app.** Changes things, it adds a repo. Bump the release every build, keep the newest alone, and give every old build its own folder and repo, one build per index:

```bash
sudo mkdir -p /var/lib/myapp/repo-old/1.0.8-9
sudo mv /var/lib/myapp/repo/myapp-1.0.8-9-1-x86_64.stone /var/lib/myapp/repo-old/1.0.8-9/
sudo moss index -i /var/lib/myapp/repo-old/1.0.8-9      # 0.26.8: sudo moss index <folder>
sudo moss repo add myapp-old-1_0_8-9 file:///var/lib/myapp/repo-old/1.0.8-9/stone.index -p 1
```

## 🐧 Kernels and the boot menu

No clr-boot-manager on AerynOS. blsforme writes the boot entries by itself on every sync, and Space at boot gets you the menu. The Kernels tab adds or removes a kind of kernel (stable, lts) and does the NVIDIA modules with it. Each kernel says which package and variant it is in `/usr/lib/kernel/<version>/boot.json`.

**Show the boot menu** in Kernels gives you 3 seconds to pick a kernel and it sticks after updates. blsforme writes `loader.conf` fresh every sync with only `default "aerynos*"`, so a timeout in there gets wiped. `bootctl set-timeout` saves it in an EFI variable instead, and that beats `loader.conf` anyway.

| Source | What I took from it |
|---|---|
| [blsforme systemd_boot/mod.rs](https://github.com/AerynOS/blsforme/blob/main/blsforme/src/bootloader/systemd_boot/mod.rs) | `loader.conf` gets written fresh every sync, only the default line |
| [bootctl(1)](https://www.freedesktop.org/software/systemd/man/latest/bootctl.html) | `set-timeout` saves it, `""` puts the boot loader back to its own timeout |
| [systemd-boot(7)](https://www.freedesktop.org/software/systemd/man/latest/systemd-boot.html) | `LoaderConfigTimeout` sticks across boots |
| `man loader.conf` on the box | The EFI variable beats `loader.conf` for the timeout |

### Try it yourself

```bash
ls /usr/lib/kernel/                        # every kernel you have
cat /usr/lib/kernel/*/boot.json            # which package each one came from
bootctl status 2>/dev/null | head -20      # what systemd-boot is doing
```

## 🧭 What AerynOS does its own way

Things I found on the box itself, AerynOS 2026.08 with moss 0.26.8:

- **sched_ext** starts lavd in auto, not flash like Solus. `/usr/share/defaults/scx_loader/config.toml` says so
- **The clock** syncs with ntpd-rs, not chrony or timesyncd. `/usr/lib/systemd/system-preset/98-ntpd-rs.preset`. Health knows that now
- **No AppArmor.** It isn't in `/sys/kernel/security/lsm`, so Health doesn't go looking for it
- **No security list.** AerynOS has no advisories in its index yet, so there's no Security card
- **PyQt6 only.** No PyQt5 at all, so the AerynOS tray is PyQt6

### Try it yourself

```bash
cat /usr/share/defaults/scx_loader/config.toml
cat /sys/kernel/security/lsm; echo
systemctl status ntpd-rs --no-pager | head -5
```

## 🔐 Signed stones on GitHub

Every stone in my GitHub folder has a `.asc` next to it, signed with the same key as the RPMs and eopkgs. The folder's a moss repo too, so a new pc does:

```bash
sudo moss repo add linuxtweaks https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/LINUXTWEAKS/STONE/AERYNOS/stone.index -p 10
sudo moss install linuxtweaks-updater      # 0.26.10 and up: sudo moss pkg add linuxtweaks-updater
```

After that, **About → Check for LinuxTweaks updates** reads the `AerynOS` badge on raw GitHub, downloads the new stone and its `.asc`, and checks it against the key that comes with the app. One that isn't signed by me never gets installed.

### Try it yourself

```bash
gpgv --keyring /usr/share/linuxtweaks-updater/linuxtweaks-key.gpg \
     linuxtweaks-updater-1.0.9-10-1-x86_64.stone.asc linuxtweaks-updater-1.0.9-10-1-x86_64.stone
```

`Good signature from "Tolga Erok (LinuxTweaks RPM Signing)"` means it's mine and nobody changed it.

## ⚡ Quick reboot and the chime

Both the same as on Solus.

Plasma hangs on the way out sometimes, and its own unit gives it 40s before systemd kills it, so the reboot sat on "a stop job is running for user 1000". The **Quick reboot, don't wait on Plasma** switch in Settings writes `~/.config/systemd/user/plasma-plasmashell.service.d/10-stop-timeout.conf` with `KillSignal=SIGKILL`. Only your user, no password, and off takes the file out.

The chime is a little sound when the install window's done, so you can walk off and still know. A switch in Settings, and switching it on plays it once.

| Source | What I took from it |
|---|---|
| [plasma-plasmashell.service.in](https://invent.kde.org/plasma/plasma-workspace/-/raw/master/shell/plasma-plasmashell.service.in) | Plasma's own unit sets `TimeoutSec=40sec`, that's the 40s |
| [systemd.unit(5)](https://www.freedesktop.org/software/systemd/man/latest/systemd.unit.html) | `~/.config/systemd/user` drop-ins go on top of the unit in `/usr/lib`, updates don't touch them |
| [systemd.kill(5)](https://www.freedesktop.org/software/systemd/man/latest/systemd.kill.html) | `KillSignal=` is what gets sent when the unit stops |
| [systemd.service(5)](https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html) | `TimeoutSec=` sets both start and stop |
| [Arch forum, 40s on reboot](https://bbs.archlinux.org/viewtopic.php?id=314567) | plasmashell stuck in the Wayland clipboard code till it got killed |
| [Zulip THIRDPARTY](https://github.com/zulip/zulip/blob/main/docs/THIRDPARTY) | `stairs` is Stefan Mertens' from Zulip, CC0, so it can go in a GPL package |
| [pw-cat(1)](https://docs.pipewire.org/page_man_pw-cat_1.html) | `pw-play --media-role=Notification` so it goes with your other notification sounds |
| [paplay(1)](https://man.archlinux.org/man/paplay.1) | The fallback when there's no `pw-play` |

## 🔗 Shared with Fedora

These are written up once, on the [Fedora page](SOURCES-FEDORA.md):

- [systemd: timers, services and sleep](SOURCES-FEDORA.md#%EF%B8%8F-systemd-timers-services-and-sleep)
- [Root without sudo rules: polkit](SOURCES-FEDORA.md#-root-without-sudo-rules-polkit)
- [Desktop standards](SOURCES-FEDORA.md#%EF%B8%8F-desktop-standards)
- [The tray and window: Python and Qt](SOURCES-FEDORA.md#-the-tray-and-window-python-and-qt)
- [Health and the report](SOURCES-FEDORA.md#-health-and-the-report)
- [Drives](SOURCES-FEDORA.md#-drives-schedulers-and-read-ahead), [Memory](SOURCES-FEDORA.md#-memory-zram-and-sysctl) and [Network](SOURCES-FEDORA.md#-network-bbr-cake-and-networkmanager)
- [Bash](SOURCES-FEDORA.md#-bash) and [the look](SOURCES-FEDORA.md#-the-look)
- [CPU scheduler: sched_ext](SOURCES-FEDORA.md#-cpu-scheduler-sched_ext), AerynOS starts lavd in auto
- [Boxes: distrobox and LumineCapture](SOURCES-FEDORA.md#-boxes-distrobox-and-luminecapture), where the `.utf8` language fix comes from
- [Nix](SOURCES-FEDORA.md#%EF%B8%8F-nix) and [Extras: WPS Office](SOURCES-FEDORA.md#-extras-wps-office)
- [Restarting services after an update](SOURCES-FEDORA.md#-restarting-services-after-an-update), same window and same careful list
- [A new LinuxTweaks within seconds](SOURCES-FEDORA.md#-a-new-linuxtweaks-within-seconds), on AerynOS it reads the `AerynOS` badge on raw GitHub
- [Usage sharing, only if you say yes](SOURCES-FEDORA.md#-usage-sharing-only-if-you-say-yes), same popup and same Worker, the About this PC and What LinuxTweaks does here tick boxes too

---

<div align="center">

[⬅ Back to the README](README.md) · [📚 All sources](SOURCES.md) · [🎩 Fedora sources](SOURCES-FEDORA.md) · [🌀 Solus sources](SOURCES-SOLUS.md) · [⬆ Back to top](#top)

</div>
