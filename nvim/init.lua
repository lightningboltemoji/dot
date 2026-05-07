vim.g.mapleader = ' '

-- New UI opt-in
require('vim._core.ui2').enable({})

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.cursorlineopt = 'number'
-- Always reserve sign column space so diagnostics don't shift the gutter
vim.opt.signcolumn = 'yes'
-- Right-align the current line's number too (default left-aligns it)
vim.opt.statuscolumn = '%s%=%{v:relnum?v:relnum:v:lnum} '

-- Default to 2-space indentation; guess-indent overrides per-buffer when it can.
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2

-- Sync with macOS clipboard
vim.opt.clipboard = 'unnamedplus'

-- Auto-reload files changed on disk (prompts if buffer is also modified)
vim.o.autoread = true
vim.o.updatetime = 250

-- Persistent undo: keeps full undo tree across sessions under ~/.local/state/nvim/undo
vim.opt.undofile = true

vim.opt.termguicolors = true
vim.opt.fillchars = { eob = ' ' }

vim.o.winborder = 'single'

-- Keep context around the cursor when scrolling/searching
vim.o.scrolloff = 5
vim.o.sidescrolloff = 5

-- Case-insensitive search, unless the pattern contains a capital letter
vim.o.ignorecase = true
vim.o.smartcase = true

-- Wrapped lines keep their visual indent
vim.o.breakindent = true

-- Snappier which-key (default 1000ms feels sluggish)
vim.o.timeoutlen = 300

-- Plugin management (neovim 0.12 built-in)
vim.pack.add({
  'https://github.com/vague-theme/vague.nvim',
  'https://github.com/lambdalisue/vim-fern',
  'https://github.com/lambdalisue/vim-fern-renderer-nerdfont',
  'https://github.com/lambdalisue/vim-nerdfont',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/nvim-lualine/lualine.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/ibhagwan/fzf-lua',
  'https://github.com/folke/snacks.nvim',
  { src = 'https://github.com/saghen/blink.cmp', version = 'v1' },
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/windwp/nvim-ts-autotag',
  'https://github.com/nvim-mini/mini.animate',
  'https://github.com/nvim-mini/mini.ai',
  'https://codeberg.org/andyg/leap.nvim.git',
  'https://github.com/MunifTanjim/nui.nvim',
  'https://github.com/folke/noice.nvim',
  'https://github.com/junegunn/goyo.vim',
  'https://github.com/ray-x/lsp_signature.nvim',
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/NMAC427/guess-indent.nvim',
})

require('keymaps')
require('ui')
require('editing')
require('lsp')
require('explorer')
require('finder')
