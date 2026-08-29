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
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-vstest")({
            -- merged into the config handed to nvim-dap when debugging a test
            dap_settings = { type = "netcoredbg" },
          }),
          require("neotest-go")({
            -- route debug runs through nvim-dap-go instead of plain `go test`
            dap_go_enabled = true,
          }),
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
