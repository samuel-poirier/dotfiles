-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Basic settings
vim.o.number = true -- Enable line numbers
vim.o.relativenumber = true -- Enable relative line numbers
vim.o.tabstop = 2 -- Number of spaces a tab represents
vim.o.shiftwidth = 2 -- Number of spaces for each indentation
vim.o.expandtab = true -- Convert tabs to spaces
vim.o.smartindent = true -- Automatically indent new lines
vim.o.wrap = false -- Disable line wrapping
vim.o.autoindent = true
vim.o.swapfile = false
vim.o.winborder = "rounded"
vim.g.mapleader = " " -- Space as the leader key
local map = vim.keymap.set

map("n", "<Leader>w", ":w<CR>", { noremap = true, silent = true, desc = "Save" })
map("n", "<Leader>q", ":q!<CR>", { noremap = true, silent = true, desc = "Quit" })
map("n", "<Leader>v", ":vsplit<CR><C-w>l", { noremap = true, silent = true, desc = "Vertical split" })
map("n", "<Leader>s", ":split<CR><C-w>j", { noremap = true, silent = true, desc = "Horizontal split" })
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { noremap = true, silent = true, desc = "Clear highlight" })

map("v", "J", ":m '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "Move lines down" })
map("v", "K", ":m '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "Move lines up" })
map("v", "ie", "vgg0vG$", { noremap = true, silent = true, desc = "Select all" })

map("v", ">", ">gv", { noremap = true, silent = true, desc = "Indent right" })
map("v", "<", "<gv", { noremap = true, silent = true, desc = "Indent left" })

map("x", "<Leader>p", '"_dP', { noremap = true, silent = true, desc = "Paste and preserve yank" })
map("n", "Y", '"+y', { noremap = true, silent = true, desc = "Copy to clipboard" })
map("v", "Y", '"+y', { noremap = true, silent = true, desc = "Copy to clipboard" })
map("n", "Q", "<nop>", { noremap = true, silent = true, desc = "Nothing" })

map("n", "<C-Up>", "<C-W>-<C-W>-", { noremap = true, silent = true, desc = "Resize buffer up" })
map("n", "<C-Down>", "<C-W>+<C-W>+", { noremap = true, silent = true, desc = "Resize buffer down" })
map("n", "<C-Right>", "<C-W><<C-W><", { noremap = true, silent = true, desc = "Resize buffer Right" })
map("n", "<C-Left>", "<C-W>><C-W>>", { noremap = true, silent = true, desc = "Resize buffer Left" })

map("i", "jj", "<Esc>", { noremap = true, silent = true, desc = "Escape insert mode" })

map("n", "<tab>", "<cmd>bnext<cr>", { noremap = true, silent = true, desc = "Next Buffer" })
map("n", "<s-tab>", "<cmd>bprevious<cr>", { noremap = true, silent = true, desc = "Previous Buffer" })

-- LSP Keymaps

local opts = { noremap = true, silent = true }

opts.desc = "Goto Definition"
map("n", "gd", function()
  Snacks.picker.lsp_definitions()
end, opts)

opts.desc = "References (Snacks)"
map("n", "gu", function()
  Snacks.picker.lsp_references()
end, opts)

opts.desc = "Goto Implementation"
map("n", "gi", function()
  Snacks.picker.lsp_implementations()
end, opts)

opts.desc = "Goto Type Definition"
map("n", "gt", function()
  Snacks.picker.lsp_type_definitions()
end, opts)

opts.desc = "Document Symbols"
map("n", "fo", function()
  Snacks.picker.lsp_symbols({ filter = LazyVim.config.kind_filter })
end, opts)

vim.keymap.del("n", "<leader>ft")
opts.desc = "Workspace Symbols"
map("n", "ft", function()
  Snacks.picker.lsp_workspace_symbols({ filter = LazyVim.config.kind_filter })
end, opts)

vim.keymap.del("n", "<leader>ff")
opts.desc = "Find files (cwd)"
map("n", "ff", function()
  Snacks.picker.files()
end, opts)

vim.keymap.del("n", "<leader>fF")
opts.desc = "Find files (root)"
map("n", "fF", function()
  Snacks.picker.files({ cwd = Snacks.git.get_root() })
end, opts)

opts.desc = "Grep (cwd)"
map("n", "fs", function()
  Snacks.picker.grep({ cwd = vim.fn.getcwd() })
end, opts)

---

-- { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition", has = "definition" },
-- { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
-- { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
-- { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
-- { "<leader>ss", function() Snacks.picker.lsp_symbols({ filter = LazyVim.config.kind_filter }) end, desc = "LSP Symbols", has = "documentSymbol" },
-- { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols({ filter = LazyVim.config.kind_filter }) end, desc = "LSP Workspace Symbols", has = "workspace/symbols" },
-- { "gai", function() Snacks.picker.lsp_incoming_calls() end, desc = "C[a]lls Incoming", has = "callHierarchy/incomingCalls" },
-- { "gao", function() Snacks.picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing", has = "callHierarchy/outgoingCalls" },

---

-- opts.desc = "Show buffer diagnostics"
-- map("n", "<C-m>", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

opts.desc = "Smart rename"
map("n", "<leader>r", vim.lsp.buf.rename, opts) -- smart rename

-- -- neotest keymap
--
-- local neotest = require("neotest")
--
-- opts.desc = "Run test file"
-- map("n", "<Leader>tr", function()
--   neotest.run.run(vim.fn.expand("%"))
-- end, opts)
--
-- local cmp = require("cmp")
--
-- cmp.setup({
--   mapping = cmp.mapping.preset.insert({
--     ["<Tab>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item
--   }),
-- })
--
-- -- Http client plugin
-- local kulala = require("kulala")
-- opts.desc = "Send HTTP Request"
-- map("n", "<leader>Rs", kulala.run, opts)
--
-- opts.desc = "Send All HTTP Request"
-- map("n", "<leader>Ra", kulala.run_all, opts)
