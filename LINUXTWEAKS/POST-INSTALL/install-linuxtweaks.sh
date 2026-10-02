#!/usr/bin/bash
# 👁️‍🗨️ Created by: Tolga Erok
# 📧 Email:      kingtolga@gmail.com
# 📡 GitHub:     https://github.com/tolgaerok/linuxtweaks
# SPDX-License-Identifier: GPL-3.0-or-later

# one script for my LinuxTweaks Updater. it installs it, updates it, checks
# it, clears out what my old 6.x app left behind, removes it, and can fill
# the tray with fake updates so you can see how it looks.
#
#   bash install-linuxtweaks.sh               install it, or update it
#   bash install-linuxtweaks.sh --check       only look, changes nothing
#   bash install-linuxtweaks.sh --cleanup     only clear out old 6.x leftovers
#   bash install-linuxtweaks.sh --remove      uninstall it
#   bash install-linuxtweaks.sh --fake 3 20   3 dnf + 20 flatpak fake updates in the tray
#   bash install-linuxtweaks.sh --restore     put the real update list back
#
# what it never does: update the rest of your system, add sudo rules, or
# delete anything without showing you first and asking.

BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PACKAGE="linuxtweaks-updater"
REPO_URL="http://100.83.30.114:8080/linuxtweaks"
REPO_FILE="/etc/yum.repos.d/linuxtweaks.repo"
IO_REPO_FILE="/etc/yum.repos.d/linuxtweaks-io.repo"
KEY_ID="F75286EAE1540626"
TRAY_PATTERN="^python3 /usr/lib/${PACKAGE}/tray/tray.py"
STATE="${HOME}/.local/state/${PACKAGE}"
BACKUP="${STATE}/fake-test-backup"

header() {
	echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
	echo -e "${CYAN}  $*${NC}"
	echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}
step() { echo -e "\n${CYAN}▶${NC} ${BLUE}$*${NC}"; }
ok() { echo -e "  ${GREEN}✓${NC} $*"; }
note() { echo -e "  ${YELLOW}•${NC} $*"; }
bad() { echo -e "  ${RED}✗${NC} $*"; }

# ask a yes/no question. works with curl | bash too, the answer comes from
# your keyboard, not the pipe. no keyboard at all? the answer is no
ask() {
	local reply
	[ -r /dev/tty ] || return 1
	read -r -p "  $1 [y/N] " reply </dev/tty || return 1
	[[ $reply =~ ^[Yy] ]]
}

# ---- old 6.x leftovers ------------------------------------------------------

# my old app lived in your home folder and had its own timers, they can keep
# starting the old tray next to the new one. exact old names only, never
# anything called linuxtweaks-updater
OLD_UNITS="linuxtweaks.timer linuxtweaks.service linuxtweaks-autostart.service app-linuxtweaks@autostart.service"
OLD_SYSTEM_PATHS="/usr/lib/linuxtweaks /usr/lib64/linuxtweaks /usr/local/share/linuxtweaks
/usr/local/lib/linuxtweaks /usr/local/bin/linuxtweaks /usr/local/bin/linuxtweaks-check
/usr/local/bin/linuxtweaks-upgrade /usr/local/bin/linuxtweaks-autostart
/etc/sudoers.d/linuxtweaks /etc/xdg/autostart/linuxtweaks.desktop
/usr/lib/systemd/user/linuxtweaks.timer /usr/lib/systemd/user/linuxtweaks.service
/usr/lib/systemd/user/linuxtweaks-autostart.service"

OLD_HOME=()
OLD_SYSTEM=()
OLD_PIDS=()

find_old() {
	OLD_HOME=()
	OLD_SYSTEM=()
	OLD_PIDS=()
	local p u f

	for u in $OLD_UNITS; do
		for p in "$HOME/.config/systemd/user/$u" "$HOME"/.config/systemd/user/*.wants/"$u"; do
			[ -e "$p" ] || [ -L "$p" ] && OLD_HOME+=("$p")
		done
	done
	for f in autostart/linuxtweaks.desktop autostart/linuxtweaks-tray.desktop \
		autostart/linuxtweaks-autostart.desktop linuxtweaks; do
		[ -e "$HOME/.config/$f" ] && OLD_HOME+=("$HOME/.config/$f")
	done
	for p in "$HOME/.local/lib/linuxtweaks" "$HOME/.local/share/linuxtweaks" \
		"$HOME/.local/share/applications/linuxtweaks.desktop" "$HOME/.cache/linuxtweaks"; do
		[ -e "$p" ] && OLD_HOME+=("$p")
	done
	for f in linuxtweaks linuxtweaks-autostart linuxtweaks-check linuxtweaks-upgrade linuxtweaks-tray; do
		[ -e "$HOME/.local/bin/$f" ] || [ -L "$HOME/.local/bin/$f" ] && OLD_HOME+=("$HOME/.local/bin/$f")
	done

	# system files, but only the ones no installed package owns
	for p in $OLD_SYSTEM_PATHS /etc/systemd/user/*.wants/linuxtweaks.timer \
		/etc/systemd/user/*.wants/linuxtweaks-autostart.service; do
		[ -e "$p" ] || [ -L "$p" ] || continue
		rpm -qf "$p" >/dev/null 2>&1 || OLD_SYSTEM+=("$p")
	done

	# the old tray still running. it ran as "python3 -m tray" from its own
	# folder, so I only count it when that folder is a linuxtweaks one
	for p in $(pgrep -u "$(id -u)" -f 'python3 -m tray|/linuxtweaks/tray/|/linuxtweaks/lib/check.sh' 2>/dev/null); do
		tr '\0' ' ' <"/proc/$p/cmdline" 2>/dev/null | grep -q "$PACKAGE" && continue
		if tr '\0' ' ' <"/proc/$p/cmdline" 2>/dev/null | grep -q '/linuxtweaks/' ||
			readlink "/proc/$p/cwd" 2>/dev/null | grep -q '/linuxtweaks'; then
			OLD_PIDS+=("$p")
		fi
	done
}

show_old() {
	local p
	for p in "${OLD_PIDS[@]}"; do note "old tray running, pid $p"; done
	for p in "${OLD_HOME[@]}"; do note "$p"; done
	for p in "${OLD_SYSTEM[@]}"; do note "$p (no package owns it)"; done
}

old_count() { echo $((${#OLD_HOME[@]} + ${#OLD_SYSTEM[@]} + ${#OLD_PIDS[@]})); }

remove_old() {
	[ ${#OLD_PIDS[@]} -gt 0 ] && kill "${OLD_PIDS[@]}" 2>/dev/null
	systemctl --user disable --now $OLD_UNITS >/dev/null 2>&1
	[ ${#OLD_HOME[@]} -gt 0 ] && rm -rf "${OLD_HOME[@]}"
	[ ${#OLD_SYSTEM[@]} -gt 0 ] && sudo rm -rf "${OLD_SYSTEM[@]}"
	systemctl --user daemon-reload 2>/dev/null
	systemctl --user reset-failed 2>/dev/null
	ok "removed $(old_count) old leftover(s)"
}

# look, show, ask, then clean
cleanup_old() {
	step "Old LinuxTweaks 6.x leftovers"
	find_old
	if [ "$(old_count)" -eq 0 ]; then
		ok "none found"
		return
	fi
	echo "  These are from my old app and can start it next to the new one:"
	show_old
	if ask "Remove them?"; then
		remove_old
	else
		note "left them alone. run this again with --cleanup when you want them gone"
	fi
}

# ---- status -----------------------------------------------------------------

repo_reachable() {
	curl -fsS -m 10 -o /dev/null "${REPO_URL}/repodata/repomd.xml" 2>/dev/null
}

tray_running() { pgrep -u "$(id -u)" -f "$TRAY_PATTERN" >/dev/null; }

status() {
	step "My repo"
	if repo_reachable; then ok "reachable at ${REPO_URL}"; else bad "can't reach ${REPO_URL}"; fi
	if [ -f "$REPO_FILE" ]; then
		if grep -q '^gpgcheck=1' "$REPO_FILE"; then ok "$REPO_FILE checks my signature"; else bad "$REPO_FILE doesn't check my signature, run the install again to fix it"; fi
	else
		note "$REPO_FILE isn't there yet"
	fi
	if [ -f "$IO_REPO_FILE" ] && grep -q '^gpgcheck=0' "$IO_REPO_FILE"; then
		note "$IO_REPO_FILE doesn't check signatures, the install switches that on"
	fi

	step "LinuxTweaks Updater"
	if rpm -q "$PACKAGE" >/dev/null 2>&1; then
		ok "installed: $(rpm -q "$PACKAGE")"
	else
		note "not installed"
		return
	fi
	if tray_running; then ok "tray running"; else note "tray not running, start it with: linuxtweaks-updater"; fi
	if systemctl --user is-enabled linuxtweaks-updater-check.timer >/dev/null 2>&1; then
		ok "update check timer is on"
	else
		note "update check timer switches on the first time the tray starts"
	fi
	if systemctl is-enabled linuxtweaks-updater-maintenance.timer >/dev/null 2>&1; then
		ok "weekly maintenance is on"
	else
		note "weekly maintenance is off. switch it on in the tray menu if you want it"
	fi
	if [ -e /etc/sudoers.d/linuxtweaks-updater ]; then
		bad "/etc/sudoers.d/linuxtweaks-updater is still there. versions before 7.4.0 had it, update to get rid of it"
	else
		ok "no sudo rules from me"
	fi
}

# ---- install / update -------------------------------------------------------

install() {
	header "🫟  LinuxTweaks Updater install"

	step "Can I reach my repo?"
	if ! repo_reachable; then
		bad "no answer from ${REPO_URL}"
		echo "  My repo runs on my own server over Tailscale."
		# say which bit is missing, not just "it failed"
		if ! command -v tailscale >/dev/null 2>&1; then
			echo "  Tailscale isn't installed here. The README shows how, it takes 5 minutes."
		elif ! tailscale status >/dev/null 2>&1; then
			echo "  Tailscale is installed but not connected. Run: sudo tailscale up"
		else
			echo "  You're on Tailscale but my server isn't shared with you yet. Send me"
			echo "  the email you log in to Tailscale with and I'll share it."
		fi
		echo "  Nothing was changed."
		exit 1
	fi
	ok "yes"

	step "Repo file"
	# always written fresh, older copies didn't check the signature
	sudo tee "$REPO_FILE" >/dev/null <<EOF
[linuxtweaks]
name=LinuxTweaks Repository
baseurl=${REPO_URL}/
enabled=1
gpgcheck=1
gpgkey=${REPO_URL}/RPM-GPG-KEY
# check for new uploads at least hourly
metadata_expire=1h
EOF
	ok "$REPO_FILE written, packages must carry my signature"
	# linuxtweaks-io is signed with the same key, so it can check too
	if [ -f "$IO_REPO_FILE" ] && grep -q '^gpgcheck=0' "$IO_REPO_FILE"; then
		sudo sed -i "s|^gpgcheck=0|gpgcheck=1\ngpgkey=${REPO_URL}/RPM-GPG-KEY|" "$IO_REPO_FILE"
		ok "$IO_REPO_FILE now checks my signature too"
	fi

	# my old 6.x app. the new package replaces it in the same dnf step,
	# this only stops it running first
	if rpm -q linuxtweaks >/dev/null 2>&1 && [ "$(rpm -q --qf '%{NAME}' linuxtweaks)" = linuxtweaks ]; then
		step "Old LinuxTweaks 6.x"
		systemctl --user stop $OLD_UNITS >/dev/null 2>&1
		systemctl --user disable $OLD_UNITS >/dev/null 2>&1
		ok "stopped, dnf swaps it for the new one next"
	fi
	cleanup_old

	step "Installing"
	echo "  dnf may ask to import my signing key. Its ID is ${KEY_ID}."
	local was=""
	rpm -q "$PACKAGE" >/dev/null 2>&1 && was=$(rpm -q --qf '%{VERSION}' "$PACKAGE")
	if [ -n "$was" ]; then
		# only my package, the rest of your system is your call
		sudo dnf upgrade --refresh -y "$PACKAGE" || { bad "dnf couldn't update it"; exit 1; }
	else
		sudo dnf install --refresh -y "$PACKAGE" || { bad "dnf couldn't install it"; exit 1; }
	fi
	local now
	now=$(rpm -q --qf '%{VERSION}' "$PACKAGE")
	if [ -z "$was" ]; then
		ok "installed ${now}"
	elif [ "$was" = "$now" ]; then
		ok "already on the latest, ${now}"
	else
		ok "updated ${was} to ${now}"
	fi

	step "Tray"
	if [ -z "${DISPLAY}${WAYLAND_DISPLAY}" ]; then
		note "no desktop here, the tray starts by itself next time you log in"
	else
		if tray_running && [ -n "$was" ] && [ "$was" != "$now" ]; then
			# still running the old code, swap it for the new
			pkill -TERM -u "$(id -u)" -f "$TRAY_PATTERN"
			sleep 2
		fi
		linuxtweaks-updater >/dev/null 2>&1
		sleep 3
		if tray_running; then ok "running, look for the icon"; else bad "didn't start, try: linuxtweaks-updater --foreground"; fi
	fi

	status

	echo ""
	header "✅ LinuxTweaks Updater ${now} is ready"
	echo "  • Right click the tray icon for the menu. Help is under About."
	echo "  • It checks every 30 minutes and starts by itself when you log in."
	echo "  • Click a package in the DNF list to see what changed in it. A 🔴"
	echo "    means it's a security fix."
	echo "  • Weekly maintenance is off until you switch it on in the menu."
	echo "  • New versions come with a normal: sudo dnf upgrade"
	echo ""
}

# ---- remove -----------------------------------------------------------------

remove() {
	header "🫟  LinuxTweaks Updater remove"
	if ! rpm -q "$PACKAGE" >/dev/null 2>&1; then
		ok "not installed, nothing to do"
	else
		echo "  This removes the app, its timers and its settings for every user"
		echo "  on this PC. Your packages and updates stay as they are."
		if ask "Remove LinuxTweaks Updater?"; then
			sudo dnf remove -y "$PACKAGE" && ok "removed"
		else
			note "kept it"
			exit 0
		fi
	fi
	if [ -f "$REPO_FILE" ] && ask "Remove my repo file too ($REPO_FILE)?"; then
		sudo rm -f "$REPO_FILE" && ok "repo file removed"
	fi
}

# ---- fake updates for testing the tray ----------------------------------------

# the tray only notices a file that's replaced, not one edited in place, so
# everything here is written next to it and moved over
put() { cat >"$STATE/.$1.new" && mv -f "$STATE/.$1.new" "$STATE/$1"; }

FAKE_FILES="last_updates_check_packages last_updates_check_flatpak last_updates_check_security current_updates_check"

fake() {
	local dnf_count="${1:-1}" flatpak_count="${2:-500}" i f
	[ -d "$STATE" ] || { bad "the tray hasn't run here yet, start it first: linuxtweaks-updater"; exit 1; }
	# back up the real lists once, a second run mustn't back up the fakes
	if [ ! -d "$BACKUP" ]; then
		mkdir -p "$BACKUP"
		for f in $FAKE_FILES; do [ -f "$STATE/$f" ] && cp "$STATE/$f" "$BACKUP/$f"; done
	fi
	for i in $(seq 1 "$dnf_count"); do echo "fake-package-${i}: 1.0.0-1 → 1.0.1-1"; done | put last_updates_check_packages
	for i in $(seq 1 "$flatpak_count"); do
		printf 'Fake App %d\torg.linuxtweaks.FakeApp%d\t1.0.%d\tstable\tx86_64\tflathub\n' "$i" "$i" "$i"
	done | put last_updates_check_flatpak
	# the first fake package is a pretend security fix, so you see the 🔴 too
	if [ "$dnf_count" -gt 0 ]; then
		printf 'fake-package-1\tImportant\tFAKE-0001\n' | put last_updates_check_security
	else
		: | put last_updates_check_security
	fi
	echo $((dnf_count + flatpak_count)) | put current_updates_check
	ok "fake updates in the tray: ${dnf_count} dnf + ${flatpak_count} flatpak"
	echo "  Hover the icon and right click it to see how they look."
	echo -e "  ${YELLOW}Don't press Install${NC}, that runs a real update."
	echo "  The next check puts the real list back anyway, or run this with --restore"
}

restore() {
	local f
	[ -d "$BACKUP" ] || { ok "no fake test running, nothing to restore"; exit 0; }
	for f in $FAKE_FILES; do
		if [ -f "$BACKUP/$f" ]; then put "$f" <"$BACKUP/$f"; else : | put "$f"; fi
	done
	rm -rf "$BACKUP"
	ok "real update list is back"
}

# ---- go -----------------------------------------------------------------------

case "$1" in
"") install ;;
--check)
	header "🫟  LinuxTweaks Updater check (only looking)"
	status
	step "Old LinuxTweaks 6.x leftovers"
	find_old
	if [ "$(old_count)" -eq 0 ]; then ok "none found"; else show_old; echo "  Remove them with: bash install-linuxtweaks.sh --cleanup"; fi
	echo ""
	;;
--cleanup) cleanup_old ;;
--remove) remove ;;
--fake) fake "$2" "$3" ;;
--restore) restore ;;
*)
	# $0 is just "bash" when this comes through curl, so the list lives here
	echo "  bash install-linuxtweaks.sh               install it, or update it"
	echo "  bash install-linuxtweaks.sh --check       only look, changes nothing"
	echo "  bash install-linuxtweaks.sh --cleanup     only clear out old 6.x leftovers"
	echo "  bash install-linuxtweaks.sh --remove      uninstall it"
	echo "  bash install-linuxtweaks.sh --fake 3 20   3 dnf + 20 flatpak fake updates in the tray"
	echo "  bash install-linuxtweaks.sh --restore     put the real update list back"
	exit 1
	;;
esac
