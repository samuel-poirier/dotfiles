return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nsidorenco/neotest-vstest",
			"nvim-neotest/neotest-go",
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-vstest"),
					require("neotest-go"),
				},
			})
		end,
	},
}
