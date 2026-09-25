return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              buildFlags = { "-tags=integration" },
            },
          },
        },
        -- Lua LSP
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim", "Snacks" },
                disable = { "missing-fields" },
              },
            },
          },
        },
        -- Python LSP
        pyright = {},
        -- dotnet LSP
        roslyn_ls = {
          settings = {
            ["csharp|background_analysis"] = {
              dotnet_analyzer_diagnostics_scope = "openFiles",
              dotnet_compiler_diagnostics_scope = "openFiles",
            },
            ["csharp|inlay_hints"] = {
              csharp_enable_inlay_hints_for_implicit_object_creation = false,
              csharp_enable_inlay_hints_for_implicit_variable_types = false,
              csharp_enable_inlay_hints_for_indexer_parameters = false,
              csharp_enable_inlay_hints_for_lambda_parameter_types = false,
              csharp_enable_inlay_hints_for_literal_parameters = false,
              csharp_enable_inlay_hints_for_object_creation_parameters = false,
              csharp_enable_inlay_hints_for_other_parameters = false,
              csharp_enable_inlay_hints_for_parameters = false,
              csharp_enable_inlay_hints_for_types = false,
              csharp_suppress_inlay_hints_for_parameters_that_match_argument_name = false,
              dotnet_enable_inlay_hints_for_indexer_parameters = false,
              dotnet_enable_inlay_hints_for_literal_parameters = false,
              dotnet_enable_inlay_hints_for_object_creation_parameters = false,
              dotnet_enable_inlay_hints_for_other_parameters = false,
              dotnet_enable_inlay_hints_for_parameters = false,
              dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = false,
              dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = false,
              dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = false,
            },
          },
          -- This replaces lspconfig's on_init (lists merge by index), which is
          -- what normally sends solution/open. So we have to open a target here.
          on_init = {
            function(client)
              local roslyn = require("utils.roslyn-solution")
              roslyn.initRoot(client.config.root_dir)
              roslyn.open_default(client)
            end,
          },
        },
      },
    },
  },
}
