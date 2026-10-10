-----------------------------
--------- XDG ---------------
-----------------------------
hl.window_rule({
	match = {
		class = "^(xdg-desktop-portal-gtk)$",
	},
	float = true,
	center = true,
	size = { 800, 600 },
})

hl.window_rule({
	match = {
		title = "^(Open File|Save File|All Files)$",
	},
	float = true,
	center = true,
})

-- Hyprland-run windowrule
hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = "20 monitor_h-120",
	float = true,
})

-- Move kitty to 100 100 and add an anim style (named rule)
hl.window_rule({
	name = "move-kitty",
	match = { class = "kitty" },
	move = { 100, 100 },
	animation = "popin",
})

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

hl.window_rule({
	match = { class = "kitty" },
	float = true,
	size = "1150 650",
	center = true,
})

local float_apps = {
	"xdg-desktop-portal-gtk",
	"io.bassi.Amberol",
	"python3",
	"org.gnome.Loupe",
	"com.github.huluti.Curtail",
	"dev.bragefuglseth.Fretboard",
	"eww",
	"com.github.GradienceTeam.Gradience",
	"pavucontrol",
	"blueman-manager",
	"nm-connection-editor",
	"blueberry.py",
	"Color Picker",
	"Network",
	"xdg-desktop-portal",
	"xdg-desktop-portal-hyprland",
	"xdg-desktop-portal-gnome",
	"io.github.nate_xyz.Chromatic",
	"it.mijorus.whisper",
	"io.github.giantpinkrobots.flatsweep",
	"VirtualBox Machine",
	"org.gnome.Nautilus",
	"floatterm",
	"moe.launcher.an-anime-game-launcher",
	"org.gnome.clocks",
	"org.gnome.Calculator",
	"io.github.kaii_lb.Overskride",
	"org.matplotlib.Matplotlib3",
	"org.gnome.Decibels",
	"org.kde.dolphin",
	"org.kde.gwenviewsudo",
	"io.github.nokse22.trivia-quiz",
	"com.saivert.pwvucontrol",
	"io.missioncenter.MissionCenter",
	"org.kde.plasmashell",
	"pavucontrol-qt",
	"hu.irl.cameractrls",
	"org.freedesktop.impl.portal.desktop.kde",
	"mpv",
	"org.fooyin.fooyin",
	"zoom",
}

hl.window_rule({
	name = "Float Windows",
	match = {
		class = table.concat(float_apps, "|"),
	},
	float = true,
})

local small_float_apps = {
	"org.gnome.Calculator",
	"Color Picker",
	"blueman-manager",
}

local large_float_apps = {
	"org.kde.dolphin",
	"VirtualBox Machine",
	"org.gnome.Nautilus",
}

hl.window_rule({
	match = { class = table.concat(small_float_apps, "|") },
	float = true,
	size = "400 500",
	center = true,
})

hl.window_rule({
	match = { class = table.concat(large_float_apps, "|") },
	float = true,
	size = "1000 700",
	center = true,
})
