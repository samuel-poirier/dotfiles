-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

--------------------------------
-- Application bindings
--------------------------------

hl.unbind("SUPER + Return")
hl.unbind("SUPER + SHIFT + S")

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

-- Returns all connected monitors sorted left-to-right by position.
-- Works regardless of monitor names/models, so it holds up across
-- different setups (home vs office).

local workspace_range = 10

local function get_sorted_monitors()
	local mons = hl.get_monitors()
	table.sort(mons, function(a, b)
		return a.x < b.x
	end)
	return mons
end

-- Assign workspace ranges: leftmost monitor gets 1-10, next gets 11-20, etc.
local function assign_workspace_rules()
	local mons = get_sorted_monitors()
	for idx, mon in ipairs(mons) do
		local base = (idx - 1) * workspace_range
		for n = 1, workspace_range do
			hl.workspace_rule({ workspace = tostring(base + n), monitor = mon.name })
		end
	end
end

assign_workspace_rules()

-- Re-run whenever the monitor setup changes (docking, plugging in, etc.)
hl.on("monitor.added", assign_workspace_rules)
hl.on("monitor.removed", assign_workspace_rules)
hl.on("monitor.layout_changed", assign_workspace_rules)

-- Switch every monitor to its own "slot n" at once
local function switch_all(n)
	return function()
		local mons = get_sorted_monitors()
		for idx, mon in ipairs(mons) do
			local base = (idx - 1) * workspace_range
			local target = tostring(base + n)

			hl.dispatch(hl.dsp.focus({ monitor = mon.name }))
			hl.dispatch(hl.dsp.focus({ workspace = target, on_current_monitor = true }))
		end
	end
end

local function move_and_switch_all(n)
	return function()
		local win = hl.get_active_window()

		if win then
			local mons = get_sorted_monitors()
			local mon_idx = nil
			for idx, mon in ipairs(mons) do
				if mon.name == win.monitor.name then
					mon_idx = idx
					break
				end
			end

			if mon_idx then
				local base = (mon_idx - 1) * 10
				local target = tostring(base + n)
				hl.dispatch(hl.dsp.window.move({ workspace = target, follow = true }))
			end
		end

		-- reuse the same sync logic so every other monitor flips too
		switch_all(n)()
	end
end
for n = 1, workspace_range do
	local key = (n == 10) and "0" or tostring(n)

	hl.unbind("SUPER+" .. key)
	hl.unbind("SUPER+SHIFT+" .. key)

	hl.bind("SUPER+" .. key, switch_all(n), { description = "Switch all monitors to slot " .. n })
	hl.bind(
		"SUPER+SHIFT+" .. key,
		move_and_switch_all(n),
		{ description = "Move window and switch all monitors to slot " .. n }
	)
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
