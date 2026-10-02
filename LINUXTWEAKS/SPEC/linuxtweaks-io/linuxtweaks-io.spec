%global debug_package %{nil}

Name:           linuxtweaks-io
Version: 1.1.42
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
# the password box for changing a scheduler
Requires:       polkit
# the uninstall cleanup
Requires(preun): bash
Requires(preun): procps-ng

BuildArch:      noarch

%description
My I/O scheduler app for Fedora. It shows every drive with the scheduler
it uses right now, explains what each scheduler is good at, and changes it
with a click. It asks for your password to change it and writes a udev rule
so your pick stays after a reboot.

It only offers the schedulers your kernel really has: none, mq-deadline,
kyber and bfq, plus adios on a CachyOS kernel.

It sits in the tray and keeps a log of what it changed. It doesn't start
by itself at login, start it from the app menu when you want it.

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
install -m 0644 tray/theme.py %{buildroot}%{_usr}/lib/linuxtweaks-io/tray/
install -m 0644 tray/log_dialog.py %{buildroot}%{_usr}/lib/linuxtweaks-io/tray/
install -m 0644 tray/about_dialog.py %{buildroot}%{_usr}/lib/linuxtweaks-io/tray/
install -m 0644 tray/utils.py %{buildroot}%{_usr}/lib/linuxtweaks-io/tray/
install -m 0644 tray/linuxtweaks-io-icon.png %{buildroot}%{_usr}/lib/linuxtweaks-io/tray/

# Install the uninstall cleanup
install -d %{buildroot}%{_usr}/lib/linuxtweaks-io/bin
install -m 0755 bin/cleanup.sh %{buildroot}%{_usr}/lib/linuxtweaks-io/bin/
# the one thing that runs as root, and the polkit rule that says so nicely
install -m 0755 bin/set-scheduler %{buildroot}%{_usr}/lib/linuxtweaks-io/bin/
install -d %{buildroot}%{_datadir}/polkit-1/actions
install -m 0644 usr/share/polkit-1/actions/org.linuxtweaks.io.policy %{buildroot}%{_datadir}/polkit-1/actions/

# Install executable wrapper
install -d %{buildroot}%{_usr}/bin
install -m 0755 usr/bin/linuxtweaks-io %{buildroot}%{_usr}/bin/

# Install desktop entry
install -d %{buildroot}%{_datadir}/applications
install -m 0644 usr/share/applications/linuxtweaks-io.desktop %{buildroot}%{_datadir}/applications/

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
%{_datadir}/polkit-1/actions/org.linuxtweaks.io.policy

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
echo -e "${BLUE} 📡 GitHub:     https://github.com/tolgaerok/linuxtweaks${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}✓ Change your I/O schedulers with a click${NC}"
echo -e "${YELLOW}✓ Your picks stay after a reboot (udev rule)${NC}"
echo -e "${YELLOW}✓ Start it from the app menu${NC}"
echo ""
echo -e "${GREEN}😎 👉 Run: linuxtweaks-io${NC}"
echo ""

# $1 = how many copies are left after this: 0 = real uninstall, 1+ = upgrade.
# only a real uninstall cleans up, an upgrade keeps your picks and the rule
%preun
if [ "$1" -eq 0 ]; then
	%{_usr}/lib/linuxtweaks-io/bin/cleanup.sh || :
fi

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
echo -e "${BLUE} 📡 GitHub:     https://github.com/tolgaerok/linuxtweaks${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

%changelog
* Fri Oct 02 2026 Tolga Erok <kingtolga@gmail.com> - 1.1.42-1
- No more "Wayland does not support QWindow::requestActivate()" in the
  terminal when the window comes to the front. On Wayland KWin decides
  who gets focus, so I don't ask any more
- Started from a terminal I let go of it now, so closing the terminal
  doesn't close me too
- Started from a folder with its own tray folder in it, like my updater's
  project, I used to launch LinuxTweaks Updater instead of me. I always
  start from my own folder now
- Scrolling the drive list over a dropdown changed that drive's scheduler
  and popped a password box. The dropdowns ignore the scroll wheel now
- One password box per change instead of two, and it says what it's for
  in plain words instead of a line of shell code. Change a few drives in a
  row and it only asks once. A small helper does the root part and only
  takes a real drive and a scheduler that drive has

* Fri Oct 02 2026 Tolga Erok <kingtolga@gmail.com> - 1.1.41-1
- Cancelling the password box crashed the whole app, it doesn't now. You
  get a message and the list shows what the drive really uses
- Saving the rule and reloading udev is one step with one password box.
  The reload used to run through sudo with nowhere to ask and failed quietly
- Only ever one of me. Start me again and the open one comes to the front,
  no lock file that can go stale
- Uninstalling cleans up properly now: the tray closes for every user, and
  everybody's picks, log and any autostart entry go too. The udev rule
  stays, your drives keep the schedulers you picked
- Took out the claims that weren't true: no autostart, and no noop,
  deadline or CFQ, modern kernels dropped those years ago
- The GitHub link pointed at a page that doesn't exist
- Binned the leftover systemd service code, udev does that job
- Bigger window, 890 by 486
- Your picks belong to the drive now, not its name. I save them against the
  drive's serial number, so if Linux swaps sda and sdb at boot your pick
  still lands on the right drive. Old picks switch over the next time you
  change any drive. A lock on the card shows a drive has a saved pick
- An About window, same cards as LinuxTweaks Updater: what I do, how I keep
  your picks, which scheduler for which drive and where I keep things
- Same look as LinuxTweaks Updater. Every drive gets its own card with its
  model, size, the scheduler it uses and what that means. Scheduler info and
  the log use the same cards and headline

* Mon Sep 14 2026 Tolga Erok <tolga@example.com> - 1.1.30-1
- I/O scheduler management with udev persistence
- Modern dark theme with cyan accents
- Icon in window header (80x80)
- Tray icon tooltip with version
- Removed systemd services (udev handles persistence)
