#!/bin/bash
# ======================================================================
#   LinuxTweaks - cleanup of the OLD LinuxTweaks app (6.x and earlier)
#   Author : Tolga Erok
#   Date   : 29 Sep 2026
#
#   Removes what the old app left behind: pre-RPM copies in your home
#   folder (~/.local/lib/linuxtweaks, ~/.local/bin/linuxtweaks*), their user
#   timers/services/autostart - which can keep starting the OLD app next to
#   LinuxTweaks Updater - old settings, and unowned leftovers in /usr.
#
#   bash cleanup-old-linuxtweaks.sh           look only, changes nothing
#   bash cleanup-old-linuxtweaks.sh --apply   remove what it found
#
#   Only exact old names. Never touches LinuxTweaks Updater
#   (linuxtweaks-updater*), and only removes system folders that no
#   installed package owns.
# ======================================================================

BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

APPLY=""
[ "$1" = "--apply" ] && APPLY=1
FOUND=0

step() { echo -e "\n${CYAN}▶${NC} ${BLUE}$*${NC}"; }
found() {
	FOUND=$((FOUND + 1))
	if [ -n "$APPLY" ]; then echo -e "  ${GREEN}removed${NC}  $*"; else echo -e "  ${YELLOW}found${NC}    $*"; fi
}

# home-folder leftover: file, link or folder
user_item() {
	[ -e "$1" ] || [ -L "$1" ] || return 0
	found "$1"
	[ -n "$APPLY" ] && rm -rf "$1"
}

# system leftover: only if no installed package owns it
system_item() {
	sudo test -e "$1" 2>/dev/null || [ -e "$1" ] || return 0
	if rpm -qf "$1" >/dev/null 2>&1; then
		return 0 # owned by an installed package - not a leftover
	fi
	found "$1 (not owned by any package)"
	[ -n "$APPLY" ] && sudo rm -rf "$1"
}

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  🫟  Old LinuxTweaks cleanup $([ -n "$APPLY" ] && echo "(removing)" || echo "(look only)")${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

step "Old LinuxTweaks package"
if rpm -q --qf '%{NAME}\n' linuxtweaks 2>/dev/null | grep -qx linuxtweaks; then
	echo -e "  ${YELLOW}installed${NC} $(rpm -q linuxtweaks) - 'sudo dnf upgrade --refresh' replaces it with LinuxTweaks Updater"
else
	echo -e "  ${GREEN}not installed${NC}"
fi

step "Old app still running"
OLD_PIDS=$(pgrep -u "$(id -u)" -f 'python3 -m tray|/linuxtweaks/tray/|/linuxtweaks/lib/check.sh' 2>/dev/null |
	while read -r p; do
		# never the new updater
		tr '\0' ' ' <"/proc/$p/cmdline" 2>/dev/null | grep -q 'linuxtweaks-updater' || echo "$p"
	done)
if [ -n "$OLD_PIDS" ]; then
	for p in $OLD_PIDS; do found "process $p: $(tr '\0' ' ' <"/proc/$p/cmdline" 2>/dev/null | cut -c1-80)"; done
	[ -n "$APPLY" ] && kill $OLD_PIDS 2>/dev/null
else
	echo -e "  ${GREEN}none${NC}"
fi

step "Old timers, services and autostart in your account"
UNITS="linuxtweaks.timer linuxtweaks.service linuxtweaks-autostart.service app-linuxtweaks@autostart.service"
if [ -n "$APPLY" ]; then
	systemctl --user disable --now $UNITS >/dev/null 2>&1
fi
for u in $UNITS; do
	user_item "$HOME/.config/systemd/user/$u"
	for link in "$HOME"/.config/systemd/user/*.wants/"$u"; do user_item "$link"; done
done
for f in linuxtweaks.desktop linuxtweaks-tray.desktop linuxtweaks-autostart.desktop; do
	user_item "$HOME/.config/autostart/$f"
done

step "Old copies and settings in your home folder"
user_item "$HOME/.local/lib/linuxtweaks"
user_item "$HOME/.local/share/linuxtweaks"
for f in linuxtweaks linuxtweaks-autostart linuxtweaks-check linuxtweaks-upgrade linuxtweaks-tray; do
	user_item "$HOME/.local/bin/$f"
done
user_item "$HOME/.local/share/applications/linuxtweaks.desktop"
user_item "$HOME/.config/linuxtweaks"
user_item "$HOME/.cache/linuxtweaks"

step "Old system leftovers (need sudo to check)"
for p in /usr/lib/linuxtweaks /usr/lib64/linuxtweaks /usr/local/share/linuxtweaks \
	/usr/local/lib/linuxtweaks /usr/local/bin/linuxtweaks /usr/local/bin/linuxtweaks-check \
	/usr/local/bin/linuxtweaks-upgrade /usr/local/bin/linuxtweaks-autostart \
	/etc/sudoers.d/linuxtweaks /etc/xdg/autostart/linuxtweaks.desktop \
	/usr/lib/systemd/user/linuxtweaks.timer /usr/lib/systemd/user/linuxtweaks.service \
	/usr/lib/systemd/user/linuxtweaks-autostart.service; do
	system_item "$p"
done
for link in /etc/systemd/user/*.wants/linuxtweaks.timer /etc/systemd/user/*.wants/linuxtweaks-autostart.service; do
	[ -L "$link" ] && system_item "$link"
done

if [ -n "$APPLY" ]; then
	systemctl --user daemon-reload 2>/dev/null
	systemctl --user reset-failed 2>/dev/null
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ "$FOUND" -eq 0 ]; then
	echo -e "  ${GREEN}✅ No old LinuxTweaks leftovers found${NC}"
elif [ -n "$APPLY" ]; then
	echo -e "  ${GREEN}✅ Removed $FOUND old leftover(s)${NC} - log out and back in for a clean start"
else
	echo -e "  ${YELLOW}$FOUND old leftover(s) found.${NC} Remove them with:"
	echo -e "  ${GREEN}bash $0 --apply${NC}"
fi
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
