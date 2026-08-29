vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil or client.name ~= "pyright" then
      return
    end

    local function map(mode, lhs, fn, desc)
      vim.keymap.set(mode, lhs, fn, { buffer = args.buf, noremap = true, silent = true, desc = desc })
    end

    map("n", "<leader>dp", function()
      require("dap").run({
        type = "python",
        name = "Debug file",
        request = "launch",
        program = "${file}",
        console = "integratedTerminal",
        justMyCode = false,
      })
    end, "Debug: current file")
    map("n", "<leader>dn", function()
      require("dap-python").test_method()
    end, "Debug: nearest test")
    map("n", "<leader>dN", function()
      require("dap-python").test_class()
    end, "Debug: enclosing test class")
    map("v", "<leader>dv", function()
      require("dap-python").debug_selection()
    end, "Debug: selection")
  end,
})
