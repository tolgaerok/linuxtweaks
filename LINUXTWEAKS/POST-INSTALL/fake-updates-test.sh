#!/bin/bash
# ======================================================================
#   LinuxTweaks Updater - fake updates, to test the tray
#   Author : Tolga Erok
#   Date   : 29 Sep 2026
#
#   Shows fake updates in the tray (icon, tooltip, menu) without touching
#   a single package. Only the tray's own little list files are changed.
#
#   bash fake-updates-test.sh              1 DNF + 500 Flatpak fake updates
#   bash fake-updates-test.sh 3 20         3 DNF + 20 Flatpak
#   bash fake-updates-test.sh --restore    put the real lists back
#
#   The fakes last until the next check (tray countdown or "Check for
#   updates"), which writes the real lists again anyway. Don't press
#   Install while testing - it would just run a real, normal update.
# ======================================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

STATE="${HOME}/.local/state/linuxtweaks-updater"
BACKUP="${STATE}/fake-test-backup"
FILES="last_updates_check_packages last_updates_check_flatpak current_updates_check"

if [ ! -d "$STATE" ]; then
	echo "LinuxTweaks Updater hasn't run yet here - start it first: linuxtweaks-updater"
	exit 1
fi

if [ "$1" = "--restore" ]; then
	if [ ! -d "$BACKUP" ]; then
		echo "Nothing to restore - no fake test is active"
		exit 0
	fi
	for f in $FILES; do
		[ -f "$BACKUP/$f" ] && cp "$BACKUP/$f" "$STATE/$f"
	done
	rm -rf "$BACKUP"
	echo -e "${GREEN}✅ Real update lists restored${NC} - the tray redraws by itself"
	exit 0
fi

DNF_COUNT="${1:-1}"
FLATPAK_COUNT="${2:-500}"

# keep the real lists, once (running it twice mustn't back up the fakes)
if [ ! -d "$BACKUP" ]; then
	mkdir -p "$BACKUP"
	for f in $FILES; do
		[ -f "$STATE/$f" ] && cp "$STATE/$f" "$BACKUP/$f"
	done
fi

# same formats check.sh writes
for i in $(seq 1 "$DNF_COUNT"); do
	echo "fake-package-${i}: 1.0.0-1 → 1.0.1-1"
done >"$STATE/last_updates_check_packages"

for i in $(seq 1 "$FLATPAK_COUNT"); do
	printf 'Fake App %d\torg.linuxtweaks.FakeApp%d\t1.0.%d\tstable\tx86_64\tflathub\n' "$i" "$i" "$i"
done >"$STATE/last_updates_check_flatpak"

echo $((DNF_COUNT + FLATPAK_COUNT)) >"$STATE/current_updates_check"

echo -e "${GREEN}✅ Fake updates in the tray:${NC} ${DNF_COUNT} DNF + ${FLATPAK_COUNT} Flatpak"
echo -e "   Hover the icon and right-click it to see how they look."
echo -e "   ${YELLOW}Don't press Install${NC} (it would run a real update)."
echo -e "   Put the real lists back with: ${GREEN}bash $0 --restore${NC}"
