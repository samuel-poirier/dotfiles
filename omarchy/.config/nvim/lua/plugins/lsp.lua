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
							},
						},
					},
				},
				pyright = {},
				-- Python LSP
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
					on_init = {
						function(client)
							local root_dir = client.config.root_dir
							require("utils.roslyn-solution").initRoot(root_dir)
						end,
					},
				},
				setup = {
					-- Use a wildcard fallback or explicit setups if you want to alter the 0.12 logic
					["*"] = function(server, opts)
						-- LazyVim natively handles mapping this block into Neovim 0.12's
						-- native vim.lsp.config(server, opts) and vim.lsp.enable(server) loop.
					end,
				},
			},
		},
	},
}
