# MacOs

## Yabai

To Exclude new windows from tiling look for the window name with following query:

```bash
yabai -m query --windows | jq ".[] | { App: .app, Title: .title }"
```

Replace DP-1 with the actual monitor

```bash
xrandr --output DP-1 --primary
```

# Hyprland

## Hypridle setup

hypridle is managed by a systemd user service. Enable it with:

```bash
systemctl --user daemon-reload
systemctl --user enable --now hypridle.service
```

Verify it's running:

```bash
systemctl --user status hypridle
```
