return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nsidorenco/neotest-vstest",
      "nvim-neotest/neotest-go",
      "nvim-neotest/neotest-python",
      -- needed by the "dap" strategy (<leader>td)
      "mfussenegger/nvim-dap",
    },
    -- neotest-vstest takes its whole configuration from this global and reads it
    -- when the module is first required, so it has to be set before `config`.
    init = function()
      --- @type neotest-vstest.Config
      vim.g.neotest_vstest = {
        -- The adapter locates vstest.console.dll by grepping `dotnet --info` for
        -- "Base Path:", which only matches an English cli, and otherwise falls
        -- back to a macOS install path. Resolve it from the filesystem instead;
        -- without it discovery silently finds nothing.
        sdk_path = require("utils/dotnet-sdk").vstest_path(),
        -- merged into the config handed to nvim-dap when debugging a test
        dap_settings = { type = "netcoredbg" },
      }

      -- The adapter looks for the solution roslyn.nvim picked. We have our own
      -- picker, so hand it the same target: with no solution, or the wrong one,
      -- every project fails the "is it in this solution" check and the adapter
      -- reports each file as a non-test file. .slnf is not supported upstream.
      local target = require("utils/roslyn-solution").resolve()
      if target and target:match("%.slnx?$") then
        vim.g.roslyn_nvim_selected_solution = target
      end
    end,
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-vstest"),
          require("neotest-go"),
          require("neotest-python")({
            pytest_discovery = true,
            runner = "pytest",
            dap = { justMyCode = false },
          }),
        },
      })
    end,
  },
}
