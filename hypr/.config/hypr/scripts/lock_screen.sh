#!/bin/bash
# Redirects all lock paths (keybind, waybar, wlogout, swayidle) through
# loginctl, which fires hypridle's lock_cmd → watchdog → hyprlock.
pkill -x hyprlock 2>/dev/null
loginctl lock-session
