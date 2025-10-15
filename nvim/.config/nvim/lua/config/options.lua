-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.lazyvim_picker = "telescope"

vim.lsp.config("roslyn", {
  cmd = {
    "~/.dotnet/dotnet",
    "~/csharp-ls/content/LanguageServer/linux-x64/Microsoft.CodeAnalysis.LanguageServer.dll",
    "--logLevel=Information",
    "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
    "--stdio", -- Flag does not exist on this version
  },
})

vim.lsp.config("gopls", {})

vim.lsp.config("typescript-language-server", {})
