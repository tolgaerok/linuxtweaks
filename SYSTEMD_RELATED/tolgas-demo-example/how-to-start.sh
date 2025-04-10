# download LinuxTweaks icon
sudo mkdir -p /usr/local/bin/LinuxTweaks/images
sudo wget -O /usr/local/bin/LinuxTweaks/images/LinuxTweak.png https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/MY_PYTHON_APP/images/LinuxTweak.png
sudo chmod 644 /usr/local/bin/LinuxTweaks/images/LinuxTweak.png

systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable --now tolga.timer
systemctl --user start tolga.service
systemctl --user status tolga.timer
sudo loginctl enable-linger tolga
systemctl --user list-timers | grep tolga
