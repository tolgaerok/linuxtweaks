# Tolga Erok
# 26-3-2025

# APP IMAGE LOCATION:      /usr/local/bin/LinuxTweaks/images/LinuxTweak.png
# APP LOCATION:            /usr/local/bin/LinuxTweaks/LinuxTweaks.py
# PYTHON ONLINE FORMATTER: https://codebeautify.org/python-formatter-beautifier#
# SYMLINK:                 sudo ln -s /usr/local/bin/LinuxTweaks/LinuxTweaks.py /usr/local/bin/linuxtweaks
# Installer:               curl -sL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/MY_PYTHON_APP/installer.sh | sudo bash

import subprocess
from modules.icons import icon_green, icon_amber, icon_red


def check_service_status(service):
    """Returns status icons for each service"""
    try:
        active_status = subprocess.run(
            ["systemctl", "is-active", service],
            capture_output=True,
            text=True,
            check=True,
        ).stdout.strip()
        enabled_status = subprocess.run(
            ["systemctl", "is-enabled", service],
            capture_output=True,
            text=True,
            check=True,
        ).stdout.strip()

        if active_status == "active" and enabled_status == "enabled":
            return icon_green, "Active"
        elif enabled_status == "disabled":
            return icon_amber, "Disabled"
        else:
            return icon_red, "Inactive"
    except subprocess.CalledProcessError:
        return icon_red, "Error"


def manage_service(action, service_name):
    """Start/Stop/Restart a service with error handling"""
    try:
        subprocess.run(["systemctl", "daemon-reload"], check=True, capture_output=True)
        subprocess.run(
            ["systemctl", action, service_name], check=True, capture_output=True
        )
        return f"✅ {service_name} {action}ed successfully."
    except subprocess.CalledProcessError as e:
        return f"❌ Failed to {action} {service_name}: {e}"
