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

  -- Syntax parser (not LSP). Provides syntax tree metadata for other plugins
  {
      'nvim-treesitter/nvim-treesitter',
      config = function()
          require'nvim-treesitter.configs'.setup({
            -- A list of parser names, or "all" (the five listed parsers should always be installed)
            ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "query" },
        
            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,
        
            ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
            -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!
        
            highlight = {
              enable = true,
            },
        })
      end,
  },

  -- Pickers
  {
      'nvim-telescope/telescope.nvim', tag = '0.1.6',
      dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' }
  },

  -- Scrollbar
  {
      'dstein64/nvim-scrollview',
      signs_on_startup = {'all'}
  },

  -- Base LSP plugin
  {'neovim/nvim-lspconfig'},

  -- Mason, for installing language server internally
  {"williamboman/mason.nvim"},

  -- Completion with LSP
  {'hrsh7th/cmp-nvim-lsp'},
  {'hrsh7th/nvim-cmp'},

  -- File explorer tree
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

--- Mason
mason = require("mason")
mason.setup()

print('hi')
mason_reg = require("mason-registry")
if not mason_reg.is_installed("clangd") then
    print('Installing clangd via mason')
    vim.cmd("MasonInstall clangd")
end

--- LSP&completion stuff
--- The following is the default configuration of nvim-cmp, copied from GitHub
--- except the last line which sets the server as clangd

  -- Set up nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
      -- { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      { name = 'buffer' },
    })
  })

  -- To use git you need to install the plugin petertriho/cmp-git and uncomment lines below
  -- Set configuration for specific filetype.
  --[[ cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'git' },
    }, {
      { name = 'buffer' },
    })
 })
 require("cmp_git").setup() ]]-- 

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    }),
    matching = { disallow_symbol_nonprefix_matching = false }
  })

  -- Set up lspconfig.
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
  require('lspconfig').clangd.setup {
    capabilities = capabilities
  }

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = false,
  float = true,
})
