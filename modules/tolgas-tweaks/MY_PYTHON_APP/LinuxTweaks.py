#!/usr/bin/env python3
# Tolga Erok
# 26-3-2025

# APP IMAGE LOCATION:      /usr/local/bin/LinuxTweaks/images/LinuxTweak.png
# APP LOCATION:            /usr/local/bin/LinuxTweaks/LinuxTweaks.py
# PYTHON ONLINE FORMATTER: https://codebeautify.org/python-formatter-beautifier#
# SYMLINK:                 sudo ln -s /usr/local/bin/LinuxTweaks/LinuxTweaks.py /usr/local/bin/linuxtweaks


import sys
import subprocess
from PyQt6.QtWidgets import (
    QApplication,
    QWidget,
    QVBoxLayout,
    QLabel,
    QPushButton,
    QSystemTrayIcon,
    QMenu,
    QListWidget,
    QMessageBox,
)
from PyQt6.QtGui import QAction, QIcon
from PyQt6.QtCore import Qt, QTimer

# My custom systemd services to monitor
services = [
    "tolga-apply-cake-qdisc-wake.service",
    "tolga-apply-cake-qdisc.service",
    "tolga-flatpak-update.service",
]

# my icons for tray & tooltip
app_icon = "/usr/local/bin/LinuxTweaks/images/LinuxTweak.png"
icon_amber = "🛡️"
icon_green = "✔️"
icon_red = "⚠️"


def check_service_status(service):
    """Returns status icons for each of my services"""
    try:
        active_status = subprocess.run(
            ["systemctl", "is-active", service], capture_output=True, text=True
        ).stdout.strip()
        enabled_status = subprocess.run(
            ["systemctl", "is-enabled", service], capture_output=True, text=True
        ).stdout.strip()

        if active_status == "active" and enabled_status == "enabled":
            return icon_green, " Active   "
        elif enabled_status == "disabled":
            return icon_amber, " Disabled"
        else:
            return icon_red, " Inactive"
    except Exception:
        return icon_red, " Error"


class LinuxTweakMonitor(QWidget):
    def __init__(self, tray_icon):
        super().__init__()
        self.tray_icon = tray_icon
        self.setWindowTitle("LinuxTweak Service Monitor")
        self.setGeometry(100, 100, 350, 300)
        self.layout = QVBoxLayout()

        # My service list
        self.service_list = QListWidget()
        self.layout.addWidget(self.service_list)

        # Buttons
        self.start_button = QPushButton("Start Service")
        self.stop_button = QPushButton("Stop Service")
        self.restart_button = QPushButton("Restart Service")
        self.layout.addWidget(self.start_button)
        self.layout.addWidget(self.stop_button)
        self.layout.addWidget(self.restart_button)

        # Button actions
        self.start_button.clicked.connect(lambda: self.manage_service("start"))
        self.stop_button.clicked.connect(lambda: self.manage_service("stop"))
        self.restart_button.clicked.connect(lambda: self.manage_service("restart"))

        self.setLayout(self.layout)
        self.refresh_status()

    def refresh_status(self):
        """Update service status in my list box"""
        self.service_list.clear()

        # Put my service list into an array
        service_statuses = []
        for service in services:
            icon, status = check_service_status(service)
            service_statuses.append((service, icon, status))

        # Sort my services by name first > then by status: Active -> Inactive -> Disabled
        service_statuses.sort(key=lambda x: ("Active" not in x[2], "Disabled" in x[2]))

        # Add my sorted services to the list box
        for service, icon, status in service_statuses:
            self.service_list.addItem(f"{icon}{status} :  {service}")

        self.tray_icon.update_status()

    def manage_service(self, action):
        """Start/Stop/Restart my service"""
        selected_item = self.service_list.currentItem()
        if not selected_item:
            QMessageBox.warning(self, "No Service Selected", "Please select a service.")
            return

        service_name = selected_item.text().split(":")[-1].strip()

        subprocess.run(["systemctl", "daemon-reload"], check=True, capture_output=True)
        subprocess.run(["systemctl", action, service_name], capture_output=True)
        subprocess.run(
            ["systemctl", "is-enabled", service_name], check=True, capture_output=True
        )

        self.refresh_status()
        QTimer.singleShot(100, self.tray_icon.update_status)


class LinuxTweakTray:
    def __init__(self):
        self.app = QApplication(sys.argv)

        # Load my app icon into tray
        self.tray = QSystemTrayIcon(QIcon(app_icon))
        self.tray.setToolTip("Flatpak Service Monitor")

        # Check if my icon is loaded correctly in taskbar
        if self.tray.icon().isNull():
            print("Error: Icon is invalid!")
        else:
            print("App icon loaded successfully.")

        self.menu = QMenu()

        # Actions
        self.show_app_action = QAction("Open Service Monitor")
        self.show_app_action.triggered.connect(self.open_app)

        self.refresh_action = QAction("Refresh")
        self.refresh_action.triggered.connect(self.update_status)

        self.exit_action = QAction("Exit")
        self.exit_action.triggered.connect(self.app.quit)

        self.menu.addAction(self.show_app_action)
        self.menu.addAction(self.refresh_action)
        self.menu.addSeparator()
        self.menu.addAction(self.exit_action)

        self.tray.setContextMenu(self.menu)
        self.tray.activated.connect(self.tray_clicked)

        # Main window
        self.window = LinuxTweakMonitor(self)

        # Check & update status every 5 seconds
        self.update_status()
        self.timer = QTimer()
        self.timer.timeout.connect(self.update_status)
        self.timer.start(5000)  # == 5 seconds

        self.tray.show()
        print("Tray shown.")

    def update_status(self):
        """Update my tray icon and group services by status"""
        service_statuses = [
            (service, *check_service_status(service)) for service in services
        ]

        # Group by status
        active_services = [
            f"{icon}{status} : {service}"
            for service, icon, status in service_statuses
            if "Active" in status
        ]
        disabled_services = [
            f"{icon}{status} : {service}"
            for service, icon, status in service_statuses
            if "Disabled" in status
        ]
        inactive_services = [
            f"{icon}{status} : {service}"
            for service, icon, status in service_statuses
            if "Inactive" in status or "Error" in status
        ]

        # build tooltip text groups
        tooltip_text = ""

        if active_services:
            tooltip_text += "Active services:\n" + "\n".join(active_services) + "\n\n"
        if disabled_services:
            tooltip_text += "Disabled services:\n" + "\n".join(disabled_services) + "\n\n"
        if inactive_services:
            tooltip_text += "Inactive services:\n" + "\n".join(inactive_services) + "\n\n"

        # if no inactive or disabled services, show "All Good"
        if not disabled_services and not inactive_services:
            tooltip_text = "✔️ All Good"

        # keep icon locked to my LinuxTweaks icon
        self.tray.setToolTip(tooltip_text.strip())
        
        # Always show my LT icon
        self.tray.setIcon(QIcon(app_icon))  

    def tray_clicked(self, reason):
        """Handle clicks on tray icon"""
        if reason == QSystemTrayIcon.ActivationReason.Trigger:
            self.open_app()

    def open_app(self):
        """Show the service monitor window"""
        self.window.refresh_status()
        self.window.show()

    def run(self):
        self.app.exec()


# Main menu
if __name__ == "__main__":
    tray = LinuxTweakTray()
    tray.run()
