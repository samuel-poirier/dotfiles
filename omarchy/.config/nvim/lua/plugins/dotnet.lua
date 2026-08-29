return {
  -- Mason: manages installed LSPs/tools
  {
    "mason-org/mason.nvim",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry", -- has an up-to-date roslyn build
      },
    },
  },

  -- Treesitter grammar for C#
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "c_sharp" } },
  },
}
