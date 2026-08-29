return {
  -- Debug adapters, installed through Mason like the rest of the tooling
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "netcoredbg", -- dotnet / C#
        "debugpy", -- python
        "delve", -- go
      },
    },
  },

  -- Core DAP client, UI and inline variable values
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      ---------------------------------------------------------------- ui

      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        layouts = {
          {
            position = "left",
            size = 45,
            elements = {
              { id = "scopes", size = 0.35 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
              { id = "breakpoints", size = 0.15 },
            },
          },
          {
            position = "bottom",
            size = 12,
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
          },
        },
        floating = { border = "rounded" },
      })

      require("nvim-dap-virtual-text").setup({
        commented = true,
        virt_text_pos = "eol",
      })

      dap.listeners.after.event_initialized["dapui"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui"] = function()
        dapui.close()
      end

      for name, sign in pairs({
        DapBreakpoint = { "●", "DiagnosticError" },
        DapBreakpointCondition = { "◆", "DiagnosticWarn" },
        DapBreakpointRejected = { "○", "DiagnosticError" },
        DapLogPoint = { "◆", "DiagnosticInfo" },
      }) do
        vim.fn.sign_define(name, { text = sign[1], texthl = sign[2], numhl = sign[2] })
      end
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", linehl = "Visual" })

      ---------------------------------------------------------------- dotnet

      local mason_bin = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin")
      local netcoredbg = vim.fs.joinpath(mason_bin, "netcoredbg")
      if vim.fn.executable(netcoredbg) == 0 then
        netcoredbg = "netcoredbg"
      end

      dap.adapters.coreclr = {
        type = "executable",
        command = netcoredbg,
        args = { "--interpreter=vscode" },
      }
      -- neotest-vstest asks for an adapter named "netcoredbg"; same binary.
      dap.adapters.netcoredbg = dap.adapters.coreclr

      local dotnet = require("utils/dotnet-dap")

      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "Launch: pick project",
          request = "launch",
          -- builds the picked project and hands back its dll
          program = dotnet.pick_dll,
          cwd = "${workspaceFolder}",
          stopAtEntry = false,
          justMyCode = false,
        },
        {
          type = "coreclr",
          name = "Attach to process",
          request = "attach",
          processId = require("dap.utils").pick_process,
        },
      }
      dap.configurations.fsharp = dap.configurations.cs
    end,
  },

  -- go: delve adapter + "debug nearest test" helpers
  {
    "leoluz/nvim-dap-go",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-go").setup({
        delve = {
          -- detached delve survives a nvim crash on unix; not supported on windows
          detached = vim.fn.has("win32") == 0,
        },
      })
    end,
  },

  -- python: debugpy adapter, run from the venv mason installed it into
  {
    "mfussenegger/nvim-dap-python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local debugpy = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "packages", "debugpy", "venv", "bin", "python")
      local dap_python = require("dap-python")
      dap_python.setup(vim.fn.executable(debugpy) == 1 and debugpy or "python3")
      -- match the runner neotest-python is configured with
      dap_python.test_runner = "pytest"
    end,
  },
}
