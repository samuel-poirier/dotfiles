vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil or client.name ~= "gopls" then
      return
    end

    local function map(lhs, fn, desc)
      vim.keymap.set("n", lhs, fn, { buffer = args.buf, noremap = true, silent = true, desc = desc })
    end

    map("<leader>dp", function()
      require("dap").run({
        type = "go",
        name = "Debug package",
        request = "launch",
        program = "${fileDirname}",
      })
    end, "Debug: current package")
    map("<leader>dn", function()
      require("dap-go").debug_test()
    end, "Debug: nearest test")
    map("<leader>dN", function()
      require("dap-go").debug_last_test()
    end, "Debug: last test")
  end,
})
