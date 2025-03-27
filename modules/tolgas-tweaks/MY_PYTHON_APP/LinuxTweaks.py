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

# my custom systemD services to monitor
SERVICES = [
    "tolga-apply-cake-qdisc-wake.service",
    "tolga-apply-cake-qdisc.service",
    "tolga-flatpak-update.service",    
]

# Icons for tray && tooltip
APP_ICON = "/usr/local/bin/LinuxTweaks/images/LinuxTweak.png"
ICON_AMBER = "🛡️"
ICON_GREEN = "✔️"
ICON_RED = "⚠️"


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
            return ICON_GREEN, " Active   "
        elif enabled_status == "disabled":
            return ICON_AMBER, " Disabled"
        else:
            return ICON_RED, " Inactive"
    except Exception:
        return ICON_RED, " Error"


class LinuxTweakMonitor(QWidget):
    def __init__(self, tray_icon):
        super().__init__()
        self.tray_icon = tray_icon
        self.setWindowTitle("LinuxTweak Service Monitor")
        self.setGeometry(100, 100, 350, 300)
        self.layout = QVBoxLayout()

        # my service List
        self.service_list = QListWidget()
        self.layout.addWidget(self.service_list)

        # buttons
        self.start_button = QPushButton("Start Service")
        self.stop_button = QPushButton("Stop Service")
        self.restart_button = QPushButton("Restart Service")
        self.layout.addWidget(self.start_button)
        self.layout.addWidget(self.stop_button)
        self.layout.addWidget(self.restart_button)

        # action buttons
        self.start_button.clicked.connect(lambda: self.manage_service("start"))
        self.stop_button.clicked.connect(lambda: self.manage_service("stop"))
        self.restart_button.clicked.connect(lambda: self.manage_service("restart"))

        self.setLayout(self.layout)
        self.refresh_status()

    def refresh_status(self):
        """update service status in my list box"""
        self.service_list.clear()

        # put my service list into an arry
        service_statuses = []
        for service in SERVICES:
            icon, status = check_service_status(service)
            # self.service_list.addItem(f"{icon} {service}: {status}")
            service_statuses.append((service, icon, status))

        # sort my services by name first > then by status: Active -> Inactive -> Disabled
        service_statuses.sort(key=lambda x: ("Active" not in x[2], "Disabled" in x[2]))

        # add my sorted services to the list box
        for service, icon, status in service_statuses:
            self.service_list.addItem(f"{icon}{status} :  {service}")

        self.tray_icon.update_status()

    def manage_service(self, action):
        """Start/Stop/Restart my service"""
        selected_item = self.service_list.currentItem()
        if not selected_item:
            QMessageBox.warning(self, "No Service Selected", "Please select a service.")
            return

        # service_name = selected_item.text().split(" ")[1]
        # service_name = selected_item.text().split(" ")[1].strip(":")
        service_name = selected_item.text().split(":")[-1].strip()

        subprocess.run(["systemctl", "daemon-reload"], check=True, capture_output=True)
        subprocess.run(["systemctl", action, service_name], capture_output=True)
        subprocess.run(
            ["systemctl", "is-enabled", service_name], check=True, capture_output=True
        )
        
        self.refresh_status()
        QTimer.singleShot(100, self.tray_icon.update_status)
        # self.timer.stop()
        # self.timer.start(1000)


class LinuxTweakTray:
    def __init__(self):
        self.app = QApplication(sys.argv)

        # Load my app icon into tray
        self.tray = QSystemTrayIcon(QIcon(APP_ICON))
        self.tray.setToolTip("Flatpak Service Monitor")

        # check if the icon is loaded correctly in taskbar
        if self.tray.icon().isNull():
            print("Error: Icon is invalid!")
        else:
            print("App icon loaded successfully.")

        self.menu = QMenu()

        # actions
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

        # check && update status every 5 seconds
        self.update_status()
        self.timer = QTimer()
        self.timer.timeout.connect(self.update_status)
        self.timer.start(5000)  # == 5 seconds

        self.tray.show()
        print("Tray shown.")

    def update_status(self):
        """update my tray icon and tooltip"""
        statuses = [check_service_status(service) for service in SERVICES]
        tooltip_text = "\n".join(
            [
                f"{icon} {service}: {status}"
                for service, (icon, status) in zip(SERVICES, statuses)
            ]
        )

        # always show my LinuxTweaks app icon in the tray
        self.tray.setToolTip(tooltip_text)
        self.tray.setIcon(QIcon(APP_ICON))  # lock to show my LT icon

    def tray_clicked(self, reason):
        """handle clicks on tray icon"""
        if reason == QSystemTrayIcon.ActivationReason.Trigger:
            self.open_app()

    def open_app(self):
        """show the service monitor window"""
        self.window.refresh_status()
        self.window.show()

    def run(self):
        self.app.exec()

# Main menu
if __name__ == "__main__":
    tray = LinuxTweakTray()
    tray.run()
