-- ============================================================
-- Modular Hyprland Lua config
-- Parallel to legacy hyprland.conf — lives in lua/ so it stays
-- INERT until you activate it (see MIGRATION.md).
--
-- To test:   Hyprland -c ~/.config/hypr/lua/hyprland.lua
-- To activate (next login):
--   ln -sf lua/hyprland.lua ~/.config/hypr/hyprland.lua
-- To roll back:
--   rm ~/.config/hypr/hyprland.lua
-- ============================================================

-- Absolute package.path so require() resolves regardless of how
-- Hyprland was launched (-c path, top-level symlink, etc.)
local hypr_dir = os.getenv("HOME") .. "/.config/hypr"
package.path   = hypr_dir .. "/lua/?.lua;" .. package.path

-- Each require() is a separate Lua scope: an error in one file
-- does NOT stop execution of the others.
require("env")
require("monitors")
require("input")
require("look_and_feel")
require("window_rules")
require("keybinds")
require("autostart")
