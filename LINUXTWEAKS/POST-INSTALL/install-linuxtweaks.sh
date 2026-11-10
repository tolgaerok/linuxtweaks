#!/usr/bin/env bash
# 👁️‍🗨️ Created by: Tolga Erok
# 📧 Email:      kingtolga@gmail.com
# 📡 GitHub:     https://github.com/tolgaerok/linuxtweaks
# SPDX-License-Identifier: GPL-3.0-or-later
#
# one installer for LinuxTweaks on Fedora, Solus and AerynOS. it looks at
# /etc/os-release, grabs the newest signed package from my GitHub, checks
# it's signed with my key and installs it. already in? it updates it or
# takes it off. everything comes from GitHub, no Tailscale needed.
#
#   curl -fsSL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/LINUXTWEAKS/POST-INSTALL/install-linuxtweaks.sh | bash
#
# on a desktop with PyQt6 or PyQt5 already there it opens my window
# (install-linuxtweaks-gui.py), the window runs this same script for every
# step. no PyQt yet (a fresh Fedora or Solus can have none) and it does the
# same steps right here in the terminal. --terminal forces that, --check
# only downloads it and checks the signature.
#
# it never updates the rest of your system and never runs as root itself,
# it asks for your password once, for the install.

set -u

RAW=https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main
API=https://api.github.com/repos/tolgaerok/linuxtweaks/contents/LINUXTWEAKS
KEY_URL=$RAW/LINUXTWEAKS/KEYS/linuxtweaks-key.gpg
STONE_INDEX=$RAW/LINUXTWEAKS/STONE/AERYNOS/stone.index
FPR=B7574AE0016A7493E9AB64E4F75286EAE1540626
PKG=linuxtweaks-updater
UA="LinuxTweaks-installer"

# plain lines for my window, colours for a terminal
PLAIN=0
say() {
    local kind=$1
    shift
    if [ "$PLAIN" = 1 ]; then
        echo "$kind: $*"
        return
    fi
    case $kind in
        step) printf '\033[0;36m●\033[0m %s\n' "$*" ;;
        ok) printf '\033[0;32m✓\033[0m %s\n' "$*" ;;
        done) printf '\033[1;32m✓ %s\033[0m\n' "$*" ;;
        fail) printf '\033[0;31m✗ %s\033[0m\n' "$*" ;;
        *) printf '  %s\n' "$*" ;;
    esac
}
die() { say fail "$*"; exit 1; }
# what dnf, eopkg or moss print, as log lines
show() { local l; while IFS= read -r l; do say log "$l"; done; }

# ---- what box is this -------------------------------------------------

find_distro() {
    local f=/etc/os-release
    [ -f "$f" ] || f=/usr/lib/os-release
    ID="" NAME="" PRETTY_NAME=""
    # shellcheck disable=SC1090
    [ -f "$f" ] && . "$f"
    case "${ID:-}" in
        fedora) DISTRO=fedora ;;
        solus) DISTRO=solus ;;
        aerynos) DISTRO=aerynos ;;
        *)
            if command -v eopkg >/dev/null 2>&1; then DISTRO=solus
            else DISTRO=unknown
            fi
            ;;
    esac
    DNAME=${PRETTY_NAME:-${NAME:-unknown}}
}

installed_version() {
    local f
    for f in /usr/lib/$PKG/tray/version.py /usr/lib64/$PKG/tray/version.py; do
        [ -f "$f" ] && { sed -n 's/^__version__ = "v\{0,1\}\([^"]*\)".*/\1/p' "$f"; return; }
    done
}

# ---- the newest package on my GitHub ----------------------------------

folder_and_pattern() {
    case $DISTRO in
        fedora) FOLDER="RPM/linuxtweaks-updater%20v7x"; PAT="^$PKG-[0-9.]+-[0-9]+\.fc[0-9]+\.noarch\.rpm[|]" ;;
        solus) FOLDER="EOPKG/SOLUS"; PAT="^$PKG-[0-9.]+-[0-9]+-[0-9]+-x86_64\.eopkg[|]" ;;
        aerynos) FOLDER="STONE/AERYNOS"; PAT="^$PKG-[0-9.]+-[0-9]+-[0-9]+-x86_64\.stone[|]" ;;
    esac
}

# finds the newest package in my GitHub folder, its name, link, size and version
newest() {
    local list line
    folder_and_pattern
    list=$(curl -fsSL -A "$UA" "$API/$FOLDER" | tr ',{}' '\n\n\n') || return 1
    line=$(echo "$list" | awk -F'"' '
        /"name":/ {n=$4}
        /"size":/ {s=$0; gsub(/[^0-9]/, "", s)}
        /"download_url":/ {print n "|" s "|" $4}' |
        grep -E "$PAT" | sort -V | tail -1)
    [ -n "$line" ] || return 1
    NEW_NAME=${line%%|*}
    line=${line#*|}
    NEW_SIZE=${line%%|*}
    NEW_URL=${line#*|}
    # linuxtweaks-updater-8.2.94-1.fc44.noarch.rpm -> 8.2.94
    NEW_VER=$(echo "$NEW_NAME" | sed -E "s/^$PKG-([0-9.]+)-.*/\1/")
}

# ---- download and check it's mine -------------------------------------

get_key() {
    curl -fsSL -A "$UA" -o "$WORK/key.gpg" "$KEY_URL" || die "couldn't get my key from GitHub"
    # the key file has to be mine too. gpg isn't on every fresh box, gpgv is
    if command -v gpg >/dev/null 2>&1; then
        gpg --show-keys --with-colons "$WORK/key.gpg" 2>/dev/null | grep -q "^fpr:*$FPR:" ||
            die "the key on GitHub isn't mine, stopped"
    fi
}

# the package (and its .asc) into $1
download() {
    local dir=$1
    mkdir -p "$dir"
    FILE="$dir/$NEW_NAME"
    say step "getting $NEW_NAME from GitHub"
    curl -fsSL -A "$UA" -o "$FILE" "$NEW_URL" || die "download failed, try again in a bit"
    if [ "$DISTRO" != fedora ]; then
        curl -fsSL -A "$UA" -o "$FILE.asc" "$NEW_URL.asc" || die "couldn't get its signature (.asc)"
    fi
    say ok "got $NEW_NAME"
}

verify() {
    local g d
    say step "checking it's signed with my key"
    get_key
    if [ "$DISTRO" = fedora ]; then
        # checks it with my key in a throwaway spot, your own keys never change
        command -v gpg >/dev/null 2>&1 || die "gpg isn't installed, sudo dnf install gnupg2"
        g=$(mktemp -d "$WORK/gpg.XXXX")
        d=$(mktemp -d "$WORK/rpmdb.XXXX")
        GNUPGHOME=$g gpg -q --import "$WORK/key.gpg" 2>/dev/null
        GNUPGHOME=$g gpg -q --armor --export "$FPR" >"$WORK/key.asc" 2>/dev/null
        gpgconf --homedir "$g" --kill all >/dev/null 2>&1
        rpmkeys --dbpath "$d" --import "$WORK/key.asc" >/dev/null 2>&1 &&
            rpmkeys --dbpath "$d" --checksig "$FILE" >/dev/null 2>&1 ||
            die "it isn't signed with my key, not installing it"
    else
        gpgv --keyring "$WORK/key.gpg" "$FILE.asc" "$FILE" >/dev/null 2>&1 ||
            die "it isn't signed with my key, not installing it"
    fi
    say ok "signed with my key (${FPR: -16})"
}

# ---- the root bit, one password ---------------------------------------

# the password bit. my window asks with a password box, the terminal with sudo
as_root() {
    local mode=color rc
    [ "$PLAIN" = 1 ] && mode=plain
    if [ "$GUI" = 1 ]; then
        pkexec /usr/bin/bash "$SELF" --root "$mode" "$@"
    else
        sudo /usr/bin/bash "$SELF" --root "$mode" "$@"
    fi
    rc=$?
    # you closed the password box or got it wrong
    [ "$GUI" = 1 ] && [ $rc = 126 -o $rc = 127 ] && die "no password given, nothing changed"
    [ $rc = 0 ] || exit 1
}

# the bit that runs as root. it only takes my own packages
root_part() {
    local action=$2 distro=$3 file=${4:--} extras=${5:-} helper
    [ "$1" = plain ] && PLAIN=1
    [ "$(id -u)" = 0 ] || die "--root is for the password step only"
    if [ "$file" != - ]; then
        [[ $file =~ ^(/tmp/lt-install\.[A-Za-z0-9]+|/home/[A-Za-z0-9._-]+/\.cache/linuxtweaks-updater)/linuxtweaks-updater-[0-9.]+-[0-9]+[-.][A-Za-z0-9._-]+$ ]] ||
            die "not my package: $file"
        [ -f "$file" ] && [ ! -L "$file" ] || die "no such file: $file"
    fi
    case "$distro:$action" in
        fedora:install | fedora:update)
            say step "dnf installing it and what it needs"
            dnf install -y "$file" 2>&1 | show
            [ "${PIPESTATUS[0]}" = 0 ] || die "dnf couldn't install it"
            if [[ $extras == *bandwhich* ]]; then
                say step "getting bandwhich from Terra for the Traffic tab"
                /usr/lib/$PKG/bin/linuxtweaks-updater-tweaks get-bandwhich >/dev/null 2>&1 ||
                    say log "bandwhich didn't go in, the Traffic tab can get it later"
            fi
            ;;
        solus:install | solus:update)
            say step "eopkg installing it and what it needs"
            eopkg it -y "$file" 2>&1 | show
            [ "${PIPESTATUS[0]}" = 0 ] || die "eopkg couldn't install it"
            ;;
        aerynos:install)
            if [[ $extras == *volatile* ]]; then
                say step "adding the volatile repo"
                moss repo add volatile https://cdn.aerynos.dev/ --root-index version=stream/volatile -p 10 -c volatile >/dev/null 2>&1 || true
            fi
            say step "adding my moss repo and installing it"
            moss repo add linuxtweaks "$STONE_INDEX" -p 10 -c linuxtweaks >/dev/null 2>&1 || true
            moss repo update linuxtweaks >/dev/null 2>&1 || true
            if moss pkg --help >/dev/null 2>&1; then
                moss pkg add -y "$PKG" 2>&1 | show
            else
                moss install -y "$PKG" 2>&1 | show
            fi
            [ "${PIPESTATUS[0]}" = 0 ] || die "moss couldn't install it"
            ;;
        aerynos:update)
            # moss can't update one package on its own, a sync moves the whole
            # system. LinuxTweaks' own About update does it right, same helper
            helper=/usr/lib/$PKG/bin/linuxtweaks-updater-upgrade-helper
            [ -x "$helper" ] || die "the LinuxTweaks on here is too old for this, use About → Check for LinuxTweaks updates"
            say step "installing it the way About does"
            "$helper" self-update "$file" >/dev/null 2>&1 || die "the update didn't go in"
            ;;
        fedora:remove)
            say step "dnf removing LinuxTweaks"
            dnf remove -y "$PKG" 2>&1 | show
            [ "${PIPESTATUS[0]}" = 0 ] || die "dnf couldn't remove it"
            ;;
        solus:remove)
            say step "eopkg removing LinuxTweaks"
            eopkg rm -y "$PKG" 2>&1 | show
            [ "${PIPESTATUS[0]}" = 0 ] || die "eopkg couldn't remove it"
            ;;
        aerynos:remove)
            say step "moss removing LinuxTweaks"
            if moss pkg --help >/dev/null 2>&1; then
                moss pkg remove -y "$PKG" 2>&1 | show
            else
                moss remove -y "$PKG" 2>&1 | show
            fi
            [ "${PIPESTATUS[0]}" = 0 ] || die "moss couldn't remove it"
            ;;
        *) die "don't know how to $action on $distro" ;;
    esac
    exit 0
}

# ---- the jobs ---------------------------------------------------------

restart_tray() {
    pkill -u "$(id -u)" -f "$PKG/tray/tray.py" 2>/dev/null
    sleep 1
    command -v "$PKG" >/dev/null 2>&1 && setsid -f "$PKG" >/dev/null 2>&1
}

do_install() {
    local extras=$1 dir=$WORK
    newest || die "couldn't reach my GitHub, check your internet"
    # aeryn's About update only takes a stone from LinuxTweaks' own cache
    [ "$DISTRO" = aerynos ] && [ "$ACTION" = update ] && dir="$HOME/.cache/$PKG"
    download "$dir"
    verify
    as_root "$ACTION" "$DISTRO" "$FILE" "$extras"
    say step "starting LinuxTweaks"
    restart_tray
    say done "LinuxTweaks $NEW_VER is in, look for it in your tray"
}

# Browser in RAM keeps your browser profile in /dev/shm with a link to it.
# take LinuxTweaks off with that on and the profile's gone after a reboot,
# so it goes back on disk first
browser_ram_off() {
    local lib b out
    for lib in /usr/lib/$PKG/lib /usr/lib64/$PKG/lib; do
        [ -f "$lib/browser_ram.sh" ] || continue
        for b in firefox librewolf; do
            out=$(bash "$lib/browser_ram.sh" status "$b" 2>/dev/null)
            echo "$out" | grep -qE '^state=(on|leaving|broken|waiting)$' || continue
            echo "$out" | grep -q '^running=1$' &&
                die "Browser in RAM is on for $b, close $b first so its profile goes back on disk"
            say step "putting your $b profile back on disk"
            bash "$lib/browser_ram.sh" off "$b" >/dev/null 2>&1 || die "couldn't put $b back on disk, nothing removed"
        done
    done
}

# what goes with it. moss takes python-pyqt6-svg along on aeryn
remove_list() {
    case $DISTRO in
        aerynos)
            if moss pkg --help >/dev/null 2>&1; then
                moss pkg remove --dry-run "$PKG" 2>/dev/null
            else
                moss remove --dry-run "$PKG" 2>/dev/null
            fi | grep -v ':' | awk '{for (i = 1; i < NF; i += 2) print $i " " $(i + 1)}' | sort -u
            ;;
        *) echo "$PKG" ;;
    esac
}

do_remove() {
    browser_ram_off
    as_root remove "$DISTRO" -
    pkill -u "$(id -u)" -f "$PKG/tray/tray.py" 2>/dev/null
    say done "LinuxTweaks is off this pc"
}

wipe_settings() {
    rm -rf "$HOME/.local/state/$PKG" "$HOME/.cache/$PKG" "$HOME/.config/$PKG"
    say done "your LinuxTweaks settings are gone too"
}

info() {
    newest >/dev/null 2>&1 || true
    echo "distro=$DISTRO"
    echo "name=$DNAME"
    echo "installed=$(installed_version)"
    echo "newest=${NEW_VER:-}"
    echo "file=${NEW_NAME:-}"
    echo "size=${NEW_SIZE:-}"
}

ask() {
    local ans
    printf '%s ' "$1" >/dev/tty
    read -r ans </dev/tty || ans=""
    echo "${ans:-$2}"
}

terminal() {
    local have extras="" a
    printf '\n\033[1;36m  LinuxTweaks installer\033[0m  \033[0;34m%s\033[0m\n\n' "$DNAME"
    [ "$DISTRO" = unknown ] && die "LinuxTweaks is for Fedora, Solus and AerynOS, this is $DNAME"
    newest || die "couldn't reach my GitHub, check your internet"
    have=$(installed_version)
    if [ -z "$have" ]; then
        say log "LinuxTweaks isn't on here yet, newest is $NEW_VER ($((NEW_SIZE / 1024)) KB)"
        if [ "$DISTRO" = fedora ]; then
            a=$(ask "  get bandwhich from Terra too, for the Traffic tab? [y/N]" n)
            [[ $a =~ ^[Yy] ]] && extras=bandwhich
        fi
        if [ "$DISTRO" = aerynos ]; then
            a=$(ask "  add the volatile repo too (newer packages sooner, can break now and then)? [y/N]" n)
            [[ $a =~ ^[Yy] ]] && extras=volatile
        fi
        a=$(ask "  install it? [Y/n]" y)
        [[ $a =~ ^[Yy] ]] || { say log "left it, nothing changed"; exit 0; }
        ACTION=install
        do_install "$extras"
        return
    fi
    say log "LinuxTweaks $have is on here, newest is $NEW_VER"
    if [ "$(printf '%s\n%s\n' "$have" "$NEW_VER" | sort -V | tail -1)" != "$have" ]; then
        a=$(ask "  update to $NEW_VER? [Y/n]" y)
        if [[ $a =~ ^[Yy] ]]; then
            ACTION=update
            do_install ""
            return
        fi
    else
        say ok "you're on the newest"
    fi
    a=$(ask "  take LinuxTweaks off this pc? [y/N]" n)
    [[ $a =~ ^[Yy] ]] || exit 0
    if [ "$DISTRO" = aerynos ]; then
        say log "moss takes these with it:"
        remove_list | show
        a=$(ask "  still take it off? [y/N]" n)
        [[ $a =~ ^[Yy] ]] || exit 0
    fi
    do_remove
    a=$(ask "  delete your LinuxTweaks settings too? [y/N]" n)
    [[ $a =~ ^[Yy] ]] && wipe_settings
}

# ---- start ------------------------------------------------------------

if [ "${1:-}" = --root ]; then
    shift
    find_distro
    root_part "$@"
fi

[ "$(id -u)" = 0 ] && die "run it as you, not root. it asks for your password when it needs it"
command -v curl >/dev/null 2>&1 || die "curl isn't installed"

WORK=$(mktemp -d /tmp/lt-install.XXXXXXXX)
chmod 755 "$WORK"
trap 'rm -rf "$WORK"' EXIT
find_distro

# piped from curl there's no file to run as root, so grab my own copy
HERE=""
if [ -f "${BASH_SOURCE[0]:-}" ]; then
    SELF=$(readlink -f "${BASH_SOURCE[0]}")
    HERE=$(dirname "$SELF")
else
    SELF="$WORK/install-linuxtweaks.sh"
    curl -fsSL -A "$UA" -o "$SELF" "$RAW/LINUXTWEAKS/POST-INSTALL/install-linuxtweaks.sh" ||
        die "couldn't get the installer from GitHub"
fi

# my window asks for plain lines and the password box
GUI=0
if [ "${1:-}" = --plain ]; then
    PLAIN=1
    GUI=1
    shift
fi

case "${1:-}" in
    --info) info ;;
    --check)
        # download and check the signature, installs nothing
        newest || die "couldn't reach my GitHub, check your internet"
        download "$WORK"
        verify
        say done "$NEW_NAME is mine and good to go, nothing installed"
        ;;
    --install) ACTION=install; do_install "${2:-}" ;;
    --update) ACTION=update; do_install "" ;;
    --remove-list) remove_list ;;
    --remove) do_remove ;;
    --wipe) wipe_settings ;;
    --terminal) terminal ;;
    "")
        # my window when there's a desktop and PyQt, the terminal if not
        py=""
        if [ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ] && command -v python3 >/dev/null 2>&1; then
            python3 -c 'import PyQt6.QtWidgets' 2>/dev/null && py=6
            [ -z "$py" ] && python3 -c 'import PyQt5.QtWidgets' 2>/dev/null && py=5
        fi
        if [ -n "$py" ]; then
            gui="$HERE/install-linuxtweaks-gui.py"
            if [ -z "$HERE" ] || [ ! -f "$gui" ]; then
                gui="$WORK/install-linuxtweaks-gui.py"
                curl -fsSL -A "$UA" -o "$gui" "$RAW/LINUXTWEAKS/POST-INSTALL/install-linuxtweaks-gui.py" || gui=""
                # my LinuxTweaks icon for the window, it looks next to itself
                curl -fsSL -A "$UA" -o "$WORK/install-linuxtweaks-icon.png" \
                    "$RAW/LINUXTWEAKS/POST-INSTALL/install-linuxtweaks-icon.png" 2>/dev/null || true
            fi
            if [ -n "$gui" ]; then
                python3 "$gui" "$SELF"
                exit $?
            fi
        fi
        [ "$DISTRO" != unknown ] && say log "no Qt on here yet, so I'll do it in the terminal. same steps"
        terminal
        ;;
    *)
        echo "install-linuxtweaks.sh [--terminal | --check]" >&2
        exit 2
        ;;
esac
