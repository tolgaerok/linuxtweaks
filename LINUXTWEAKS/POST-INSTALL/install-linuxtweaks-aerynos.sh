#!/usr/bin/env bash
# tolga erok
# my old aerynos only install line. install-linuxtweaks.sh does all 3 distros
# now (10 Nov), this just hands over to it so old links still work
#
# curl -fsSL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/LINUXTWEAKS/POST-INSTALL/install-linuxtweaks.sh | bash

curl -fsSL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/LINUXTWEAKS/POST-INSTALL/install-linuxtweaks.sh | bash -s -- "$@"
