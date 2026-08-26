return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nsidorenco/neotest-vstest",
      "nvim-neotest/neotest-go",
      "nvim-neotest/neotest-python",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-vstest"),
          require("neotest-go"),
          require("neotest-python"),
        },
      })
    end,
  },
}
