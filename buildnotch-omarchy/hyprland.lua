-- Omarchy 4.x (Hyprland Lua config). Omarchy 3.x uses .conf: see hyprland.conf.
-- Add each block to the file named above it, or run `./install.sh --hypr`.

-- ~/.config/hypr/autostart.lua
o.launch_on_start("buildnotch")

-- ~/.config/hypr/bindings.lua
-- SUPER+` is Omarchy's scratchpad on 4.5+, so the notch toggle is SUPER+ALT+N (set "toggleHint" in config.json if you change it).
o.bind("SUPER + ALT + N", "BuildNotch: toggle", hl.dsp.global("buildnotch:toggle"))
o.bind("SUPER + ALT + V", "BuildNotch: clipboard history", hl.dsp.global("buildnotch:clipboard"))

-- ~/.config/hypr/bindings.lua (or hyprland.lua): pop-out focus timer and blur behind the notch
o.window({ title = "^(BuildNotch Timer)$" }, {
  float = true,
  pin = true,
  move = { "(monitor_w-window_w-40)", "80" },
})
hl.layer_rule({ match = { namespace = "^buildnotch$" }, blur = true, ignore_alpha = 0.3 })
