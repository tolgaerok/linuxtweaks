%global debug_package %{nil}

# systemd 248+ (RHEL 8 compatibility)
%if 0%{?rhel} == 8
%global _systemd_util_dir %{_prefix}/lib/systemd
%endif

Name:           linuxtweaks
Version:        6.1.69
Release:        1%{?dist}
Summary:       🛡️ Personal Fedora System Update Manager > 🫟  LinuxTweaks 2026 Tray Application
License:        MIT
URL:            https://github.com/tolgaerok/linuxtweaks
Source0:        %{name}-%{version}.tar.gz
Packager:       Tolga Erok <kingtolga@gmail.com>
Vendor:         🫟 LinuxTweaks 2026

BuildArch:      noarch
BuildRequires:  python3, systemd-rpm-macros
Requires:       python3-qt5, libnotify, flatpak, yad, zenity, dnf, fwupd

%{?systemd_requires}

%description
🫟 LinuxTweaks %{version} > My personal Fedora system update manager

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
%autosetup -n %{name}-%{version}
[ -d tray ] || { echo "ERROR: tray directory missing"; exit 1; }
[ -d lib ] || { echo "ERROR: lib directory missing"; exit 1; }
[ -d etc/xdg/autostart ] || { echo "ERROR: autostart directory missing"; exit 1; }

%check
python3 -m py_compile tray/*.py
python3 -m py_compile lib/config.py 2>/dev/null || true
bash -n lib/*.sh 2>/dev/null || true

%build
# No build required > pure Python and bash 😎

%install
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_libdir}/linuxtweaks/{lib,tray}
mkdir -p %{buildroot}%{_sysconfdir}/sudoers.d
mkdir -p %{buildroot}%{_sysconfdir}/xdg/autostart
mkdir -p %{buildroot}%{_userunitdir}
mkdir -p %{buildroot}%{_sysconfdir}/systemd/user-preset

# Install source files from tarball
install -m 644 etc/xdg/autostart/linuxtweaks.desktop %{buildroot}%{_sysconfdir}/xdg/autostart/
install -m 644 etc/sudoers.d/linuxtweaks %{buildroot}%{_sysconfdir}/sudoers.d/
install -m 644 etc/systemd/user-preset/50-linuxtweaks.preset %{buildroot}%{_sysconfdir}/systemd/user-preset/

install -m 755 lib/*.sh %{buildroot}%{_libdir}/linuxtweaks/lib/
install -m 755 tray/*.py %{buildroot}%{_libdir}/linuxtweaks/tray/
install -m 644 tray/*.png %{buildroot}%{_libdir}/linuxtweaks/tray/ 2>/dev/null || true

# Install wrapper scripts from tracked files
install -m 755 usr/bin/linuxtweaks %{buildroot}%{_bindir}/
install -m 755 usr/bin/linuxtweaks-autostart %{buildroot}%{_bindir}/
install -m 755 usr/bin/linuxtweaks-upgrade %{buildroot}%{_bindir}/
install -m 755 usr/bin/linuxtweaks-check %{buildroot}%{_bindir}/

# Install systemd service files from tracked files
install -m 644 usr/lib/systemd/user/linuxtweaks.timer %{buildroot}%{_userunitdir}/
install -m 644 usr/lib/systemd/user/linuxtweaks.service %{buildroot}%{_userunitdir}/
install -m 644 usr/lib/systemd/user/linuxtweaks-autostart.service %{buildroot}%{_userunitdir}/

%files
%license LICENSE
%doc README.md
%{_userunitdir}/linuxtweaks.timer
%{_userunitdir}/linuxtweaks.service
%{_userunitdir}/linuxtweaks-autostart.service
%{_bindir}/linuxtweaks-autostart
%{_bindir}/linuxtweaks
%{_bindir}/linuxtweaks-upgrade
%{_bindir}/linuxtweaks-check
%{_libdir}/linuxtweaks/
%{_sysconfdir}/sudoers.d/linuxtweaks
%{_sysconfdir}/xdg/autostart/linuxtweaks.desktop
%{_sysconfdir}/systemd/user-preset/50-linuxtweaks.preset

%post
%systemd_user_post linuxtweaks.timer linuxtweaks.service linuxtweaks-autostart.service

for user_home in /home/*; do
    if [ -d "$user_home" ]; then
        user=$(basename "$user_home")
        sudo -u "$user" systemctl --user daemon-reload 2>/dev/null || true
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
echo -e "${YELLOW}      🫟  LinuxTweaks${NC} ${BLUE}%{version}${NC} ${GREEN}installed!${NC}  🫟"
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
echo -e "${GREEN}😎 👉 Run: linuxtweaks${NC}"
echo ""

%preun
%systemd_user_preun linuxtweaks.timer linuxtweaks-autostart.service
systemctl --user daemon-reload 2>/dev/null || true

%postun
%systemd_user_postun linuxtweaks.timer linuxtweaks-autostart.service
pkill -9 -f "python3 -m tray" 2>/dev/null || true
pkill -9 -f "check.sh" 2>/dev/null || true

for home in /home/* /root; do
    [ -d "$home" ] && rm -rf "$home/.config/linuxtweaks" 2>/dev/null || true
    [ -d "$home" ] && rm -f "$home/.config/systemd/user/linuxtweaks.timer" 2>/dev/null || true
done

systemctl --user daemon-reload 2>/dev/null || true

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
echo -e "${YELLOW}  🫟  LinuxTweaks ${RED}REMOVED${NC} Thanks for using it!  🫟 ${NC}"
echo ""
echo -e "${BLUE} 👁️‍🗨️ Created by: Tolga Erok${NC}"
echo -e "${BLUE} 📧 Email:      kingtolga@gmail.com${NC}"
echo -e "${BLUE} 📡 GitHub:     https://github.com/tolgaerok/linuxtweaks${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

%changelog
* Thu Sep 10 2026 Tolga Erok <kingtolga@gmail.com> - 6.1.68-1
- FIXED: settings_dialog.py timer interval save (mkdir, shutil.copy, proper error handling)
- FIXED: User timer directory creation (~/.config/systemd/user/) on first interval change
- IMPROVED: Python files now have proper shebangs (#!/usr/bin/python3) and UTF-8 encoding declarations
- IMPROVED: Wrapper script auto-starts services on app launch (systemctl --user start)
- IMPROVED: Settings dialog now correctly copies/modifies system timer to user config
- IMPROVED: Timer interval changes now immediately reload systemd (daemon-reload + restart)

* Wed Sep 09 2026 Tolga Erok <kingtolga@gmail.com> - 6.1.64-1
- REFACTOR: Professional RPM structure (tracked files, no heredocs)
- IMPROVED: Clean spec file with service files as tracked files
- IMPROVED: Automated build/sign/deploy pipeline with verification
- FIXED: %systemd_user_post macro for proper service enablement

* Mon Sep 07 2026 Tolga Erok <kingtolga@gmail.com> - 6.1.53-1
- FIXED: Duplicate tray instances > disabled _ensure_services_enabled() in __init__.py
- FIXED: Wrapper now checks if tray is already running before starting
- FIXED: Process detection pattern corrected to "python3 -m tray" for accuracy
- IMPROVED: upgrade.sh now restarts tray cleanly without duplicates
- IMPROVED: Single instance protection prevents multiple tray icons in system tray
- IMPROVED: Upgrade process is now atomic > kills old, starts new, no overlap

* Sun Sep 06 2026 Tolga Erok <kingtolga@gmail.com> - 6.1.31-1
- PRODUCTION RELEASE: Full path migration from lib64 to lib, all systems verified ✅
- FIXED: Corrected check.sh path from /usr/lib64 to /usr/lib (checks now fire)
- FIXED: All hardcoded icon paths updated from /usr/lib64 to /usr/lib
- FIXED: Settings dialog countdown timer now restarts when dialog is reopened
- FIXED: upgrade.sh now uses wrapper /usr/bin/linuxtweaks instead of direct path
- IMPROVED: Removed all debug print statements (production clean)

* Sat Sep 05 2026 Tolga Erok <kingtolga@gmail.com> - 6.1.20-1
- CRITICAL: Distroboxes not updating, added separate menu item, temporary fix
- FIXED: App crash loop > removed self-killing code from initialization
- FIXED: Autostart service now uses Restart=no for clean exit handling

* Fri Sep 04 2026 Tolga Erok <kingtolga@gmail.com> - 6.0.8-1
- CRITICAL FIXED: corrected flatpak detection!

* Thu Sep 03 2026 Tolga Erok <kingtolga@gmail.com> - 6.0.7-1
- MAJOR: Nordic color theme applied to all Python UI components
- FIXED: Timer now uses correct intervals (30s boot, 30min check, 5s random delay)

* Wed Sep 02 2026 Tolga Erok <kingtolga@gmail.com> - 6.0.6-1
- MAJOR: Upgrade and Check scripts bugfixes
- FIXED: Settings dialog countdown timer now syncs with systemd timer

* Fri Aug 28 2026 Tolga Erok <kingtolga@gmail.com> - 6.0.1-1
- MAJOR: System-wide RPM deployment (/usr/lib64/linuxtweaks)
- MAJOR: Systemd user timer (OnUnitActiveSec=1min, Persistent=true)
- Works flawlessly on Fedora KDE Plasma

* Wed Aug 26 2026 Tolga Erok <kingtolga@gmail.com> - 5.0.1-1
- Immediate Auto-Refresh Update after upgrade

* Tue Aug 25 2026 Tolga Erok <kingtolga@gmail.com> - 5.0.0-1
- Initial v5.0 release
- PyQt5 system tray application
