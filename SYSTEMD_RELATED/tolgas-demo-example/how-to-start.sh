systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable --now tolga.timer
systemctl --user start tolga.service
systemctl --user status tolga.timer
sudo loginctl enable-linger tolga
systemctl --user list-timers | grep tolga
