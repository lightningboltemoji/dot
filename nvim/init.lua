vim.g.mapleader = ' '

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Use terminal's 16-color palette
vim.opt.termguicolors = false

-- Use terminal background color
vim.api.nvim_set_hl(0, 'Normal', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'NONE' })
vim.opt.fillchars = { eob = ' ' }
vim.api.nvim_set_hl(0, 'FloatBorder', { ctermfg = 8 })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE' })

vim.o.winborder = 'single'

-- Plugin management (neovim 0.12 built-in)
vim.pack.add({
  'https://github.com/lambdalisue/vim-fern',
  'https://github.com/lambdalisue/vim-fern-hijack',
  'https://github.com/lambdalisue/vim-fern-renderer-nerdfont',
  'https://github.com/lambdalisue/vim-nerdfont',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/nvim-lualine/lualine.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/ibhagwan/fzf-lua',
  'https://github.com/folke/snacks.nvim',
})

-- Window navigation with ctrl+hjkl
vim.keymap.set('n', '<c-h>', '<c-w>h')
vim.keymap.set('n', '<c-j>', '<c-w>j')
vim.keymap.set('n', '<c-k>', '<c-w>k')
vim.keymap.set('n', '<c-l>', '<c-w>l')

require('which-key').setup({
  delay = 0,
  win = {
    border = 'single',
    col = math.huge,
    width = { min = 40, max = 60 },
  },
})
require('which-key').add({
  { '<leader>c', group = 'code' },
  { '<leader>f', group = 'find' },
  { '<leader>g', group = 'git' },
  { '<leader>q', group = 'quit' },
})
require('snacks').setup({ lazygit = { enabled = true } })
require('fzf-lua').setup({
  buffers = { no_header = true, no_header_i = true, buf_flag = false, buf_nr = false },
})

require('lualine').setup({
  options = { globalstatus = true },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'filetype', 'filename' },
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { 'branch', 'diff', 'location' },
  },
})

-- Fern settings
-- Use nerdfont icons in fern
vim.g['fern#renderer'] = 'nerdfont'

-- Override Fern's ctrl+h/l so window navigation works inside fern
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'fern',
  callback = function()
    local opts = { buffer = true }
    vim.keymap.set('n', '<c-h>', '<c-w>h', opts)
    vim.keymap.set('n', '<c-l>', '<c-w>l', opts)
    vim.keymap.set('n', 'R', '<cmd>Fern . -drawer -reveal=%<cr>', opts)
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})

-- LSP
vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      workspace = { library = { vim.env.VIMRUNTIME } },
    },
  },
})
vim.lsp.enable('lua_ls')

vim.keymap.set('n', '<leader>cf', function() vim.lsp.buf.format() end, { desc = 'format' })
vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end, { desc = 'go to definition' })
vim.keymap.set('n', 'gr', function() vim.lsp.buf.references() end, { desc = 'references' })
vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, { desc = 'hover' })
vim.keymap.set('n', '<leader>cr', function() vim.lsp.buf.rename() end, { desc = 'rename' })
vim.keymap.set('n', '<leader>ca', function() vim.lsp.buf.code_action() end, { desc = 'code action' })

-- Clear search highlights with Esc
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<cr>')

-- Fuzzy finding
vim.keymap.set('n', '<leader>ff', '<cmd>FzfLua files<cr>', { desc = 'files' })
vim.keymap.set('n', '<leader>fg', '<cmd>FzfLua live_grep<cr>', { desc = 'grep' })
vim.keymap.set('n', '<leader>fb', '<cmd>FzfLua buffers<cr>', { desc = 'buffers' })

-- Quit with <leader>qq
vim.keymap.set('n', '<leader>qq', '<cmd>qa<cr>', { desc = 'quit' })

-- Git
vim.keymap.set('n', '<leader>gg', function() Snacks.lazygit() end, { desc = 'lazygit' })

-- Toggle fern file drawer with <leader>e
vim.keymap.set('n', '<leader>e', '<cmd>Fern . -drawer -toggle -reveal=%<cr>', { desc = 'fern' })
