-- Language agnostic debugger bindings.
-- The <leader>d prefix is already taken by the dotnet build maps, so debugging
-- lives under <leader>D. Per language extras are in *-dap-bindings.lua.

local dap = require("dap")
local dapui = require("dapui")

local function map(lhs, fn, desc, mode)
  vim.keymap.set(mode or "n", lhs, fn, { noremap = true, silent = true, desc = desc })
end

-- Stepping, on the keys every other debugger uses too
map("<F5>", dap.continue, "Debug: start / continue")
map("<F9>", dap.toggle_breakpoint, "Debug: toggle breakpoint")
map("<F10>", dap.step_over, "Debug: step over")
map("<F11>", dap.step_into, "Debug: step into")
map("<F12>", dap.step_out, "Debug: step out")

map("<leader>dc", dap.continue, "Debug: start / continue")
map("<leader>di", dap.step_into, "Debug: step into")
map("<leader>do", dap.step_over, "Debug: step over")
map("<leader>dO", dap.step_out, "Debug: step out")
map("<leader>dC", dap.run_to_cursor, "Debug: run to cursor")
map("<leader>dL", dap.run_last, "Debug: re-run last configuration")
map("<leader>dt", dap.terminate, "Debug: terminate session")
map("<leader>dd", dap.disconnect, "Debug: disconnect")
map("<leader>dr", dap.repl.toggle, "Debug: toggle REPL")

-- Breakpoints
map("<leader>db", dap.toggle_breakpoint, "Debug: toggle breakpoint")
map("<leader>dB", function()
  vim.ui.input({ prompt = "Breakpoint condition: " }, function(cond)
    if cond and cond ~= "" then
      dap.set_breakpoint(cond)
    end
  end)
end, "Debug: conditional breakpoint")
map("<leader>dl", function()
  vim.ui.input({ prompt = "Log point message: " }, function(msg)
    if msg and msg ~= "" then
      dap.set_breakpoint(nil, nil, msg)
    end
  end)
end, "Debug: log point")
map("<leader>dx", dap.clear_breakpoints, "Debug: clear all breakpoints")

-- Inspection
map("<leader>du", dapui.toggle, "Debug: toggle UI")
map("<leader>de", function()
  dapui.eval(nil, { enter = true })
end, "Debug: evaluate expression", { "n", "v" })
map("<leader>dw", function()
  require("dap.ui.widgets").hover()
end, "Debug: hover value")
map("<leader>df", function()
  local widgets = require("dap.ui.widgets")
  widgets.centered_float(widgets.frames)
end, "Debug: stack frames")
map("<leader>ds", function()
  local widgets = require("dap.ui.widgets")
  widgets.center(widgets.scopes)
end, "Debug: scopes")
