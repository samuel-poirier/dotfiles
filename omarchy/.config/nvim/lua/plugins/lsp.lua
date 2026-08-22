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
								globals = { "vim" },
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
							csharp_enable_inlay_hints_for_lambda_parameter_types = false,
							csharp_enable_inlay_hints_for_types = false,
							csharp_enable_inlay_hints_for_other_parameters = false,
							csharp_suppress_inlay_hints_for_parameters_that_match_argument_name = false,
							csharp_enable_inlay_hints_for_parameters = false,
							csharp_enable_inlay_hints_for_literal_parameters = false,
							csharp_enable_inlay_hints_for_object_creation_parameters = false,
							csharp_enable_inlay_hints_for_indexer_parameters = false,
						},
					},
					on_init = {
						function(client)
							local root_dir = client.config.root_dir
							vim.bo.errorformat = "%f(%l\\,%c): %t%*[^ ] %m"
							local dotnetModule = require("../utils/dotnet-module")
							for entry, type in vim.fs.dir(root_dir) do
								if
									type == "file"
									and entry:match("%.slnx?$")
									and not vim.tbl_contains(dotnetModule.ignored_solutions, entry)
								then
									client:notify("solution/open", {
										solution = vim.uri_from_fname(vim.fs.joinpath(root_dir, entry)),
									})
									return
								end
							end

							-- fallback: no acceptable solution found, load csproj files instead
							local projects = {}
							for entry, type in vim.fs.dir(root_dir) do
								if type == "file" and entry:match("%.csproj$") then
									table.insert(projects, vim.uri_from_fname(vim.fs.joinpath(root_dir, entry)))
								end
							end
							if #projects > 0 then
								client:notify("project/open", { projects = projects })
							end
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
