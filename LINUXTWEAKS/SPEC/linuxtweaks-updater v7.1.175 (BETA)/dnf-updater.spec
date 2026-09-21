Name:           linuxtweaks-dnf-updater
Version:        7.1.157
Release:        1%{?dist}
Summary:        🛡️ Tolga's personal System tray for 📦 dnf/flatpak updates
License:        GPL-3.0-or-later
URL:            https://github.com/tolgaerok/linuxtweaks

Source0:        linuxtweaks-dnf-updater-%{version}.tar.gz

Packager:       Tolga Erok <kingtolga@gmail.com>
Vendor:         🫟 LinuxTweaks 2026

BuildArch:      noarch
BuildRequires:  python3
Requires:       /usr/bin/python3
Requires:       /usr/bin/bash

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
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/lib/dnf-updater/lib
mkdir -p %{buildroot}/usr/lib/dnf-updater/tray
mkdir -p %{buildroot}/etc/sudoers.d
mkdir -p %{buildroot}/etc/xdg/autostart
mkdir -p %{buildroot}/usr/share/applications
mkdir -p %{buildroot}/usr/lib/systemd/user
mkdir -p %{buildroot}/usr/share/icons/hicolor/48x48/apps

install -m 440 etc/sudoers.d/dnf-updater %{buildroot}/etc/sudoers.d/
install -m 755 lib/check.sh lib/common.sh lib/flatpak_unused_packages.sh lib/full_upgrade.sh lib/kernel_reboot.sh lib/list_packages.sh lib/notification.sh lib/orphan_packages.sh lib/packages_cache.sh lib/restart_services.sh lib/rpmnew_files.sh lib/tray.sh lib/update.sh %{buildroot}/usr/lib/dnf-updater/lib/
install -m 644 tray/__init__.py %{buildroot}/usr/lib/dnf-updater/tray/
install -m 644 tray/__main__.py %{buildroot}/usr/lib/dnf-updater/tray/
install -m 755 tray/tray.py %{buildroot}/usr/lib/dnf-updater/tray/
install -m 644 tray/dnf-updater-icon.png %{buildroot}/usr/lib/dnf-updater/tray/
install -m 644 tray/dnf-updater-icon.png %{buildroot}/usr/share/icons/hicolor/48x48/apps/dnf-updater.png
install -m 755 usr/bin/dnf-updater %{buildroot}/usr/bin/
install -m 755 usr/bin/dnf-updater-check %{buildroot}/usr/bin/
install -m 755 usr/bin/dnf-updater-upgrade %{buildroot}/usr/bin/
install -m 644 etc/xdg/autostart/dnf-updater-tray.desktop %{buildroot}/etc/xdg/autostart/
install -m 644 etc/xdg/applications/dnf-updater.desktop %{buildroot}/usr/share/applications/
install -m 644 usr/lib/systemd/user/dnf-updater-check.service %{buildroot}/usr/lib/systemd/user/
install -m 644 usr/lib/systemd/user/dnf-updater-check.timer %{buildroot}/usr/lib/systemd/user/
install -m 644 usr/lib/systemd/user/dnf-updater-autostart.service %{buildroot}/usr/lib/systemd/user/

%check
python3 -m py_compile tray/__init__.py tray/__main__.py tray/tray.py
bash -n lib/check.sh lib/common.sh lib/flatpak_unused_packages.sh lib/full_upgrade.sh lib/kernel_reboot.sh lib/list_packages.sh lib/notification.sh lib/orphan_packages.sh lib/packages_cache.sh lib/restart_services.sh lib/rpmnew_files.sh lib/tray.sh lib/update.sh

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
%attr(0440, root, root) %config(noreplace) /etc/sudoers.d/dnf-updater
/usr/bin/dnf-updater
/usr/bin/dnf-updater-check
/usr/bin/dnf-updater-upgrade
/usr/lib/dnf-updater/lib/
/usr/lib/dnf-updater/tray/
/usr/share/applications/dnf-updater.desktop
/etc/xdg/autostart/dnf-updater-tray.desktop
/usr/lib/systemd/user/dnf-updater-check.service
/usr/lib/systemd/user/dnf-updater-check.timer
/usr/lib/systemd/user/dnf-updater-autostart.service
/usr/share/icons/hicolor/48x48/apps/dnf-updater.png

%postun
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
