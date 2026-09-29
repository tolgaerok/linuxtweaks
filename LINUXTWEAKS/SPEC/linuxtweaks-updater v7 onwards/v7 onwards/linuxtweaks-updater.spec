Name:           linuxtweaks-updater
Version:        7.3.10
Release:        1%{?dist}
Summary:       🛡️ Tolga's personal System tray for 📦 dnf/flatpak updates
License:        GPL-3.0-or-later
URL:            https://github.com/tolgaerok/linuxtweaks

Source0:        linuxtweaks-updater-%{version}.tar.gz

Packager:       Tolga Erok <kingtolga@gmail.com>
Vendor:         🫟 LinuxTweaks 2026

BuildArch:      noarch
# this is needed for the check section: py_compile, bash -n, desktop-file-validate
BuildRequires:  python3
BuildRequires:  bash
BuildRequires:  desktop-file-utils
BuildRequires:  systemd-rpm-macros
Requires:       python3 >= 3.8
Requires:       dnf >= 4.0
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
Recommends:     flatpak
# Renamed from linuxtweaks-dnf-updater in 7.2.0: replace it on upgrade, thps is cool
Obsoletes:      linuxtweaks-dnf-updater < 7.2.0
Provides:       linuxtweaks-dnf-updater = %{version}-%{release}
# Replaces my old LinuxTweaks 6.x tray app (package "linuxtweaks"): a normal
# dnf upgrade swaps it over, and "dnf install linuxtweaks" gets this instead
Obsoletes:      linuxtweaks < 7.0
Provides:       linuxtweaks = %{version}-%{release}

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
install -Dm755 -t "$_app"/bin bin/cleanup.sh

# --- sudoers ----------------------------------------------------------------
install -Dm440 -t %{buildroot}%{_sysconfdir}/sudoers.d etc/sudoers.d/%{name}

# --- desktop entries --------------------------------------------------------
install -Dm644 -t %{buildroot}%{_datadir}/applications etc/xdg/applications/%{name}.desktop
install -Dm644 -t %{buildroot}%{_sysconfdir}/xdg/autostart etc/xdg/autostart/%{name}-tray.desktop

# --- systemd user units -----------------------------------------------------
install -Dm644 -t %{buildroot}%{_userunitdir} usr/lib/systemd/user/%{name}-*

# --- state folder for the linger list (see post) ---------------------------
install -dm755 %{buildroot}%{_sharedstatedir}/%{name}

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
for user_home in /home/*; do
	if [ -d "$user_home" ]; then
		# Renamed from dnf-updater (7.2.0): keep the user's settings + history.
		# Must happen here, before the obsoleted package's postun deletes
		# ~/.local/state/dnf-updater.
		old_state="$user_home/.local/state/dnf-updater"
		if [ -d "$old_state" ] && [ ! -e "$user_home/.local/state/%{name}" ]; then
			mv "$old_state" "$user_home/.local/state/%{name}" 2>/dev/null || true
		fi
		# enable links of the old units point at files that no longer exist
		rm -f "$user_home"/.config/systemd/user/*.wants/dnf-updater-* 2>/dev/null || true
		# same for my old LinuxTweaks 6.x app (exact names - a linuxtweaks* glob
		# would hit this package's own linuxtweaks-updater-* units)
		for u in linuxtweaks.timer linuxtweaks.service linuxtweaks-autostart.service; do
			rm -f "$user_home"/.config/systemd/user/*.wants/"$u" 2>/dev/null || true
		done
		rm -f "$user_home/.config/autostart/dnf-updater-tray.desktop" 2>/dev/null || true
		state_dir="$user_home/.local/state/%{name}"
		mkdir -p "$state_dir" 2>/dev/null || true
		# Make it owned by the user, not root
		if [ -f "$user_home/.bashrc" ]; then
			user=$(basename "$user_home")
			chown "$user:$user" "$state_dir" 2>/dev/null || true
			chmod 700 "$state_dir" 2>/dev/null || true
			# Thankyou Nixos!
			# Keep this user's systemd --user manager alive across logout/suspend,
			# otherwise Persistent= timers (weekly maintenance) lose their last-run
			# state on every fresh login and fire immediately instead of weekly.
			# only if it's off now, and write down that it was me who switched it
			# on, so cleanup.sh can switch it off again on uninstall
			if [ ! -e "/var/lib/systemd/linger/$user" ]; then
				if loginctl enable-linger "$user" 2>/dev/null; then
					grep -qx "$user" %{_sharedstatedir}/%{name}/linger-users 2>/dev/null ||
						echo "$user" >>%{_sharedstatedir}/%{name}/linger-users
				fi
			fi
		fi
	fi
done

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
echo -e "${YELLOW}🫟 LinuxTweaks Updater ${NC} ${BLUE}%{version}${NC} ${GREEN}installed!${NC}  🫟"
echo ""
echo -e "${BLUE} 👁️‍🗨️ Created by: Tolga Erok${NC}"
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
# files
# ---------------------------------------------------------------------------
%files
%attr(0440, root, root) %config(noreplace) %{_sysconfdir}/sudoers.d/%{name}
%{_bindir}/%{name}
%{_bindir}/%{name}-check
%{_bindir}/%{name}-upgrade
%{_prefix}/lib/%{name}/
%{_datadir}/applications/%{name}.desktop
%config(noreplace) %{_sysconfdir}/xdg/autostart/%{name}-tray.desktop
%{_userunitdir}/%{name}-*
%{_datadir}/icons/hicolor/*/apps/%{name}.png
# holds linger-users, the list of users %%post switched lingering on for
%dir %{_sharedstatedir}/%{name}

# ---------------------------------------------------------------------------
# preun
# ---------------------------------------------------------------------------
# $1 = how many copies are left after this: 0 = real uninstall, 1+ = upgrade.
# brother, upgrades must never clean up, that used to wipe everyone's settings.
# preun runs while my files are still there, so cleanup.sh can still run.
# cleanup.sh does it all: stops and disables the timers for every user, bins
# settings, state, cache, temp files, and lingering if I switched it on
%preun
if [ "$1" -eq 0 ]; then
	%{_prefix}/lib/%{name}/bin/cleanup.sh || :
fi

# ---------------------------------------------------------------------------
# postun
# ---------------------------------------------------------------------------
# everything's already cleaned in preun, this just says goodbye
%postun
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
	echo -e "${YELLOW}🫟 LinuxTweaks Updater ${RED}REMOVED${NC} Thanks for using it!  🫟 ${NC}"
	echo ""
	echo -e "${BLUE} 👁️‍🗨️ Created by: Tolga Erok${NC}"
	echo -e "${BLUE} 📧 Email:      kingtolga@gmail.com${NC}"
	echo -e "${BLUE} 📡 GitHub:     https://github.com/tolgaerok/linuxtweaks${NC}"
	echo ""
	echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
	echo ""
fi

%changelog
* Tue Sep 29 2026 Tolga Erok <kingtolga@gmail.com> - 7.3.10-1
- Fixed the popups for Check interval, Notifications and Weekly maintenance
  only showing the first time: Plasma silently swallowed the later ones

* Tue Sep 29 2026 Tolga Erok <kingtolga@gmail.com> - 7.3.9-1
- Fixed flatpak updates that never go away: apps from Fedora's own flatpak
  remote were counted as updates forever. Only counts what "flatpak update"
  would really update now
- Fixed one real flatpak update being dropped from the count
- Also updates flatpak apps installed just for your account (--user)

* Mon Sep 28 2026 Tolga Erok <kingtolga@gmail.com> - 7.3.8-1
- Declares procps-ng (pgrep/pkill), which the launcher and the tray
  restart use - always there on a desktop, missing in minimal containers

* Mon Sep 28 2026 Tolga Erok <kingtolga@gmail.com> - 7.3.7-1
- Fixed the tray sometimes refusing to start ("Already running" when it
  wasn't): the check matched any process that merely mentioned the tray's
  path (an editor, grep, a script). It now only counts your own real tray
- On a shared PC, another user's tray no longer stops yours from starting
- Restarting the tray after an upgrade only stops this app's tray, not
  any other program that happens to be called tray.py
- Running linuxtweaks-updater in a terminal while the tray is already up
  now says so in the terminal instead of a desktop notification (running
  it a few times in a row used to hit Plasma's "Created too many similar
  notifications" error); from the app menu it's still a notification

* Mon Sep 28 2026 Tolga Erok <kingtolga@gmail.com> - 7.3.6-1
- Starting the tray from a terminal now shows a clear coloured message:
  that it's running in the tray, and that the terminal can be closed

* Mon Sep 28 2026 Tolga Erok <kingtolga@gmail.com> - 7.3.5-1
- Started from a terminal, the tray now detaches, so closing the terminal
  no longer closes the tray (it got SIGHUP and quit)
- linuxtweaks-updater --foreground keeps it attached and shows its output,
  for troubleshooting

* Mon Sep 28 2026 Tolga Erok <kingtolga@gmail.com> - 7.3.4-1
- Replaces my old LinuxTweaks 6.x tray app: a normal dnf upgrade swaps
  it over, and "dnf install linuxtweaks" now installs this instead
- Cleans up the old app's timer links, so it leaves no failed units
- Ctrl-C (or kill) on a tray started from a terminal now quits cleanly,
  instead of a Python traceback and a core dump on the second Ctrl-C
- Quitting the tray also stops an update check that was still running

* Mon Sep 28 2026 Tolga Erok <kingtolga@gmail.com> - 7.3.0-1
- Uninstall now really removes everything. Before, it left the timers
  switched on and still running (failing every 30 minutes until you
  rebooted), plus the cache and temp folders
- dnf remove runs cleanup.sh for every user: stops and disables the
  timers, removes settings, state, cache, temp files and autostart,
  under the new name and the old dnf-updater one
- Lingering gets switched off again, but only for users this app
  switched it on for. If you had it on for something else, it stays
- Cleanup only stops my own tray now, not any other python tray.py
- build_new.sh test install works when only the release changed
  (7.2.2-4 to 7.2.2-5 used to do nothing)
- Comments in all the scripts rewritten in plain English

* Mon Sep 28 2026 Tolga Erok <kingtolga@gmail.com> - 7.2.2-5
- Fixed: "DNF only" was still touching Flatpak. The update itself was
  fine, but the cleanup after it ran flatpak repair and the unused
  Flatpak check anyway. Now DNF only leaves Flatpak alone, and Flatpak
  only leaves DNF alone
- Fixed: the unused Flatpak check had a hidden [Y/n] question from
  flatpak itself. The window looked stuck, you hit Enter, and it removed
  the unused runtimes without showing you. Now you see the list first
  and decide with y/N

* Sun Sep 27 2026 Tolga Erok <kingtolga@gmail.com> - 7.2.2-4
- Update count badge is readable at tray size: the number grows with
  the dot, and 10+ updates show "9+" in a wider pill
- Tray icon draws on the full-size image again (the status dot no longer
  covers the whole icon)
- Proper icon sizes (16-96px) for menus, notifications and the launcher
- Spec cleanup: whole app dir owned by the package (uninstall leaves no
  empty folders), .desktop files validated at build time, every shell
  script syntax-checked (only the first one was before)
- Autostart entry keeps your edits across upgrades
- Now on COPR: sudo dnf copr enable tolgaerok/LinuxTweaks2026

* Sat Sep 26 2026 Tolga Erok <kingtolga@gmail.com> - 7.2.0-4
- Renamed to LinuxTweaks Updater (linuxtweaks-updater), following the
  LinuxTweaks naming: commands linuxtweaks-updater, -check and -upgrade,
  files in /usr/lib/linuxtweaks-updater, units linuxtweaks-updater-*
- Replaces linuxtweaks-dnf-updater on a normal dnf upgrade (Obsoletes);
  your settings, update state and What's new history move over from
  ~/.local/state/dnf-updater automatically
- Fixed: every upgrade used to kill the tray and delete all settings -
  cleanup now only runs on a real uninstall
- Weekly maintenance timer no longer fires an extra run when it starts
- About now describes what the app does, with Help (a full user guide)
  and Uninstall buttons; release notes live only in What's new
- The update notification stays until you click a button or close it
  (Plasma used to hide it after a few seconds, taking the buttons along)

* Sat Sep 26 2026 Tolga Erok <kingtolga@gmail.com> - 7.1.174-4
- New "What's new" window: a card per release from this changelog, shown
  once after the updater updates itself, and from the tray menu anytime
- Update notifications now have buttons: Install all / DNF only /
  Flatpak only / Later (Later snoozes reminders for 4 hours)
- Tray DNF and Flatpak submenus get "Install ... updates only" when both
  kinds have updates
- dnf-updater-upgrade --dnf / --flatpak installs just that part; a
  Flatpak-only run skips the .rpmnew and service-restart steps
- New lib/notify_actions.sh runs the button notification as its own
  transient user unit, so it can wait for a click after check.sh ends

* Fri Sep 25 2026 Tolga Erok <kingtolga@gmail.com> - 7.1.173-4
- Tray split into modules (like LinuxTweaks v6): tray.py is now a small
  launcher at the same path (pgrep/pkill and /usr/bin/dnf-updater find it
  by it); code lives in app, menu, checker, state, config, icons, tooltip,
  notify, systemd, about_dialog, log_dialog, theme and version .py
- New tray menu entries: About (changelog read from this RPM) and Logs
  (dnf update history + the updater's own journal), Nord-themed dialogs
- Tray notifications replace the previous one instead of stacking
- Update count shown in the tray's red dot (9+), ↻ on the reboot dot
- Fixed false "reboot required" on accounts with no dnf cache (fresh
  install, laptop): needs-restarting now runs with --disablerepo='*' and
  the JSON reboot_required field is read instead of the exit code
- build_new.sh writes the version to tray/version.py and compiles every
  tray module; spec installs tray/*.py
- Added missing Requires: python3dist(pyqt5), libnotify, konsole,
  dnf5-command(needs-restarting); Recommends: flatpak

* Fri Sep 25 2026 Tolga Erok <kingtolga@gmail.com> - 7.1.172-4
- Tray recovers after suspend: detects the wake-up, drops the stale check
  and checks again 30s later (the countdown used to stay at zero)
- Watchdog kills a check that hangs longer than 5 minutes
- Tray menu always shows DNF (n) with "No updates", like Flatpak
- Multilib packages (i686 + x86_64) no longer listed/counted twice
- Tray no longer crashes on first start with no state directory
- No "QSystemTrayIcon::setVisible: No Icon set" warning at startup

* Fri Sep 25 2026 Tolga Erok <kingtolga@gmail.com> - 7.1.171-4
- Service restarts now work: `dnf needs-restarting -s` finds every service
  running replaced code (was a 5-package hardcoded list reading a file that
  update.sh had already emptied); numbered prompt, 0 = all, enter = skip;
  display manager, dbus and logind are never offered
- Fixed restart_services.sh `exit 0` ending the whole upgrade: rpmnew,
  flatpak cleanup, cache clean and orphans were skipped after every update
- Reboot detection now uses `dnf needs-restarting` (the Arch check for a
  vanished running kernel can never fire on Fedora); names the new kernel
- New lib/reboot_state.sh, also run by every timer check, so kernels
  installed by plain dnf or Discover are caught; tray shows
  "Reboot required" + "Reboot now" and an orange icon
- Notifications: "reboot required" once per reason, update counts only
  when they change, manual checks always answer, no tray duplicates
- common.sh sourced once from the right path (ask_msg was undefined);
  upgrade order matches Cachy-Update: cleanup, reboot prompt, services
- Check timer no longer Requires= its service (fired an extra check)

* Thu Sep 24 2026 Tolga Erok <kingtolga@gmail.com> - 7.1.169-4
- %%post now runs `loginctl enable-linger` for each real user, so their
  systemd --user manager survives logout/suspend instead of being torn
  down and recreated on every session
- Without this, Persistent= timers (weekly maintenance) lost their
  last-run state on every fresh login/resume and fired immediately
  instead of waiting for the actual weekly schedule
- Not undone in %%postun on purpose: lingering is a general per-user
  system setting, not owned exclusively by this package

* Thu Sep 24 2026 Tolga Erok <kingtolga@gmail.com> - 7.1.168-3
- Fixed self-kill bug: pkill -f "dnf-updater" in %%postun/cleanup.sh matched
  the invoking dnf/rpm command line itself (it contains the package name
  "linuxtweaks-dnf-updater"), SIGKILLing the package manager mid-transaction
  on every install/remove/reinstall and corrupting the rpmdb (duplicate entries)
- Narrowed the pattern to the absolute wrapper path "/usr/bin/dnf-updater",
  which the dnf/rpm command line never contains

* Wed Sep 23 2026 Tolga Erok <kingtolga@gmail.com> - 7.1.168-2
- Added cleanup.sh script: removes all state/config dirs and processes on uninstall
- %%postun now properly cleans up root and user state directories
- Kills all running instances before cleanup to prevent "in use" errors

* Tue Sep 22 2026 Tolga Erok <kingtolga@gmail.com> - 7.1.166-1
- Added weekly maintenance timer: dnf cache clean, journal vacuum (7d), SSD TRIM
- TRIM is skipped automatically if the system's own fstrim.timer is already enabled
- Added desktop notifications for maintenance start/completion
- Added tray menu toggle to enable/disable weekly maintenance
- New sudoers grants for journalctl and fstrim (NOPASSWD, scoped like existing dnf/flatpak rules)

* Mon Sep 21 2026 Tolga Erok <kingtolga@gmail.com> - 7.1.157-1
- Fixed debug output spam from tray.py read_updates()
- Added PID-based stale lock detection to prevent blocking from crashed upgrades
- Added instance detection in main launcher to prevent multiple tray instances
- Implemented desktop notifications for:
  * Already running instance (main launcher + full_upgrade + tray)
  * Upgrade start and completion
- Improved lock checking with kill -0 process verification
- Fixed banner to display correct dnf-updater command
- Enhanced user feedback with notification icons

* Sun Sep 20 2026 Tolga Erok <kingtolga@gmail.com> - 7.1.131-1
- Service enablement moved to Python application startup
- Simplified RPM %%post script for reliability
- Production-ready hands-off installation
- All services enable when user first launches app
