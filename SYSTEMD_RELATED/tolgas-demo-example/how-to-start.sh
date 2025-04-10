systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable --now tolga.timer
systemctl --user start tolga.service