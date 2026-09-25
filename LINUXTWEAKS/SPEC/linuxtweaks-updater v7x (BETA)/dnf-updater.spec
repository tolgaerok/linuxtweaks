Name:           linuxtweaks-dnf-updater
Version:        7.1.173
Release:        4%{?dist}
Summary:       🛡️ Tolga's personal System tray for 📦 dnf/flatpak updates
License:        GPL-3.0-or-later
URL:            https://github.com/tolgaerok/linuxtweaks

Source0:        linuxtweaks-dnf-updater-%{version}.tar.gz

Packager:       Tolga Erok <kingtolga@gmail.com>
Vendor:         🫟 LinuxTweaks 2026

BuildArch:      noarch
Requires:       python3 >= 3.8
Requires:       dnf >= 4.0
Requires:       bash
# tray (PyQt5 - on the G4 it was only pip-installed, so a fresh system had none)
Requires:       python3dist(pyqt5)
# notify-send
Requires:       libnotify
# "Run DNF-Updater" opens the upgrade in konsole
Requires:       konsole
# lib/reboot_state.sh + lib/restart_services.sh
Requires:       dnf5-command(needs-restarting)
Recommends:     flatpak

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

%prep
%autosetup -n linuxtweaks-dnf-updater-%{version}

%install
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_libdir}/dnf-updater/lib
mkdir -p %{buildroot}%{_libdir}/dnf-updater/tray
mkdir -p %{buildroot}%{_libdir}/dnf-updater/bin
mkdir -p %{buildroot}%{_sysconfdir}/sudoers.d
mkdir -p %{buildroot}%{_sysconfdir}/xdg/autostart
mkdir -p %{buildroot}%{_datadir}/applications
mkdir -p %{buildroot}%{_libdir}/systemd/user
mkdir -p %{buildroot}%{_datadir}/icons/hicolor/48x48/apps


install -m 440 etc/sudoers.d/dnf-updater %{buildroot}%{_sysconfdir}/sudoers.d/
install -m 755 lib/check.sh lib/common.sh lib/flatpak_unused_packages.sh lib/full_upgrade.sh lib/kernel_reboot.sh lib/list_packages.sh lib/maintenance.sh lib/notification.sh lib/orphan_packages.sh lib/packages_cache.sh lib/restart_services.sh lib/reboot_state.sh lib/rpmnew_files.sh lib/tray.sh lib/update.sh %{buildroot}%{_libdir}/dnf-updater/lib/
install -m 644 tray/*.py %{buildroot}%{_libdir}/dnf-updater/tray/
install -m 755 tray/tray.py %{buildroot}%{_libdir}/dnf-updater/tray/
install -m 644 tray/dnf-updater-icon.png %{buildroot}%{_libdir}/dnf-updater/tray/
install -m 644 tray/dnf-updater-icon.png %{buildroot}%{_datadir}/icons/hicolor/48x48/apps/dnf-updater.png
install -m 755 usr/bin/dnf-updater %{buildroot}%{_bindir}/
install -m 755 usr/bin/dnf-updater-check %{buildroot}%{_bindir}/
install -m 755 usr/bin/dnf-updater-upgrade %{buildroot}%{_bindir}/
install -m 755 bin/cleanup.sh %{buildroot}%{_libdir}/dnf-updater/bin/
install -m 644 etc/xdg/autostart/dnf-updater-tray.desktop %{buildroot}%{_sysconfdir}/xdg/autostart/
install -m 644 etc/xdg/applications/dnf-updater.desktop %{buildroot}%{_datadir}/applications/
install -m 644 usr/lib/systemd/user/dnf-updater-check.service %{buildroot}%{_libdir}/systemd/user/
install -m 644 usr/lib/systemd/user/dnf-updater-check.timer %{buildroot}%{_libdir}/systemd/user/
install -m 644 usr/lib/systemd/user/dnf-updater-autostart.service %{buildroot}%{_libdir}/systemd/user/
install -m 644 usr/lib/systemd/user/dnf-updater-maintenance.service %{buildroot}%{_libdir}/systemd/user/
install -m 644 usr/lib/systemd/user/dnf-updater-maintenance.timer %{buildroot}%{_libdir}/systemd/user/

%check
python3 -m py_compile tray/*.py
bash -n lib/check.sh lib/common.sh lib/flatpak_unused_packages.sh lib/full_upgrade.sh lib/kernel_reboot.sh lib/list_packages.sh lib/maintenance.sh lib/notification.sh lib/orphan_packages.sh lib/packages_cache.sh lib/restart_services.sh lib/reboot_state.sh lib/rpmnew_files.sh lib/tray.sh lib/update.sh bin/cleanup.sh

%post
update-desktop-database %{_datadir}/applications 2>/dev/null || true
gtk-update-icon-cache %{_datadir}/icons/hicolor 2>/dev/null || true
systemctl --user daemon-reload 2>/dev/null || true

for user_home in /home/*; do
	if [ -d "$user_home" ]; then
		state_dir="$user_home/.local/state/dnf-updater"
		mkdir -p "$state_dir" 2>/dev/null || true
		# Make it owned by the user, not root
		if [ -f "$user_home/.bashrc" ]; then
			user=$(basename "$user_home")
			chown "$user:$user" "$state_dir" 2>/dev/null || true
			chmod 700 "$state_dir" 2>/dev/null || true
			# Keep this user's systemd --user manager alive across logout/suspend,
			# otherwise Persistent= timers (weekly maintenance) lose their last-run
			# state on every fresh login and fire immediately instead of weekly.
			loginctl enable-linger "$user" 2>/dev/null || true
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
echo -e "${YELLOW}🫟 LinuxTweak - system updater ${NC} ${BLUE}%{version}${NC} ${GREEN}installed!${NC}  🫟"
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
echo -e "${GREEN}😎 👉 Run: dnf-updater${NC}"
echo ""

%files
%attr(0440, root, root) %config(noreplace) %{_sysconfdir}/sudoers.d/dnf-updater
%{_bindir}/dnf-updater
%{_bindir}/dnf-updater-check
%{_bindir}/dnf-updater-upgrade
%{_libdir}/dnf-updater/lib/
%{_libdir}/dnf-updater/tray/
%{_libdir}/dnf-updater/bin/cleanup.sh
%{_datadir}/applications/dnf-updater.desktop
%{_sysconfdir}/xdg/autostart/dnf-updater-tray.desktop
%{_libdir}/systemd/user/dnf-updater-check.service
%{_libdir}/systemd/user/dnf-updater-check.timer
%{_libdir}/systemd/user/dnf-updater-autostart.service
%{_libdir}/systemd/user/dnf-updater-maintenance.service
%{_libdir}/systemd/user/dnf-updater-maintenance.timer
%{_datadir}/icons/hicolor/48x48/apps/dnf-updater.png

%postun
# Kill all running instances first
pkill -9 -f "python3.*tray.py" 2>/dev/null || true
pkill -9 -f "/usr/bin/dnf-updater" 2>/dev/null || true
sleep 2

# Remove all user state directories
for user_home in /home/*/; do
	if [ -d "$user_home" ]; then
		rm -rf "${user_home}.local/state/dnf-updater" 2>/dev/null || true
		rm -rf "${user_home}.config/dnf-updater" 2>/dev/null || true
	fi
done

# Remove root state
rm -rf /root/.local/state/dnf-updater 2>/dev/null || true
rm -rf /root/.config/dnf-updater 2>/dev/null || true

systemctl --user daemon-reload 2>/dev/null || true
update-desktop-database %{_datadir}/applications 2>/dev/null || true

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
echo -e "${YELLOW}🫟 LinuxTweak - system updater ${RED}REMOVED${NC} Thanks for using it!  🫟 ${NC}"
echo ""
echo -e "${BLUE} 👁️‍🗨️ Created by: Tolga Erok${NC}"
echo -e "${BLUE} 📧 Email:      kingtolga@gmail.com${NC}"
echo -e "${BLUE} 📡 GitHub:     https://github.com/tolgaerok/linuxtweaks${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

%changelog
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
- %post now runs `loginctl enable-linger` for each real user, so their
  systemd --user manager survives logout/suspend instead of being torn
  down and recreated on every session
- Without this, Persistent= timers (weekly maintenance) lost their
  last-run state on every fresh login/resume and fired immediately
  instead of waiting for the actual weekly schedule
- Not undone in %postun on purpose: lingering is a general per-user
  system setting, not owned exclusively by this package

* Thu Sep 24 2026 Tolga Erok <kingtolga@gmail.com> - 7.1.168-3
- Fixed self-kill bug: pkill -f "dnf-updater" in %postun/cleanup.sh matched
  the invoking dnf/rpm command line itself (it contains the package name
  "linuxtweaks-dnf-updater"), SIGKILLing the package manager mid-transaction
  on every install/remove/reinstall and corrupting the rpmdb (duplicate entries)
- Narrowed the pattern to the absolute wrapper path "/usr/bin/dnf-updater",
  which the dnf/rpm command line never contains

* Wed Sep 23 2026 Tolga Erok <kingtolga@gmail.com> - 7.1.168-2
- Added cleanup.sh script: removes all state/config dirs and processes on uninstall
- %postun now properly cleans up root and user state directories
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
- Simplified RPM %post script for reliability
- Production-ready hands-off installation
- All services enable when user first launches app
