%global debug_package %{nil}

Name:           linuxtweaks-io
Version: 1.1.40
Release:        1%{?dist}
Summary:        🛠️ Personal fedora I/O Scheduler Manager >> Manage kernel I/O schedulers with GUI

License:        MIT
URL:            https://github.com/tolgaerok/linuxtweaks
Source:         %{name}-%{version}.tar.gz

BuildRequires:  python3-devel
Requires:       python3
Requires:       python3-PyQt5
Requires:       python3-dbus
Requires:       kernel

BuildArch:      noarch

%description
LinuxTweaks-IO is a professional system tray application for managing Linux kernel I/O schedulers in real-time. It provides a modern GUI to view, monitor, and change I/O schedulers for block devices (NVMe, SSD, HDD, optical drives).

Features:
- Real-time scheduler detection and monitoring
- Change schedulers per-device with pkexec authentication
- Udev rules for automatic persistence across reboots
- System tray integration with quick access menu
- Dark mode with cyan accent theme
- Device information and scheduler details
- Activity logging and debugging tools
- Lightweight PyQt5 interface

Supported schedulers: none, noop, mq-deadline, kyber, bfq, deadline, CFQ

 👁️‍🗨️ Created by: Tolga Erok
 📧 Email:      kingtolga@gmail.com
 📡 GitHub:     https://github.com/tolgaerok/linuxtweaks

%prep
%setup -q

%build
python3 -m py_compile tray/*.py

%install
# Install tray application
install -d %{buildroot}%{_usr}/lib/linuxtweaks-io/tray
install -m 0644 tray/__init__.py %{buildroot}%{_usr}/lib/linuxtweaks-io/tray/
install -m 0644 tray/__main__.py %{buildroot}%{_usr}/lib/linuxtweaks-io/tray/
install -m 0644 tray/app.py %{buildroot}%{_usr}/lib/linuxtweaks-io/tray/
install -m 0644 tray/check_theme.py %{buildroot}%{_usr}/lib/linuxtweaks-io/tray/
install -m 0644 tray/log_dialog.py %{buildroot}%{_usr}/lib/linuxtweaks-io/tray/
install -m 0644 tray/utils.py %{buildroot}%{_usr}/lib/linuxtweaks-io/tray/
install -m 0644 tray/linuxtweaks-io-icon.png %{buildroot}%{_usr}/lib/linuxtweaks-io/tray/

# Install executable wrapper
install -d %{buildroot}%{_usr}/bin
install -m 0755 usr/bin/linuxtweaks-io %{buildroot}%{_usr}/bin/

# Install desktop entry
install -d %{buildroot}%{_datadir}/applications
install -m 0644 etc/xdg/autostart/linuxtweaks-io.desktop %{buildroot}%{_datadir}/applications/

# Install icon
install -d %{buildroot}%{_datadir}/icons/hicolor/48x48/apps
install -m 0644 lib/icon-scheduler.png %{buildroot}%{_datadir}/icons/hicolor/48x48/apps/linuxtweaks-io.png

%files
%license LICENSE
%doc README.md
%{_usr}/bin/linuxtweaks-io
%{_usr}/lib/linuxtweaks-io/
%{_datadir}/applications/linuxtweaks-io.desktop
%{_datadir}/icons/hicolor/48x48/apps/linuxtweaks-io.png

%post
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
echo -e "${YELLOW}      🫟  LinuxTweaks-IO ${GREEN}%{version}${YELLOW} installed!${NC}  🫟"
echo ""
echo -e "${BLUE} 👁️‍🗨️ Created by: Tolga Erok${NC}"
echo -e "${BLUE} 📧 Email:      kingtolga@gmail.com${NC}"
echo -e "${BLUE} 📡 GitHub:     https://github.com/tolgaerok/linuxtweaks-io${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}✓ Manage I/O schedulers in real-time${NC}"
echo -e "${YELLOW}✓ Autostart on login${NC}"
echo -e "${YELLOW}✓ Udev persistence across reboots${NC}"
echo ""
echo -e "${GREEN}😎 👉 Run: linuxtweaks-io${NC}"
echo ""

%postun
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
echo -e "${YELLOW}  🫟  LinuxTweaks-IO ${RED}REMOVED${NC} Thanks for using it!  🫟${NC}"
echo ""
echo -e "${BLUE} 👁️‍🗨️ Created by: Tolga Erok${NC}"
echo -e "${BLUE} 📧 Email:      kingtolga@gmail.com${NC}"
echo -e "${BLUE} 📡 GitHub:     https://github.com/tolgaerok/linuxtweaks-io${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

%changelog
* Mon Sep 14 2026 Tolga Erok <tolga@example.com> - 1.1.30-1
- I/O scheduler management with udev persistence
- Modern dark theme with cyan accents
- Icon in window header (80x80)
- Tray icon tooltip with version
- Removed systemd services (udev handles persistence)
