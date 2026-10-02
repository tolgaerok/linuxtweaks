#!/usr/bin/bash
# 👁️‍🗨️ Created by: Tolga Erok
# 📧 Email:      kingtolga@gmail.com
# 📡 GitHub:     https://github.com/tolgaerok/linuxtweaks
# SPDX-License-Identifier: GPL-3.0-or-later

# one script for my LinuxTweaks Updater. it installs it, updates it, checks
# it, clears out what my older apps left behind (dnf-updater, then
# linuxtweaks-dnf-updater, then LinuxTweaks 6.x), removes it, and can fill
# the tray with fake updates so you can see how it looks.
#
#   bash install-linuxtweaks.sh               install it, or update it
#   bash install-linuxtweaks.sh --check       only look, changes nothing
#   bash install-linuxtweaks.sh --cleanup     only clear out what my older apps left behind
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
has_tty() { { : </dev/tty; } 2>/dev/null; }
ask() {
	local reply
	has_tty || return 1
	read -r -p "  $1 [y/N] " reply </dev/tty || return 1
	[[ $reply =~ ^[Yy] ]]
}

# ---- old leftovers ------------------------------------------------------------

# everything my older apps left behind. it had three names over the years:
# dnf-updater, then linuxtweaks-dnf-updater, then LinuxTweaks 6.x (linuxtweaks).
# before those, some PCs got hand made bits from me: a tray and resume unit,
# and timers to clear out flatpak runtimes and podman images.
# exact names only. linuxtweaks* would also hit linuxtweaks-updater, so the 6.x
# ones are spelled out

OLD_PACKAGES="dnf-updater linuxtweaks-dnf-updater linuxtweaks"

# in your home folder. the * patterns fill in right here, anything that
# isn't there stays as text and gets skipped below
OLD_HOME_GLOBS=(
	"$HOME"/.config/systemd/user/{linuxtweaks.timer,linuxtweaks.service,linuxtweaks-autostart.service,app-linuxtweaks@autostart.service}
	"$HOME"/.config/systemd/user/*.wants/{linuxtweaks.timer,linuxtweaks.service,linuxtweaks-autostart.service,app-linuxtweaks@autostart.service}
	"$HOME"/.config/systemd/user/{dnf-updater-,linuxtweaks-dnf-updater-}*
	"$HOME"/.config/systemd/user/{linuxtweaks-tray.service,linuxtweaks-resume.service}
	"$HOME"/.config/systemd/user/*.wants/{linuxtweaks-tray.service,linuxtweaks-resume.service}
	"$HOME"/.config/systemd/user/*.wants/{dnf-updater-,linuxtweaks-dnf-updater-}*
	"$HOME"/.config/autostart/{linuxtweaks,linuxtweaks-tray,linuxtweaks-autostart,dnf-updater-tray,linuxtweaks-dnf-updater-tray}.desktop
	"$HOME"/.config/{linuxtweaks,dnf-updater,linuxtweaks-dnf-updater}
	"$HOME"/.local/state/{linuxtweaks,dnf-updater,linuxtweaks-dnf-updater}
	"$HOME"/.cache/{linuxtweaks,dnf-updater,linuxtweaks-dnf-updater}
	"$HOME"/.local/lib/linuxtweaks
	"$HOME"/.local/share/linuxtweaks
	"$HOME"/.local/bin/{linuxtweaks,linuxtweaks-autostart,linuxtweaks-check,linuxtweaks-upgrade,linuxtweaks-tray}
	"$HOME"/.local/bin/{dnf-updater,linuxtweaks-dnf-updater}*
	"$HOME"/.local/share/applications/{linuxtweaks,dnf-updater,linuxtweaks-dnf-updater}.desktop
	"$HOME"/.local/share/systemd/timers/stamp-{linuxtweaks.timer,linuxtweaks-autostart.service}
	"$HOME"/.local/share/systemd/timers/stamp-{dnf-updater-,linuxtweaks-dnf-updater-}*
)

# on the system, only taken when no installed package owns it
OLD_SYSTEM_GLOBS=(
	/usr/{lib,lib64}/{linuxtweaks,dnf-updater,linuxtweaks-dnf-updater}
	/usr/{lib,lib64}/systemd/user/{linuxtweaks.timer,linuxtweaks.service,linuxtweaks-autostart.service}
	/usr/{lib,lib64}/systemd/user/{dnf-updater-,linuxtweaks-dnf-updater-}*
	/usr/{lib,lib64}/systemd/user/{linuxtweaks-tray.service,linuxtweaks-resume.service}
	/etc/systemd/system/{linuxtweaks-flatpak-cleanup,linuxtweaks-podman-prune}.{service,timer}
	/etc/systemd/system/*.wants/{linuxtweaks-flatpak-cleanup,linuxtweaks-podman-prune}.timer
	/usr/local/{share,lib}/{linuxtweaks,dnf-updater,linuxtweaks-dnf-updater}
	/usr/{,local/}bin/{linuxtweaks,linuxtweaks-autostart,linuxtweaks-check,linuxtweaks-upgrade}
	/usr/{,local/}bin/{dnf-updater,linuxtweaks-dnf-updater}*
	/usr/share/applications/{linuxtweaks,dnf-updater,linuxtweaks-dnf-updater}.desktop
	/usr/share/icons/hicolor/*/apps/{dnf-updater,linuxtweaks-dnf-updater}.png
	/etc/xdg/autostart/{linuxtweaks,dnf-updater-tray,linuxtweaks-dnf-updater-tray}.desktop
	/etc/systemd/user-preset/50-linuxtweaks.preset
	/etc/systemd/user/*.wants/{linuxtweaks.timer,linuxtweaks-autostart.service}
	/etc/systemd/user/*.wants/{dnf-updater-,linuxtweaks-dnf-updater-}*
)

OLD_PKGS=()
OLD_HOME=()
OLD_SYSTEM=()
OLD_SUDOERS=()
OLD_PIDS=()
SUDOERS_LOOKED=""

# /etc/sudoers.d is the one place you can't look into without root.
# the old rules gave passwordless dnf to everyone in wheel. .rpmsave and
# .rpmnew copies don't count to sudo, but one rename switches them back on
find_old_sudoers() {
	local f
	OLD_SUDOERS=()
	SUDOERS_LOOKED=""
	if ! sudo -n true 2>/dev/null; then
		has_tty || return
		echo "  Looking in /etc/sudoers.d needs your password, only root can read it."
		sudo -v </dev/tty || return
	fi
	SUDOERS_LOOKED=1
	while IFS= read -r f; do
		rpm -qf "$f" >/dev/null 2>&1 || OLD_SUDOERS+=("$f")
	done < <(sudo find /etc/sudoers.d -maxdepth 1 -type f \( -name 'linuxtweaks*' -o -name 'dnf-updater*' \) 2>/dev/null)
}

find_old() {
	local p name
	OLD_PKGS=()
	OLD_HOME=()
	OLD_SYSTEM=()
	OLD_PIDS=()

	# the old packages themselves. by full name, so dnf can't mix them up
	# with linuxtweaks-updater, which says it provides the old names
	for name in $OLD_PACKAGES; do
		[ "$(rpm -q --qf '%{NAME}' "$name" 2>/dev/null)" = "$name" ] && OLD_PKGS+=("$(rpm -q "$name")")
	done

	for p in "${OLD_HOME_GLOBS[@]}"; do
		[ -e "$p" ] || [ -L "$p" ] && OLD_HOME+=("$p")
	done
	for p in "${OLD_SYSTEM_GLOBS[@]}"; do
		[ -e "$p" ] || [ -L "$p" ] || continue
		rpm -qf "$p" >/dev/null 2>&1 || OLD_SYSTEM+=("$p")
	done

	# an old tray still running. 6.x ran as "python3 -m tray" from its own
	# folder, so I only count it when that folder is one of mine. only real
	# tray and check paths: the GitHub link has /linuxtweaks/ in it too, and
	# run through ssh or sh -c this used to find its own shell and kill it
	local old_paths='/linuxtweaks/(tray|lib)/|/dnf-updater/(tray|lib)/|/linuxtweaks-dnf-updater/(tray|lib)/'
	for p in $(pgrep -u "$(id -u)" -f "python3 -m tray|$old_paths" 2>/dev/null); do
		[ "$p" = "$$" ] || [ "$p" = "$PPID" ] && continue
		tr '\0' ' ' <"/proc/$p/cmdline" 2>/dev/null | grep -qE "$PACKAGE|install-linuxtweaks|githubusercontent" && continue
		if tr '\0' ' ' <"/proc/$p/cmdline" 2>/dev/null | grep -qE "$old_paths" ||
			readlink "/proc/$p/cwd" 2>/dev/null | grep -qE '/linuxtweaks|dnf-updater'; then
			OLD_PIDS+=("$p")
		fi
	done

	find_old_sudoers
}

show_old() {
	local p
	for p in "${OLD_PKGS[@]}"; do note "old package still installed: $p"; done
	for p in "${OLD_PIDS[@]}"; do note "old tray running, pid $p"; done
	for p in "${OLD_SUDOERS[@]}"; do note "$p ${RED}(old sudo rules)${NC}"; done
	for p in "${OLD_HOME[@]}"; do note "$p"; done
	for p in "${OLD_SYSTEM[@]}"; do note "$p (no package owns it)"; done
	[ -z "$SUDOERS_LOOKED" ] && note "couldn't look in /etc/sudoers.d without your password"
}

old_count() { echo $((${#OLD_PKGS[@]} + ${#OLD_HOME[@]} + ${#OLD_SYSTEM[@]} + ${#OLD_SUDOERS[@]} + ${#OLD_PIDS[@]})); }

remove_old() {
	local count
	count=$(old_count)
	[ ${#OLD_PIDS[@]} -gt 0 ] && kill "${OLD_PIDS[@]}" 2>/dev/null
	systemctl --user stop 'dnf-updater-*' 'linuxtweaks-dnf-updater-*' \
		linuxtweaks.timer linuxtweaks.service linuxtweaks-autostart.service \
		linuxtweaks-tray.service linuxtweaks-resume.service >/dev/null 2>&1
	# my old hand made system timers can still be running. switch off only
	# the ones whose file is on the list, so never anything a package owns
	local u
	for u in linuxtweaks-flatpak-cleanup.timer linuxtweaks-podman-prune.timer; do
		printf '%s\n' "${OLD_SYSTEM[@]}" | grep -qx "/etc/systemd/system/$u" &&
			sudo systemctl disable --now "$u" >/dev/null 2>&1
	done
	# by exact name and version, never just "linuxtweaks"
	[ ${#OLD_PKGS[@]} -gt 0 ] && sudo dnf remove -y "${OLD_PKGS[@]}"
	[ ${#OLD_SUDOERS[@]} -gt 0 ] && sudo rm -f "${OLD_SUDOERS[@]}"
	[ ${#OLD_HOME[@]} -gt 0 ] && rm -rf "${OLD_HOME[@]}"
	if [ ${#OLD_SYSTEM[@]} -gt 0 ]; then
		sudo rm -rf "${OLD_SYSTEM[@]}"
		sudo systemctl daemon-reload 2>/dev/null
		sudo gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null
	fi
	systemctl --user daemon-reload 2>/dev/null
	systemctl --user reset-failed 2>/dev/null
	ok "removed ${count} old leftover(s)"
}

# look, show, ask, then clean
cleanup_old() {
	step "Old leftovers (dnf-updater, linuxtweaks-dnf-updater, LinuxTweaks 6.x)"
	find_old
	if [ "$(old_count)" -eq 0 ]; then
		ok "none found"
		[ -z "$SUDOERS_LOOKED" ] && note "couldn't look in /etc/sudoers.d without your password"
		return
	fi
	echo "  These are from my older apps. Some can start the old app next to the"
	echo "  new one, old sudo rules give out root without a password, and the old"
	echo "  flatpak and podman timers do what the updater does now:"
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

	# my older apps, the packages included. say no and dnf still swaps
	# linuxtweaks 6.x and linuxtweaks-dnf-updater for the new one anyway
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
	step "Old leftovers (dnf-updater, linuxtweaks-dnf-updater, LinuxTweaks 6.x)"
	find_old
	if [ "$(old_count)" -eq 0 ]; then
		ok "none found"
		# say so when sudoers wasn't looked at, "none" shouldn't cover a place I couldn't see
		[ -z "$SUDOERS_LOOKED" ] && note "couldn't look in /etc/sudoers.d without your password"
	else
		show_old
		echo "  Remove them with: bash install-linuxtweaks.sh --cleanup"
	fi
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
	echo "  bash install-linuxtweaks.sh --cleanup     only clear out what my older apps left behind"
	echo "  bash install-linuxtweaks.sh --remove      uninstall it"
	echo "  bash install-linuxtweaks.sh --fake 3 20   3 dnf + 20 flatpak fake updates in the tray"
	echo "  bash install-linuxtweaks.sh --restore     put the real update list back"
	exit 1
	;;
esac
