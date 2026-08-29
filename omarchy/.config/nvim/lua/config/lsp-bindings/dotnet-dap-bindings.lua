local dotnet = require("utils/dotnet-dap")

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil or client.name ~= "roslyn_ls" then
      return
    end

    local function map(lhs, fn, desc)
      vim.keymap.set("n", lhs, fn, { buffer = args.buf, noremap = true, silent = true, desc = desc })
    end

    map("<leader>dp", dotnet.launch, "Debug: build and launch a project")
    map("<leader>da", dotnet.attach, "Debug: attach to a running .NET process")
    map("<leader>dn", function()
      require("neotest").run.run({ strategy = "dap" })
    end, "Debug: nearest test (vstest)")
  end,
})
