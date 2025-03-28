#!/bin/bash
# tolga erok
# 26/3/2025

LinuxTweaks_URL="git@github.com:tolgaerok/linuxtweaks.git"
LinuxTweaks_DIR=~/MyGit/linuxtweaks

# check if my directory exists
if [ ! -d "$LinuxTweaks_DIR" ]; then
    echo "Cloning repository..."
    git clone "$LinuxTweaks_URL" "$LinuxTweaks_DIR"
fi

cd "$LinuxTweaks_DIR" || exit
git remote set-url origin "$LinuxTweaks_URL"
git branch --set-upstream-to=origin/main main 2>/dev/null
git pull
