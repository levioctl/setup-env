--- tab settings
vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")

--- search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true

--- markings
vim.wo.number = true

--- editing
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = {
    "*/COMMIT_EDITMSG",
  },
  callback = function(ev)
      vim.opt.colorcolumn = "72"
  end
})

--- lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

--- lazy settings, plugins to install

local plugins = {
  {
      'nvim-telescope/telescope.nvim', tag = '0.1.6',
      dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' }
  },
  {
      'dstein64/nvim-scrollview',
      signs_on_startup = {'all'}
  },
  {
      'neovim/nvim-lspconfig'
  },
    {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup {}
  end,
  }
}


local opts = {}
require("lazy").setup(plugins, opts)

--- keybindings - editor navigation
vim.keymap.set('n', '<C-h>', 'gT', {})
vim.keymap.set('n', '<C-l>', 'gt', {})
vim.keymap.set('n', '<Enter>', ':noh<cr>', {})
vim.keymap.set('n', '<C-j>', '<C-e>', {})
vim.keymap.set('n', '<C-k>', '<C-y>', {})
vim.keymap.set('n', '<M-]>', ']]zz', {})
vim.keymap.set('n', '<M-[>', '[[zz', {})

--- keybindings

local telescope = require("telescope.builtin")
local nvimtree = require "nvim-tree.api"

vim.keymap.set('n', '<C-f>', ":%s/\\<<C-r><C-w>\\>//g<Left><Left>", {})   --- quick search-replace

vim.keymap.set('n', '<C-p>', telescope.git_files, {}) --- files fuzzy search
vim.keymap.set('n', '<C-f', telescope.grep_string, {}) -- grep string
vim.keymap.set('n', '<C-b>', telescope.buffers, {})   --- list tabs

vim.keymap.set('n', '<leader>t', ':NvimTreeFindFileToggle<cr>', {}) --- show tree
vim.keymap.set('n', '<leader>h', nvimtree.tree.toggle_help, {}) --- show tree commands

vim.keymap.set('n', '<leader>o', telescope.treesitter, {}) --- show outline (non LSP)
vim.keymap.set('n', '<leader>r', telescope.lsp_references, {}) --- list references
vim.keymap.set('n', '<leader>s', telescope.lsp_document_symbols, {}) --- show buffer symbols
vim.keymap.set('n', '<leader>d', telescope.lsp_definitions, {}) --- go to definition
vim.keymap.set('n', '<leader>i', telescope.lsp_implementations, {}) --- go to definition
vim.keymap.set('n', '<leader>w', telescope.lsp_type_definitions, {}) -- go to type definition

local mappings = require("telescope.mappings")
local actions = require("telescope.actions")
mappings.default_mappings["i"]["<C-j>"] = actions.move_selection_next
mappings.default_mappings["i"]["<C-k>"] = actions.move_selection_previous

local map = function(type, key, value)
	vim.fn.nvim_buf_set_keymap(0,type,key,value,{noremap = true, silent = true});
end

local custom_attach = function(client)
	print("LSP started.");
	require'completion'.on_attach(client)
	require'diagnostic'.on_attach(client)

	map('n','gD','<cmd>lua vim.lsp.buf.declaration()<CR>')
	map('n','gd','<cmd>lua vim.lsp.buf.definition()<CR>')
	map('n','K','<cmd>lua vim.lsp.buf.hover()<CR>')
	map('n','gr','<cmd>lua vim.lsp.buf.references()<CR>')
	map('n','gs','<cmd>lua vim.lsp.buf.signature_help()<CR>')
	map('n','gi','<cmd>lua vim.lsp.buf.implementation()<CR>')
	map('n','gt','<cmd>lua vim.lsp.buf.type_definition()<CR>')
	map('n','<leader>gw','<cmd>lua vim.lsp.buf.document_symbol()<CR>')
	map('n','<leader>gW','<cmd>lua vim.lsp.buf.workspace_symbol()<CR>')
	map('n','<leader>ah','<cmd>lua vim.lsp.buf.hover()<CR>')
	map('n','<leader>af','<cmd>lua vim.lsp.buf.code_action()<CR>')
	map('n','<leader>ee','<cmd>lua vim.lsp.util.show_line_diagnostics()<CR>')
	map('n','<leader>ar','<cmd>lua vim.lsp.buf.rename()<CR>')
	map('n','<leader>=', '<cmd>lua vim.lsp.buf.formatting()<CR>')
	map('n','<leader>ai','<cmd>lua vim.lsp.buf.incoming_calls()<CR>')
	map('n','<leader>ao','<cmd>lua vim.lsp.buf.outgoing_calls()<CR>')
end


--- LSP
require'lspconfig'.pyright.setup{}
require'lspconfig'.clangd.setup{}

 vim.lsp.set_log_level("trace")

---
vim.opt.termguicolors = true
