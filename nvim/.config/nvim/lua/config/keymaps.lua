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
map("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
map("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })

-- LSP Keymaps

local opts = { noremap = true, silent = true }
opts.desc = "Show LSP references"
map("n", "gu", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references
map("n", "<Leader>fo", "<cmd>Telescope lsp_document_symbols<CR>", opts) -- show definition, references
map("n", "<Leader>ft", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", opts) -- show definition, references

opts.desc = "Show LSP definitions"
map("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

opts.desc = "Show LSP implementations"
map("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

opts.desc = "Show LSP type definitions"
map("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

opts.desc = "See available code actions"

opts.desc = "Show buffer diagnostics"
map("n", "<C-m>", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

opts.desc = "Restart LSP"
map("n", "<leader>R", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary

opts.desc = "Go to declaration"
map("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

opts.desc = "Smart rename"
map("n", "<leader>r", vim.lsp.buf.rename, opts) -- smart rename

-- neotest keymap

local neotest = require("neotest")

opts.desc = "Run test file"
map("n", "<Leader>tr", function()
  neotest.run.run(vim.fn.expand("%"))
end, opts)

local cmp = require("cmp")

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item
  }),
})
