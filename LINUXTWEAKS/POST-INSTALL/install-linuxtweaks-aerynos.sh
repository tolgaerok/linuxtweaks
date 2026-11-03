#!/usr/bin/env bash
# tolga erok
# 3/11/26
# my linuxtweaks quick install for aerynos
#
# curl -fsSL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/LINUXTWEAKS/POST-INSTALL/install-linuxtweaks-aerynos.sh | bash

set -e
index=https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/LINUXTWEAKS/STONE/AERYNOS/stone.index

# new moss says pkg add, the old one install
if moss pkg --help >/dev/null 2>&1; then new=1; else new=0; fi

# old moss can't do volatile, so only ask on the new one
if [ "$new" = 1 ]; then
    printf '\n\033[1;33m   ⚠️  volatile repo  ⚠️\033[0m\n'
    printf '     newer packages sooner, can break now and then\n\n'
    printf '  add it too? [y/N] '
    read -r ans </dev/tty || ans=n
    if [[ $ans =~ ^[Yy] ]]; then
        sudo moss repo add volatile https://cdn.aerynos.dev/ --root-index version=stream/volatile -p 10 -c volatile || true
        sudo moss sync -u -y
    fi
fi

# already added is fine
sudo moss repo add linuxtweaks "$index" -p 10 -c linuxtweaks || true
sudo moss repo update linuxtweaks

if [ "$new" = 1 ]; then sudo moss pkg add -y linuxtweaks-updater; else sudo moss install -y linuxtweaks-updater; fi

setsid -f linuxtweaks-updater >/dev/null 2>&1 || true
echo "done, look for the tray icon"
