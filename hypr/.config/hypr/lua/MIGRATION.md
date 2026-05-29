# Hyprland hyprlang → Lua migration notes

Hyprland 0.55 deprecated hyprlang in favour of Lua (`hyprland.lua`).
This directory holds the new Lua config **in parallel** with the legacy `.conf` files.
Nothing in this directory is auto-loaded until you activate it.

---

## Current state: PARALLEL (inert)

The Lua config lives in `lua/` and is **not loaded automatically** because
Hyprland's file-selection check happens once at startup.  A top-level
`hyprland.lua` does not yet exist.

---

## Activation (when you're ready)

```sh
# From ~/.config/hypr/ (which is a symlink into this repo):
ln -sf lua/hyprland.lua ~/.config/hypr/hyprland.lua
# Then log out and back in — next Hyprland launch picks up the Lua config.
```

**Roll back** at any time (before the next login) by removing the symlink:
```sh
rm ~/.config/hypr/hyprland.lua
```

---

## Testing without disrupting the running session

Open a free TTY (Ctrl+Alt+F3) and launch a nested/secondary instance:
```sh
Hyprland -c ~/.config/hypr/lua/hyprland.lua
```

Syntax-check only (no `hl.*` calls, just Lua parse):
```sh
for f in ~/.config/hypr/lua/*.lua; do
  luac -p "$f" && echo "OK: $f" || echo "SYNTAX ERROR: $f"
done
```

---

## How to regenerate colors

The Lua config reads colors from `lua/colors_wallust.lua`, which is generated
by wallust from your current wallpaper.  A committed initial copy already
exists, but you should regenerate it whenever you change your wallpaper or
want the Lua config to reflect the current palette.

### The wallust pipeline

```
wallpaper image
    │
    └─▶ wallust run <img>
            │
            ├─▶ colors-hyprland.conf  →  wallust/wallust-hyprland.conf   (legacy .conf config)
            └─▶ colors-hyprland.lua   →  lua/colors_wallust.lua          (Lua config)  ← NEW
```

The `hyprlua` entry added to `wallust.toml` makes wallust write both targets
automatically on every run.

### Step 1 — find your monitor name (if needed)

```sh
hyprctl monitors | grep "^Monitor"
# e.g.  Monitor eDP-1 (ID 0):
ls ~/.cache/awww/
# awww caches the current wallpaper path per monitor output name
```

### Step 2 — regenerate via the wallpaper script (recommended)

```sh
~/.config/hypr/scripts/wallust_swww.sh
```

This script reads the current wallpaper for the focused monitor from
`~/.cache/awww/` and calls `wallust run` on it.  Both the legacy
`wallust-hyprland.conf` and the new `lua/colors_wallust.lua` are written.

### Step 2 (alternative) — call wallust directly

```sh
# Using the awww cache for a specific monitor (e.g. eDP-1):
wallust run "$(grep -v Lanczos3 ~/.cache/awww/eDP-1 | head -1)"

# Or point at any image file directly:
wallust run /path/to/wallpaper.jpg
```

### Step 3 — reload Hyprland

```sh
hyprctl reload
```

Hyprland re-executes the config, which `require`s `colors_wallust` fresh —
equivalent to the old `source = ~/.cache/wal/colors-hyprland` in hyprlang.

### Verify colors loaded correctly

```sh
# Check the generated file looks right:
cat ~/.config/hypr/lua/colors_wallust.lua

# Check Hyprland picked up the new border color:
hyprctl getoption general:col:active_border
```

### Going forward (automatic)

Once you have activated the Lua config, every subsequent `wallust run` call
(including those triggered by `wallust_swww.sh` or `wallpaper_select.sh`)
will regenerate `colors_wallust.lua` automatically.  A manual `hyprctl reload`
is still needed to apply the new palette — this mirrors how the old config
worked with `source = ~/.cache/wal/colors-hyprland`.

---

## File mapping: old → new

| Old file (hyprlang) | New file (Lua) | Status |
|---|---|---|
| `hyprland.conf` | `lua/hyprland.lua` | ✅ ported |
| `configs/settings.conf` | `lua/autostart.lua` (initial-boot.sh exec) | ✅ ported |
| `configs/env_vars.conf` | `lua/env.lua` | ✅ ported |
| `configs/startup_apps.conf` | `lua/autostart.lua` | ✅ ported |
| `configs/monitors.conf` | `lua/monitors.lua` | ✅ ported |
| `configs/window_rules.conf` | `lua/window_rules.lua` | ✅ ported (all commented) |
| `configs/keybinds.conf` | `lua/keybinds.lua` | ✅ ported |
| `configs/user_settings.conf` | `lua/input.lua` + `lua/look_and_feel.lua` | ✅ ported |
| `wallust/wallust-hyprland.conf` (generated) | `lua/colors_wallust.lua` (generated) | ✅ new template added |

---

## Removal checklist (AFTER Lua config is verified and activated)

Remove these files/dirs only after you have confirmed the Lua config
works correctly across sessions:

- [ ] `hyprland.conf`
- [ ] `configs/settings.conf`
- [ ] `configs/env_vars.conf`
- [ ] `configs/startup_apps.conf`
- [ ] `configs/monitors.conf`
- [ ] `configs/window_rules.conf`
- [ ] `configs/keybinds.conf`
- [ ] `configs/user_settings.conf`
- [ ] `configs/` directory (once all `.conf` files above are gone)

**Keep indefinitely** (still used by Lua config and other tools):
- `scripts/` — all shell scripts referenced from `keybinds.lua` / `autostart.lua`
- `initial-boot.sh` — called from `autostart.lua`
- `wallust/` — template dir; the old hyprlang template (`wallust-hyprland.conf`)
  can be removed once the `.conf` config is gone, but keep the new `.lua` template.
- `wallust/wallust-hyprland.conf` — still generated for the legacy config;
  remove alongside `configs/user_settings.conf`.

---

## Known items to verify before activating

| Item | Details |
|---|---|
| `workspaceopt allfloat` | No `hl.dsp` dispatcher in 0.55; kept as `exec_cmd("hyprctl dispatch ...")`. Confirm the keyword still exists. |
| `hl.dsp.workspace.toggle_special()` | Called with no argument for the default special workspace. Confirm nil arg is valid. |
| `hl.dsp.window.move({ workspace = N, follow = true/false })` | Confirm `follow` semantics match old `movetoworkspace` (follow=true) vs `movetoworkspacesilent` (follow=false). |
| `hl.dsp.workspace.move({ monitor = "l" })` | Maps from `movecurrentworkspacetomonitor, l`. Confirm direction arg format. |
| `group.groupbar.col.active` field path | Confirmed in Variables wiki (line 410). Double-check at runtime. |
| `decoration.blur.new_optimizations` | Still present in 0.55 Variables wiki. Should be fine. |
| `borderangle` with `style = "loop"` | Causes constant re-rendering; intentional but impacts battery. |
| `CTRL + ALT + Delete` → `hl.dsp.exit()` | Old config used `exec, hyprctl dispatch exit 0`. `hl.dsp.exit()` is cleaner in 0.55. |
| `hl.dsp.window.resize({ x, y, relative })` | `relative = true` for relative resize. Confirm param name. |
| `col.active_border` with numeric colors array | Example config uses strings; numbers should also work. If not, wrap with `string.format("0x%08x", n)`. |

---

## Notes on differences from hyprlang

- `yes`/`no` → `true`/`false`; `1`/`0` for booleans → `true`/`false`.
- `exec-once` → `hl.on("hyprland.start", function() ... end)`.
- `exec` (with `&`) → `hl.exec_cmd(...)` (always async, no `&` needed).
- `bind`/`binde`/`bindr`/`bindm` → `hl.bind(..., { repeating, release, mouse })`.
- `bezier = NAME, X1, Y1, X2, Y2` → `hl.curve(NAME, { type="bezier", points={{X1,Y1},{X2,Y2}} })`.
- `animation = LEAF, 1, SPEED, CURVE[, STYLE]` → `hl.animation({ leaf, enabled=true, speed, bezier=CURVE, style? })`.
- `$variable = value` → `local variable = "value"` (Lua locals).
- `source = file` → `require("module")` (relative to `hyprland.lua` dir).
- Colors: hyprlang `$color2` → Lua `colors.color2` (from `colors.lua` module).
- `tap-to-click` → `tap_to_click` (hyphens → underscores in Lua keys).
