-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

--------------------------------
-- Application bindings
--------------------------------

hl.bind(
	"SUPER + Return",
	hl.dsp.exec_cmd(
		[[uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)" bash -c "tmux attach || tmux new -s Work"]]
	),
	{ description = "Tmux" }
)
hl.bind(
	"SUPER + SHIFT + Return",
	hl.dsp.exec_cmd([[uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)"]]),
	{ description = "Terminal" }
)
hl.bind("SUPER + I", hl.dsp.exec_cmd("omarchy-launch-browser"), { description = "Browser" })
hl.bind("SUPER + SHIFT + F", hl.dsp.exec_cmd("uwsm-app -- nautilus --new-window"), { description = "File manager" })
hl.bind(
	"SUPER + ALT + SHIFT + F",
	hl.dsp.exec_cmd([[uwsm-app -- nautilus --new-window "$(omarchy-cmd-terminal-cwd)"]]),
	{ description = "File manager (cwd)" }
)
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("omarchy-launch-browser"), { description = "Browser" })
hl.bind(
	"SUPER + SHIFT + ALT + B",
	hl.dsp.exec_cmd("omarchy-launch-browser --private"),
	{ description = "Browser (private)" }
)
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("omarchy-launch-or-focus spotify"), { description = "Music" })
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("omarchy-launch-editor"), { description = "Editor" })
hl.bind("SUPER + SHIFT + D", hl.dsp.exec_cmd("omarchy-launch-tui lazydocker"), { description = "Docker" })
-- hl.bind("SUPER + SHIFT + G", hl.dsp.exec_cmd([[omarchy-launch-or-focus ^signal$ "uwsm-app -- signal-desktop"]]), { description = "Signal" })
hl.bind(
	"SUPER + SHIFT + O",
	hl.dsp.exec_cmd([[omarchy-launch-or-focus ^obsidian$ "uwsm-app -- obsidian -disable-gpu --enable-wayland-ime"]]),
	{ description = "Obsidian" }
)
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("uwsm-app -- typora --enable-wayland-ime"), { description = "Typora" })
hl.bind("SUPER + SHIFT + SLASH", hl.dsp.exec_cmd("uwsm-app -- 1password"), { description = "Passwords" })

--------------------------------
-- Focus / window movement
--------------------------------

hl.unbind("SUPER + H")
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")

hl.bind("SUPER + H", hl.dsp.focus({ direction = "left" }), { description = "Focus Left" })
hl.bind("SUPER + J", hl.dsp.focus({ direction = "down" }), { description = "Focus Down" })
hl.bind("SUPER + K", hl.dsp.focus({ direction = "up" }), { description = "Focus Up" })
hl.bind("SUPER + L", hl.dsp.focus({ direction = "right" }), { description = "Focus Right" })

hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ direction = "left" }), { description = "Move Window Left" })
hl.bind("SUPER + SHIFT + J", hl.dsp.window.move({ direction = "down" }), { description = "Move Window Down" })
hl.bind("SUPER + SHIFT + K", hl.dsp.window.move({ direction = "up" }), { description = "Move Window Up" })
hl.bind("SUPER + SHIFT + L", hl.dsp.window.move({ direction = "right" }), { description = "Move Window Right" })

-- Move active window to special workspace (scratchpad)
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:scratchpad" }))

hl.bind(
	"SUPER + M",
	hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }),
	{ description = "Full width" }
)

--------------------------------
-- Workspace switching / moving
--------------------------------

for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind("SUPER + " .. key, hl.dsp.exec_cmd("~/.config/hypr/switch-workspace.sh " .. i))
	hl.bind("SUPER + SHIFT + " .. key, hl.dsp.exec_cmd("~/.config/hypr/move-to-workspace.sh " .. i))
end

hl.unbind("MODIFIER + F9")

--------------------------------
-- Cursor
--------------------------------

hl.config({
	cursor = {
		no_warps = true,
	},
})

--------------------------------
-- Monitor profiles
--------------------------------

hl.bind("SUPER + CTRL + ALT + P", hl.dsp.exec_cmd([[hyprmoncfg apply "Laptop Only" --confirm-timeout 0]]))
hl.bind("SUPER + CTRL + ALT + 1", hl.dsp.exec_cmd([[hyprmoncfg apply "Laptop Only" --confirm-timeout 0]]))
hl.bind("SUPER + CTRL + ALT + 2", hl.dsp.exec_cmd([[hyprmoncfg apply "Home Office" --confirm-timeout 0]]))
hl.bind("SUPER + CTRL + ALT + 3", hl.dsp.exec_cmd([[hyprmoncfg apply "Office" --confirm-timeout 0]]))
