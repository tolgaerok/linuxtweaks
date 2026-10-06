Name:           linuxtweaks-updater
Version:        8.1.2
Release:        1%{?dist}
Summary:       🛡️ Tolga's personal System tray for 📦 dnf/flatpak updates
License:        GPL-3.0-or-later
URL:            https://github.com/tolgaerok/linuxtweaks

Source0:        linuxtweaks-updater-%{version}.tar.gz

BuildArch:      noarch
# this is needed for the check section: py_compile, bash -n, desktop-file-validate
BuildRequires:  python3
BuildRequires:  bash
BuildRequires:  desktop-file-utils
BuildRequires:  systemd-rpm-macros
Requires:       python3 >= 3.8
# dnf5 only, needs-restarting is a dnf5 thing
Requires:       dnf5
Requires:       bash
# for the tray (PyQt5 > on my main deskop, G4, it was only pip-installed, so a fresh system had none)
Requires:       python3dist(pyqt5)
# i use notify-send for the popups
Requires:       /usr/bin/notify-send
# "Run LinuxTweaks Updater" opens the upgrade in konsole, so make sure konsole is available
Requires:       konsole
# anything that needs restarting, like, lib/reboot_state.sh + lib/restart_services.sh make sure these are present
Requires:       dnf5-command(needs-restarting)
# pgrep/pkill: the launcher's already-running check, tray restart after upgrade
Requires:       procps-ng
# the install window's password box
Requires:       polkit
# what my install/uninstall scripts need while they run
Requires(post):  systemd
Requires(post):  coreutils
Requires(post):  util-linux
Requires(preun): systemd
Requires(preun): procps-ng
Requires(preun): bash
Requires(postun): systemd
Recommends:     flatpak
# Renamed from linuxtweaks-dnf-updater in 7.2.0: replace it on upgrade, thps is cool
Obsoletes:      linuxtweaks-dnf-updater < 7.2.0
Provides:       linuxtweaks-dnf-updater = %{version}-%{release}
# Replaces my old LinuxTweaks 6.x tray app (package "linuxtweaks"): a normal
# dnf upgrade swaps it over, and "dnf install linuxtweaks" gets this instead
Obsoletes:      linuxtweaks < 7.0
Provides:       linuxtweaks = %{version}-%{release}
# LinuxTweaks-IO is the Drives tab now: an upgrade removes it (its own
# cleanup runs, the udev rule with your picks stays) and "dnf install
# linuxtweaks-io" gets this instead
Obsoletes:      linuxtweaks-io < 2.0
Provides:       linuxtweaks-io = %{version}-%{release}

%description
🫟 LinuxTweaks %{version} > My personal Fedora system update manager <

I wanted a single tool to handle everything: DNF packages, Flatpak apps,
firmware updates ... all in one place, all from the system tray. No more
hunting through different update tools. No more QTimer breaking after
suspend. Just set an interval and let it work.

Built for KDE Plasma on Fedora with PyQt5, systemd timers that actually
survive suspend/resume, and real-time update detection showing exactly
what needs updating. One-click upgrade or dry-run to see what would change.

Configure it once, forget about it. Designed and built for my Hamilton Hill,
Western Australia Fedora setup, but works great on any Fedora system.

 👁️‍🗨️ Created by: Tolga Erok
 📧 Email:      kingtolga@gmail.com
 📡 GitHub:     https://github.com/tolgaerok/linuxtweaks

# ---------------------------------------------------------------------------
# prep
# ---------------------------------------------------------------------------
%prep
%autosetup -n %{name}-%{version}

# ---------------------------------------------------------------------------
# build: nothing to compile
# ---------------------------------------------------------------------------
%build

# ---------------------------------------------------------------------------
# install
# ---------------------------------------------------------------------------
# noarch: app files go in /usr/lib/<name>, never the libdir macro (lib64 on arched builds)
%install
_app=%{buildroot}%{_prefix}/lib/%{name}

# --- commands ---------------------------------------------------------------
install -Dm755 -t %{buildroot}%{_bindir} usr/bin/%{name} usr/bin/%{name}-check usr/bin/%{name}-upgrade

# --- app: shell libs, tray, cleanup -----------------------------------------
install -Dm755 -t "$_app"/lib lib/*.sh
install -Dm644 -t "$_app"/tray tray/*.py tray/%{name}-icon.png
chmod 755 "$_app"/tray/tray.py
install -Dm755 -t "$_app"/bin bin/cleanup.sh bin/restart-tray.sh bin/%{name}-upgrade-helper bin/%{name}-set-scheduler bin/%{name}-memtune bin/%{name}-kernels bin/%{name}-journal bin/%{name}-tweaks
# the install window's root part and the polkit rule that asks for it in plain words
install -Dm644 -t %{buildroot}%{_datadir}/polkit-1/actions usr/share/polkit-1/actions/org.linuxtweaks.updater.policy

# --- desktop entries --------------------------------------------------------
install -Dm644 -t %{buildroot}%{_datadir}/applications etc/xdg/applications/%{name}.desktop
install -Dm644 -t %{buildroot}%{_sysconfdir}/xdg/autostart etc/xdg/autostart/%{name}-tray.desktop

# --- systemd user units -----------------------------------------------------
install -Dm644 -t %{buildroot}%{_userunitdir} usr/lib/systemd/user/%{name}-*

# --- weekly maintenance, a system timer (runs as root, no sudo) -------------
install -Dm644 -t %{buildroot}%{_unitdir} usr/lib/systemd/system/%{name}-maintenance.*

# --- /var/lib: linger list + last maintenance result ----------------------
install -dm755 %{buildroot}%{_sharedstatedir}/%{name}
touch %{buildroot}%{_sharedstatedir}/%{name}/linger-users
touch %{buildroot}%{_sharedstatedir}/%{name}/maintenance-last

# --- icons (sized copies made by build_new.sh) ------------------------------
for _icon in icons/*/%{name}.png; do
	_size=$(basename "$(dirname "$_icon")")
	install -Dm644 "$_icon" %{buildroot}%{_datadir}/icons/hicolor/"$_size"/apps/%{name}.png
done

# ---------------------------------------------------------------------------
# check
# ---------------------------------------------------------------------------
%check
python3 -m py_compile tray/*.py
# learnt the hard way as one file per bash -n: extra files are just arguments to the first
for f in lib/*.sh bin/*.sh; do bash -n "$f"; done
desktop-file-validate %{buildroot}%{_datadir}/applications/%{name}.desktop
desktop-file-validate %{buildroot}%{_sysconfdir}/xdg/autostart/%{name}-tray.desktop

# ---------------------------------------------------------------------------
# post
# ---------------------------------------------------------------------------
# Icon cache + desktop database refresh: handled by Fedora's file triggers as per fedora or RHEL way
%post
# real users only, not every folder in /home
getent passwd | while IFS=: read -r user _ uid _ _ user_home _; do
	[ "$uid" -ge 1000 ] 2>/dev/null && [ "$uid" -lt 60000 ] && [ -d "$user_home" ] || continue
	group=$(id -gn "$user" 2>/dev/null) || continue

	# renamed from dnf-updater in 7.2.0, bring the old settings over
	old_state="$user_home/.local/state/dnf-updater"
	if [ -d "$old_state" ] && [ ! -e "$user_home/.local/state/%{name}" ]; then
		mv "$old_state" "$user_home/.local/state/%{name}" 2>/dev/null || true
	fi
	# enable links of the old units point at files that no longer exist
	rm -f "$user_home"/.config/systemd/user/*.wants/dnf-updater-* 2>/dev/null || true
	# same for my old LinuxTweaks 6.x app (exact names, a glob hits my own units)
	for u in linuxtweaks.timer linuxtweaks.service linuxtweaks-autostart.service; do
		rm -f "$user_home"/.config/systemd/user/*.wants/"$u" 2>/dev/null || true
	done
	rm -f "$user_home/.config/autostart/dnf-updater-tray.desktop" 2>/dev/null || true

	# maintenance was a user timer before 7.4.0. was it on? keep it on
	for l in "$user_home"/.config/systemd/user/*.wants/%{name}-maintenance.timer; do
		[ -e "$l" ] || [ -L "$l" ] || continue
		rm -f "$l" 2>/dev/null || true
		touch %{_sharedstatedir}/%{name}/.maintenance-was-on 2>/dev/null || true
	done

	# older versions left these owned by root, give them back
	for d in .local .local/state .local/state/%{name}; do
		if [ -d "$user_home/$d" ] && [ "$(stat -c %%u "$user_home/$d")" = 0 ]; then
			chown "$user:$group" "$user_home/$d" 2>/dev/null || true
		fi
	done
	# made as the user, so it's never owned by root
	runuser -u "$user" -- sh -c 'umask 077; mkdir -p "$1"' _ "$user_home/.local/state/%{name}" 2>/dev/null || true

	# Thankyou Nixos!
	# lingering keeps the user timers alive. write down who I switched it on
	# for, so cleanup.sh only switches those back off
	if [ ! -e "/var/lib/systemd/linger/$user" ]; then
		if loginctl enable-linger "$user" 2>/dev/null; then
			grep -qx "$user" %{_sharedstatedir}/%{name}/linger-users 2>/dev/null ||
				echo "$user" >>%{_sharedstatedir}/%{name}/linger-users
		fi
	fi
done

# maintenance is off on a fresh install, on if it was on before
%systemd_post %{name}-maintenance.timer
if [ -e %{_sharedstatedir}/%{name}/.maintenance-was-on ]; then
	systemctl enable --now %{name}-maintenance.timer >/dev/null 2>&1 || :
	rm -f %{_sharedstatedir}/%{name}/.maintenance-was-on
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "▗▖  🫟  ▄▄▄▄  █  ▐▌▄   ▄ ▗▄▄▄▖▄   ▄ ▗▞▀▚▖▗▞▀▜▌█  ▄  ▄▄▄ "
echo "▐▌   ▄ █   █ ▀▄▄▞▘ ▀▄▀    █  █ ▄ █ ▐▛▀▀▘▝▚▄▟▌█▄▀  ▀▄▄  "
echo "▐▌   █ █   █      ▄▀ ▀▄   █  █▄█▄█ ▝▚▄▄▖     █ ▀▄ ▄▄▄▀ "
echo "▐▙▄▄▖█                    █                  █  █      "
echo -e "${NC}"
echo ""
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}🫟  LinuxTweaks Updater ${NC} ${BLUE}%{version}${NC} ${GREEN}installed!${NC}  🫟"
echo ""
echo -e "${BLUE} 👁️ Created by: Tolga Erok${NC}"
echo -e "${BLUE} 📧 Email:      kingtolga@gmail.com${NC}"
echo -e "${BLUE} 📡 GitHub:     https://github.com/tolgaerok/linuxtweaks${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}✓ Default Timer runs every 30 minutes${NC}"
echo -e "${YELLOW}✓ Autostart on login${NC}"
echo ""
echo -e "${GREEN}😎 👉 Run: linuxtweaks-updater${NC}"
echo ""

# ---------------------------------------------------------------------------
# posttrans
# ---------------------------------------------------------------------------
# stop the old user maintenance timer in logged in sessions (pre 7.4.0)
%posttrans
for run in /run/user/[0-9]*; do
	user=$(id -nu "${run##*/}" 2>/dev/null) || continue
	timeout 10 systemctl --user -M "$user@" stop %{name}-maintenance.timer >/dev/null 2>&1
	timeout 10 systemctl --user -M "$user@" daemon-reload >/dev/null 2>&1
	timeout 10 systemctl --user -M "$user@" reset-failed >/dev/null 2>&1
done
# restart running trays into the new version straight away
%{_prefix}/lib/%{name}/bin/restart-tray.sh || :

# ---------------------------------------------------------------------------
# files
# ---------------------------------------------------------------------------
%files
%license LICENSE
%{_bindir}/%{name}
%{_bindir}/%{name}-check
%{_bindir}/%{name}-upgrade
%{_prefix}/lib/%{name}/
%{_datadir}/applications/%{name}.desktop
%config(noreplace) %{_sysconfdir}/xdg/autostart/%{name}-tray.desktop
%{_userunitdir}/%{name}-*
%{_unitdir}/%{name}-maintenance.service
%{_unitdir}/%{name}-maintenance.timer
%{_datadir}/icons/hicolor/*/apps/%{name}.png
%{_datadir}/polkit-1/actions/org.linuxtweaks.updater.policy
%dir %{_sharedstatedir}/%{name}
%ghost %attr(0644, root, root) %{_sharedstatedir}/%{name}/linger-users
%ghost %attr(0644, root, root) %{_sharedstatedir}/%{name}/maintenance-last

# ---------------------------------------------------------------------------
# preun
# ---------------------------------------------------------------------------
# $1 = how many copies are left after this: 0 = real uninstall, 1+ = upgrade.
# brother, upgrades must never clean up, that used to wipe everyone's settings.
# preun runs while my files are still there, so cleanup.sh can still run.
# cleanup.sh does it all: stops and disables the timers for every user, bins
# settings, state, cache, temp files, and lingering if I switched it on
%preun
%systemd_preun %{name}-maintenance.timer %{name}-maintenance.service
if [ "$1" -eq 0 ]; then
	%{_prefix}/lib/%{name}/bin/cleanup.sh || :
fi

# ---------------------------------------------------------------------------
# postun
# ---------------------------------------------------------------------------
# everything's already cleaned in preun, this just says goodbye
%postun
%systemd_postun %{name}-maintenance.timer
if [ "$1" -eq 0 ]; then
	CYAN='\033[0;36m'
	BLUE='\033[0;34m'
	NC='\033[0m'
	YELLOW='\033[1;33m'
	RED='\033[0;31m'

	echo -e "${CYAN}"
	echo "▗▖  🫟  ▄▄▄▄  █  ▐▌▄   ▄ ▗▄▄▄▖▄   ▄ ▗▞▀▚▖▗▞▀▜▌█  ▄  ▄▄▄ "
	echo "▐▌   ▄ █   █ ▀▄▄▞▘ ▀▄▀    █  █ ▄ █ ▐▛▀▀▘▝▚▄▟▌█▄▀  ▀▄▄  "
	echo "▐▌   █ █   █      ▄▀ ▀▄   █  █▄█▄█ ▝▚▄▄▖     █ ▀▄ ▄▄▄▀ "
	echo "▐▙▄▄▖█                    █                  █  █      "
	echo -e "${NC}"
	echo ""
	echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
	echo -e "${YELLOW}🫟  LinuxTweaks Updater ${RED}REMOVED${NC} Thanks for using it!  🫟 ${NC}"
	echo ""
	echo -e "${BLUE} 👁️ Created by: Tolga Erok${NC}"
	echo -e "${BLUE} 📧 Email:      kingtolga@gmail.com${NC}"
	echo -e "${BLUE} 📡 GitHub:     https://github.com/tolgaerok/linuxtweaks${NC}"
	echo ""
	echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
	echo ""
fi

%changelog
* Tue Oct 06 2026 Tolga Erok <kingtolga@gmail.com> - 8.1.2-1
- LinuxTweaks-IO is retired, the Drives tab does everything it did and the
  read-ahead too. This update removes it for you. Your picks stay, the rules
  file is the same one, only its window and its tray icon go
- Using both at once wasn't safe, the old app dropped your read-ahead when
  it saved a scheduler

* Tue Oct 06 2026 Tolga Erok <kingtolga@gmail.com> - 8.1.1-1
- The LinuxTweaks window opens at 1200 by 790, the cards have room to
  breathe. Still drag it to any size you like
- The window says it's LinuxTweaks, KDE called it python3 in window rules
  and the task manager

* Tue Oct 06 2026 Tolga Erok <kingtolga@gmail.com> - 8.1.0-1
- New Network tab. What your connection uses now, and switches for my
  network tweaks: faster TCP with BBR, bigger buffers, CAKE on Wi-Fi and
  wired, Wi-Fi power saving off and IPv6 off. Each one says what it does
- Desktop tweaks in the Memory tab, the rest of my sysctl-desktop script:
  smooth big file copies, more file watchers and the safety net
- The settings go in 99-zz-desktop-performance.conf like my script writes.
  The first change moves my old 99-desktop-performance.conf out of the way
- Health has fixes now. Count from now for errors and crashes, restart or
  forget failed services, compare config files, reboot for a new kernel,
  remove dead login entries
- The I/O Scheduler tab is called Drives now, it has the read-ahead too and
  six tabs didn't fit

* Tue Oct 06 2026 Tolga Erok <kingtolga@gmail.com> - 8.0.9-1
- New Health tab, a quick look over the whole pc. Failed services, errors
  since boot, disk space, memory, crashes, SELinux, packages, the kernel,
  the logs and autostart, each on a green, orange or red card. Read only,
  no password, it's my check-system-health script
- Keep logs up to in the Updates settings, how much disk the system logs
  may take. 500 MB holds weeks, Fedora lets them grow to 4 GB. From my
  journal-cap script
- The tabs scroll when they don't fit, so the window opens at a size that
  fits a 1080 screen

* Tue Oct 06 2026 Tolga Erok <kingtolga@gmail.com> - 8.0.8-1
- New Kernels tab. Every installed kernel with its package and NVIDIA
  build, which one is running, which one boots by default, Boot by default
  and Remove. Remove never touches the running kernel, the last one, or
  kernel-headers. You also pick which new kernels take over as default when
  they install, so a Fedora kernel update doesn't push out your CachyOS one.
  I got caught by exactly that this week

* Tue Oct 06 2026 Tolga Erok <kingtolga@gmail.com> - 8.0.7-1
- Read-ahead on every drive card in the I/O Scheduler tab, next to the
  scheduler. Kept after a reboot in the same rules file. If a tuned profile
  sets read-ahead too, the tab says so, tuned wins at boot

* Tue Oct 06 2026 Tolga Erok <kingtolga@gmail.com> - 8.0.6-1
- What these mean opens 1200 wide, so most lines fit on one row and you
  scroll less

* Tue Oct 06 2026 Tolga Erok <kingtolga@gmail.com> - 8.0.5-1
- The Memory tab has a What these mean button. Every setting on a card in
  plain words: what zram is, what each compression is good at, what the
  swappiness numbers do and what Apply changes. Every choice in the
  dropdowns has a tooltip too. I had no idea what half of it meant myself
- The help guide is rewritten for LinuxTweaks: the window and its tabs, new
  I/O Scheduler and Memory sections, the new files, and what stays when you
  uninstall

* Tue Oct 06 2026 Tolga Erok <kingtolga@gmail.com> - 8.0.4-1
- You can resize the LinuxTweaks window now, wider and taller. It was
  locked at one width. It still won't go smaller than the cards need

* Tue Oct 06 2026 Tolga Erok <kingtolga@gmail.com> - 8.0.3-1
- In the I/O Scheduler tab the description sits on its own line under the
  dropdown, so you can read all of it. Next to the dropdown it got cut off.
  What it's best for and the drive's serial are in the tooltip
- Refresh doesn't flash the old cards on top of the new ones any more

* Tue Oct 06 2026 Tolga Erok <kingtolga@gmail.com> - 8.0.2-1
- The window is wider, 760 instead of 680. The I/O Scheduler cards were
  tight, the description got cut off early next to the dropdown

* Tue Oct 06 2026 Tolga Erok <kingtolga@gmail.com> - 8.0.1-1
- New Memory tab, the zram side of my memtune script. It shows how big the
  compressed swap in RAM is, how much is in use, the compression and the
  swappiness, and lets you change them. Recommended for this pc picks the
  same values memtune would
- Apply asks for your password once. Swappiness changes straight away, a
  new size or compression restarts zram, but only when what's in swap fits
  back into free RAM, otherwise it says so and changes nothing
- zswap stays in the script, it changes the kernel command line

* Tue Oct 06 2026 Tolga Erok <kingtolga@gmail.com> - 8.0.0-1
- LinuxTweaks Updater is turning into LinuxTweaks, one app for my tweaks.
  The window has tabs now, Updates is the first one
- LinuxTweaks-IO moved in as the I/O Scheduler tab. Same cards, same
  rules file, so your picks and the kept at boot ones carry straight over.
  A change asks for your password once and stays after a reboot
- The package is still called linuxtweaks-updater for now, so this is a
  normal upgrade

* Tue Oct 06 2026 Tolga Erok <kingtolga@gmail.com> - 7.7.4-1
- After an install or upgrade of mine the check did run, but in the
  background, so the tray never went yellow and it looked like nothing
  happened. Now the tray restarts with the check lined up itself: yellow
  dot, Checking for updates in 10s, then the check. Users without the tray
  running still get the background check
- The countdown says Checking for updates in…, not Woke up, since it's
  used after an install too

* Tue Oct 06 2026 Tolga Erok <kingtolga@gmail.com> - 7.7.3-1
- A short sleep didn't count as waking up. I only noticed a wake up when my
  clock skipped more than 30 seconds, so a 23 second suspend got no check
  at all. Now logind tells me every time the pc wakes up, however short the
  sleep was. The clock gap stays as a backup

* Tue Oct 06 2026 Tolga Erok <kingtolga@gmail.com> - 7.7.2-1
- After the pc wakes up the countdown sat on 0s with no yellow dot for half
  a minute, it looked frozen. It was waiting 30 seconds for the network on
  purpose. Now the dot goes yellow straight away, the countdown says Woke
  up, checking in 25s, and the check starts as soon as the network is
  back, usually after about 5 seconds

* Mon Oct 05 2026 Tolga Erok <kingtolga@gmail.com> - 7.7.1-1
- The help guide explains the install window now. It still talked about
  the old terminal upgrade
- Bigger icon at the top of the panel, same size as in About

* Mon Oct 05 2026 Tolga Erok <kingtolga@gmail.com> - 7.7.0-1
- Left click the tray icon for my new panel, in the same cards as my other
  windows. It shows what's waiting with the install button, if you need a
  reboot and why, and the settings
- The settings are a dropdown and two switches now, instead of three
  submenus. Plasma draws the right click menu itself and it can't do cards,
  so that menu only keeps the quick things: install, check, open the panel
  and exit

* Mon Oct 05 2026 Tolga Erok <kingtolga@gmail.com> - 7.6.2-1
- Every install or upgrade of mine checks for updates 10 seconds later, it
  doesn't wait for the tray's next check any more. You get a fresh popup
  straight away if anything is waiting

* Mon Oct 05 2026 Tolga Erok <kingtolga@gmail.com> - 7.6.1-1
- The popup still stayed up after an install when the tray wasn't running
  at that moment, like my build script's test install, which stops it
  first. Every logged in user gets the waiting popup closed and a fresh
  check now, tray running or not

* Mon Oct 05 2026 Tolga Erok <kingtolga@gmail.com> - 7.6.0-1
- Installing has its own window now, in my cards instead of a terminal.
  You see the steps, a progress bar and dnf's own output as it goes, and
  one password box that says what it's for
- No more questions in a terminal. When it's done, a reboot, services
  still running old code, packages nothing needs and changed config files
  are cards with a button each, and only when there's something to do
- Show in terminal follows the same log in Konsole, and Stop after this
  step never cuts dnf off halfway. With the tray closed the popup still
  opens the terminal upgrade, and linuxtweaks-updater-upgrade still works
- A popup still waiting closes when an install starts, and when my own
  package gets installed or upgraded. It used to stay up next to What's new
  with old numbers. A minute later the tray checks again, and if anything
  is still waiting you get a fresh one

* Mon Oct 05 2026 Tolga Erok <kingtolga@gmail.com> - 7.5.13-1
- What's new comes up after every install now, a reinstall of the same
  version too, so you can see it worked. Before it only came up once per
  version
- Run LinuxTweaks Updater in the menu is Install updates now. It opens
  Available updates first, so you see what's waiting and pick all, DNF or
  Flatpak, instead of it starting straight away

* Mon Oct 05 2026 Tolga Erok <kingtolga@gmail.com> - 7.5.12-1
- A new Available updates window, same cards as the rest of my windows.
  Security fixes come first with a red or orange stripe and how bad they
  are, then the rest of DNF in green and Flatpak in blue. Click a DNF one
  for what changed in it, install all or one side from the buttons
- The long DNF and Flatpak lists in the menu are one line now that opens
  the window. Plasma draws the menu itself, so it can't do cards
- Click the updates popup and it opens the window too

* Sun Oct 04 2026 Tolga Erok <kingtolga@gmail.com> - 7.5.11-1
- After you installed updates, the tray still said "5 security fixes"
  next to "System up to date" until the next check. The upgrade now
  clears them too, and the tray only counts fixes for packages that are
  still waiting, so updating with dnf or Discover clears them as well

* Sun Oct 04 2026 Tolga Erok <kingtolga@gmail.com> - 7.5.10-1
- Clicking a package in the DNF list opens instantly now. Each check
  already collects every waiting package's advisory and changelog in the
  background, so the click just reads them. Before, every click ran dnf
  twice, and after 6 hours it downloaded the repo data again first
- Security advisories show which CVEs they fix, with the bug title next
  to each link instead of a bare bugzilla link

* Sat Oct 03 2026 Tolga Erok <kingtolga@gmail.com> - 7.5.9-1
- Clicking a package in the DNF list is way faster. It only asks the repo
  the update comes from now. Before, dnf grabbed the changelogs for every
  repo first, 13 seconds on my PC, now 4. Once cached it's about a second

* Sat Oct 03 2026 Tolga Erok <kingtolga@gmail.com> - 7.5.8-1
- Updated me with dnf or Discover? The tray restarts into the new version
  the moment the install finishes, like other apps do. Before, it could
  take a couple of minutes

* Sat Oct 03 2026 Tolga Erok <kingtolga@gmail.com> - 7.5.7-1
- The desktop could freeze for a few seconds right after you log in. The
  tray checked the moment it started, then the timer checked again 30s
  after boot, so dnf ran four times while Plasma was still loading. Now
  only the timer checks at login
- Checks run at low priority, so dnf gives way to whatever you're doing.
  Clicking Check for updates still runs at full speed

* Fri Oct 02 2026 Tolga Erok <kingtolga@gmail.com> - 7.5.6-1
- Updated me with dnf or Discover? The tray restarts itself into the new
  version within a couple of minutes, so you get What's new and the new
  version without logging out. It waits till you're not using it
- Starting the tray while the upgrade window is open now tells you to
  finish or close that window. Alex tried five times and got no clue why
- An upgrade only counts as running when it really is mine. The old pid
  file could point at some other program after a while, and then the tray
  wouldn't start and checks got skipped for no reason

* Fri Oct 02 2026 Tolga Erok <kingtolga@gmail.com> - 7.5.5-1
- Updating from the popup could leave you with no tray till you logged in
  again, Alex found this one too. After an upgrade I restart the tray, and
  it was starting inside the upgrade window, so closing the window closed
  the tray. It gets its own unit now
- No tray when an upgrade ends, because you said n or there was nothing to
  install? It starts one now. Before, it only came back when something
  got installed

* Fri Oct 02 2026 Tolga Erok <kingtolga@gmail.com> - 7.5.4-1
- Install now on the popup could flash the upgrade window and close it
  again, Alex caught it. The tray and the timer both check every 30
  minutes and could run together. Both popped up, and the second popup
  closed the first, taking your upgrade window with it. Only one check
  runs at a time now, and the upgrade window gets its own unit so
  nothing that closes a popup can close it

* Fri Oct 02 2026 Tolga Erok <kingtolga@gmail.com> - 7.5.3-1
- Found the real stuck bug, thanks Alex. dnf run as you keeps its own copy
  of the repo keys and asked to import them (TeamViewer, Tailscale). The
  question was hidden, so the upgrade window waited forever, and the timer
  got a no and lost every dnf update. The check never asks anything now,
  it only reads. The real upgrade still checks keys as root
- Same fix for the package window, it could sit on Loading forever
- When the upgrade window has to check first you now see dnf loading each
  repo, instead of a cursor that looks stuck

* Fri Oct 02 2026 Tolga Erok <kingtolga@gmail.com> - 7.5.2-1
- No more checking while an upgrade is running. It saw the updates that
  were busy installing and put up a popup for them, and Install now on
  that popup looked stuck. Alex found this one
- Starting an upgrade closes a popup that's still waiting
- When the upgrade has to check first it tells you, dnf may need a few
  minutes to download its package lists

* Fri Oct 02 2026 Tolga Erok <kingtolga@gmail.com> - 7.5.1-1
- The updates popup used to stay on screen after an uninstall, or when a
  newer check replaced it, with buttons that did nothing. It closes
  itself now

* Fri Oct 02 2026 Tolga Erok <kingtolga@gmail.com> - 7.5.0-1
- Security fixes now stand out. The popup says how many and how bad, and
  they get a 🔴 in the DNF list. It comes from Fedora's own advisories
  that dnf already downloads, so nothing extra goes online
- A new security fix brings the popup back, even when the update count
  stays the same
- Click any package in the DNF list to see what changed in it, the
  advisory and the changelog since your version

* Thu Oct 01 2026 Tolga Erok <kingtolga@gmail.com> - 7.4.5-1
- Restarting services after an upgrade no longer fails on auditd. Services
  that refuse a manual restart aren't offered anymore, the next reboot
  picks them up

* Thu Oct 01 2026 Tolga Erok <kingtolga@gmail.com> - 7.4.4-1
- Tidied the message you get when you start the tray from a terminal

* Thu Oct 01 2026 Tolga Erok <kingtolga@gmail.com> - 7.4.3-1
- Rewrote About, Help and What's new short and to the point
- Tidied up the messages in the upgrade window too

* Thu Oct 01 2026 Tolga Erok <kingtolga@gmail.com> - 7.4.2-1
- Uninstall was moaning "remove failed" about /var/lib/linuxtweaks-updater.
  My cleanup deleted the folder before dnf could. Fixed, it's quiet now

* Thu Oct 01 2026 Tolga Erok <kingtolga@gmail.com> - 7.4.1-1
- What's new only counts as read when you close it yourself. A reboot or
  logout with it open was marking it as read, so you never saw it

* Thu Oct 01 2026 Tolga Erok <kingtolga@gmail.com> - 7.4.0-1
- Security fix. I removed my sudoers file. It let every admin on the pc
  run dnf, flatpak and journalctl as root with no password, from any
  program. Bad idea, my bad. The upgrade deletes it for you
- Checking for updates doesn't need sudo at all anymore
- Installing asks for your password once, right before the upgrade, and
  never again in that window. Say no and it won't ask at all
- Flatpak updates don't need sudo, Fedora already allows it for admins
- Weekly maintenance is a real system timer now and runs as root by
  itself. If you had it on, it stays on. Switching it on or off asks for
  your password because it's for the whole pc
- Maintenance shows how much DNF cache it really freed. It was looking
  in the old dnf4 folder and always said 0
- Logs shows the maintenance runs again
- No more failed unit after an upgrade. I was killing the tray with -9

* Wed Sep 30 2026 Tolga Erok <kingtolga@gmail.com> - 7.3.18-1
- Ships the GPL-3.0 licence file
- Installing on a pc with more than one user could leave root owned
  folders in someone else's home and mess up their next login. Fixed,
  and it repairs the ones older versions left behind
- Works for network and domain logins too
- Leaves nothing behind on uninstall
- Spec tidy up so install and uninstall can't trip over themselves

* Wed Sep 30 2026 Tolga Erok <kingtolga@gmail.com> - 7.3.17-1
- A repo kept showing up as an update that never went away. dnf's
  download line was being read as a package. Fixed
- 64 and 32 bit packages like glibc show their version properly

* Wed Sep 30 2026 Tolga Erok <kingtolga@gmail.com> - 7.3.16-1
- Fixed the tray crashing now and then. It was rebuilding the right click
  menu while you had it open
- A Python error won't take the whole tray down anymore

* Wed Sep 30 2026 Tolga Erok <kingtolga@gmail.com> - 7.3.15-1
- Help got the What's new look, a card per topic with links that jump
  straight to it
- Help lists the 1, 5 and 30 minute check intervals, 30 is the default

* Wed Sep 30 2026 Tolga Erok <kingtolga@gmail.com> - 7.3.14-1
- Logs and About got the What's new look too

* Tue Sep 29 2026 Tolga Erok <kingtolga@gmail.com> - 7.3.13-1
- The terminal list tells the two Mesa updates apart, same as the tray

* Tue Sep 29 2026 Tolga Erok <kingtolga@gmail.com> - 7.3.12-1
- Tidier flatpak list, just "Discord 1.0.159 → 1.0.160" and that's it

* Tue Sep 29 2026 Tolga Erok <kingtolga@gmail.com> - 7.3.11-1
- Flatpak updates weren't being found at all since 7.3.9. Fixed
- Counts flatpak runtimes too, like Mesa, same as Discover does

* Tue Sep 29 2026 Tolga Erok <kingtolga@gmail.com> - 7.3.10-1
- Popups for the menu settings only showed the first time. Plasma was
  swallowing the rest. Fixed

* Tue Sep 29 2026 Tolga Erok <kingtolga@gmail.com> - 7.3.9-1
- Apps from Fedora's own flatpak remote showed as updates forever. It
  only counts what flatpak update would really install now
- One real flatpak update was going missing from the count. Fixed
- Updates the flatpak apps installed just for you too

* Mon Sep 28 2026 Tolga Erok <kingtolga@gmail.com> - 7.3.8-1
- Asks for procps-ng (pgrep and pkill), the tray needs it

* Mon Sep 28 2026 Tolga Erok <kingtolga@gmail.com> - 7.3.7-1
- The tray sometimes said "Already running" when it wasn't. Fixed
- On a shared pc someone else's tray won't stop yours starting
- Restarting the tray only touches my tray, nothing else
- Running it from a terminal when it's already up tells you there,
  no more popup spam

* Mon Sep 28 2026 Tolga Erok <kingtolga@gmail.com> - 7.3.6-1
- Starting from a terminal tells you it's in the tray and you can close
  the terminal

* Mon Sep 28 2026 Tolga Erok <kingtolga@gmail.com> - 7.3.5-1
- Closing the terminal doesn't kill the tray anymore
- linuxtweaks-updater --foreground keeps it in the terminal so you can
  see what it's doing

* Mon Sep 28 2026 Tolga Erok <kingtolga@gmail.com> - 7.3.4-1
- Replaces my old LinuxTweaks 6.x tray app, a normal upgrade swaps it over
- Cleans up the old app's timers so nothing fails
- Ctrl-C quits the tray cleanly, no more crash
- Quitting the tray stops a check that's still running

* Mon Sep 28 2026 Tolga Erok <kingtolga@gmail.com> - 7.3.0-1
- Uninstall really removes everything now. It was leaving the timers
  running and failing every 30 minutes until a reboot
- Cleans up every user on the pc, the new name and the old dnf-updater
- Only switches lingering off for users I switched it on for
- Cleanup only stops my own tray
- Rewrote all my script comments in plain English

* Mon Sep 28 2026 Tolga Erok <kingtolga@gmail.com> - 7.2.2-5
- DNF only was still touching Flatpak after the update. Fixed, each one
  leaves the other alone
- The unused Flatpak check had a hidden question and removed stuff
  without showing you. You see the list first now and pick y or n

* Sun Sep 27 2026 Tolga Erok <kingtolga@gmail.com> - 7.2.2-4
- Update count badge is readable, 10 or more shows 9+
- The status dot doesn't cover the whole icon anymore
- Proper icon sizes for menus, popups and the launcher
- Spec tidy up, uninstall leaves no empty folders
- Your autostart edits survive upgrades
- On COPR now: sudo dnf copr enable tolgaerok/LinuxTweaks2026

* Sat Sep 26 2026 Tolga Erok <kingtolga@gmail.com> - 7.2.0-4
- New name, LinuxTweaks Updater (linuxtweaks-updater)
- Replaces linuxtweaks-dnf-updater on a normal upgrade and brings your
  settings and history over
- Upgrades were killing the tray and wiping your settings. Fixed,
  cleanup only runs on a real uninstall
- Weekly maintenance doesn't run an extra time when it starts
- About tells you what the app does, with Help and Uninstall buttons
- The update popup stays until you click it

* Sat Sep 26 2026 Tolga Erok <kingtolga@gmail.com> - 7.1.174-4
- New What's new window, shows up once after each update
- Update popups have buttons: Install all, DNF only, Flatpak only, Later.
  Later goes quiet for 4 hours
- Install DNF only or Flatpak only from the tray menu too

* Fri Sep 25 2026 Tolga Erok <kingtolga@gmail.com> - 7.1.173-4
- Split the tray into modules like LinuxTweaks v6
- New menu items, About and Logs, with the Nord look
- Popups replace each other instead of piling up
- Update count in the red dot, ↻ when a reboot is needed
- No more false "reboot required" on a fresh install
- Added the missing dependencies (PyQt5, libnotify, konsole)

* Fri Sep 25 2026 Tolga Erok <kingtolga@gmail.com> - 7.1.172-4
- The tray comes back properly after suspend
- A check stuck for 5 minutes gets killed
- The menu always shows DNF and Flatpak, even with no updates
- 32 and 64 bit packages aren't counted twice
- No crash on first start
- No "No Icon set" warning at startup

* Fri Sep 25 2026 Tolga Erok <kingtolga@gmail.com> - 7.1.171-4
- Service restarts actually work now. It finds every service running old
  code, pick them by number, 0 for all, Enter to skip
- The upgrade was stopping halfway after the restart step. Fixed
- Reboot check works on Fedora and names the new kernel
- Catches a new kernel even if you installed it with dnf or Discover,
  the tray turns orange and offers Reboot now
- Fewer popups, only when something changes

* Thu Sep 24 2026 Tolga Erok <kingtolga@gmail.com> - 7.1.169-4
- Switches on lingering so the weekly timer keeps its schedule after a
  logout or suspend. Thankyou Nixos!

* Thu Sep 24 2026 Tolga Erok <kingtolga@gmail.com> - 7.1.168-3
- Nasty one. The cleanup was killing dnf itself in the middle of an
  install or remove. Fixed

* Wed Sep 23 2026 Tolga Erok <kingtolga@gmail.com> - 7.1.168-2
- Added cleanup.sh, uninstall removes all my settings and folders

* Tue Sep 22 2026 Tolga Erok <kingtolga@gmail.com> - 7.1.166-1
- Weekly maintenance: cleans the DNF cache, trims the journal to 7 days
  and runs an SSD trim if Fedora isn't already doing it
- Switch it on or off from the tray menu

* Mon Sep 21 2026 Tolga Erok <kingtolga@gmail.com> - 7.1.157-1
- Only one tray at a time
- A crashed upgrade doesn't block the next one anymore
- Popups when an upgrade starts and finishes

* Sun Sep 20 2026 Tolga Erok <kingtolga@gmail.com> - 7.1.131-1
- Everything switches on the first time you open the app
