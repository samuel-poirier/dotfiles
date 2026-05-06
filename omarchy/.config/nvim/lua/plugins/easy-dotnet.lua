return {
  "GustavEikaas/easy-dotnet.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
  config = function()
    require("easy-dotnet").setup({
      test_runner = {
        mapping = {
          run_test_from_buffer = { lhs = "<leader>rt", desc = "run test from buffer" },
          run_all_tests_from_buffer = { lhs = "<leader>ra", desc = "Run all tests in file" },
          get_build_errors = { lhs = "<leader>e", desc = "get build errors" },
          peek_stack_trace_from_buffer = { lhs = "<leader>p", desc = "peek stack trace from buffer" },
          debug_test_from_buffer = { lhs = "<leader>d", desc = "run test from buffer" },
          debug_test = { lhs = "<leader>rd", desc = "debug test" },
          go_to_file = { lhs = "g", desc = "go to file" },
          run_all = { lhs = "<leader>RA", desc = "run all tests" },
          run = { lhs = "<leader>rt", desc = "run test" },
          peek_stacktrace = { lhs = "<leader>p", desc = "peek stacktrace of failed test" },
          expand = { lhs = "o", desc = "expand" },
          expand_node = { lhs = "E", desc = "expand node" },
          collapse_all = { lhs = "W", desc = "collapse all" },
          close = { lhs = "q", desc = "close testrunner" },
          refresh_testrunner = { lhs = "<C-r>", desc = "refresh testrunner" },
          cancel = { lhs = "<C-c>", desc = "cancel in-flight operation" },
        },
      },
    })
  end,
}
