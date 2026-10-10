---@diagnostic disable: undefined-global
local hl = hl or require("hyprland")

--------------------
---- LAYER RULES ----
--------------------

hl.exec_cmd("hyprctl keyword layerrule 'blur, gtk-layer-shell'")
hl.exec_cmd("hyprctl keyword layerrule 'ignorezero, gtk-layer-shell'")
hl.exec_cmd("hyprctl keyword layerrule 'blur, eww-control_center'")
hl.exec_cmd("hyprctl keyword layerrule 'blur, eww-power_menu'")
-------------------
--- KEYBINDINGS ---
-------------------

-- Toggle Control Center (SUPER + CTRL + C)
hl.bind("SUPER + CONTROL + C", hl.dsp.exec_cmd("bash ~/.config/eww/scripts/toggle_panel.sh control_center"))

-- Toggle Power Menu (SUPER + ESC)
hl.bind("SUPER + Escape", hl.dsp.exec_cmd("bash ~/.config/eww/scripts/toggle_panel.sh power_menu"))

hl.layer_rule({
	match = { namespace = "bar" },
	name = "eww-bar-blur",
	blur = true,
	ignore_alpha = 0,
})
hl.layer_rule({
    name = "eww-system-status-no-animation",
    match = {
        namespace = "eww-system-status",
    },
    no_anim = true,
})

hl.layer_rule({
    name = "eww-system-status-popup-no-animation",
    match = {
        namespace = "eww-system-status-popup",
    },
    no_anim = true,
})
hl.layer_rule({
    name = "eww-status-no-animation",
    match = {
        namespace = "^eww-status$",
    },
    no_anim = true,
})
hl.layer_rule({
    name = "eww-status-static",
    match = {
        namespace = "^eww-status$",
    },
    no_anim = true,
})
