#!/usr/bin/env python3
# Tolga Erok
# 1/4/2025

# Update Checker (Beta)

import subprocess

def check_for_updates():
    """Checks if LinuxTweaks has updates available from GitHub."""
    repo_path = "/usr/local/bin/LinuxTweaks"

    try:
        # get my current commit hash
        current_commit = subprocess.run(
            ["git", "-C", repo_path, "rev-parse", "HEAD"],
            capture_output=True,
            text=True,
            check=True
        ).stdout.strip()

        # fetch latest changes without modifying my files
        subprocess.run(
            ["git", "-C", repo_path, "fetch", "origin"],
            capture_output=True,
            text=True,
            check=True
        )

        # get the latest commit hash from my remote repository
        latest_commit = subprocess.run(
            ["git", "-C", repo_path, "rev-parse", "origin/main"],
            capture_output=True,
            text=True,
            check=True
        ).stdout.strip()

        if current_commit == latest_commit:
            return "✅ LinuxTweaks is up-to-date."
        else:
            return "🔄 Update available! Run:\n\n`git -C /usr/local/bin/LinuxTweaks pull`"

    except subprocess.CalledProcessError as e:
        return f"❌ Failed to check for updates:\n{e.stderr}"
