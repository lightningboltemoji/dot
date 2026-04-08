vim.g.mapleader = ' '

-- New UI opt-in
require('vim._core.ui2').enable({})

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.cursorlineopt = 'number'
-- Right-align the current line's number too (default left-aligns it)
vim.opt.statuscolumn = '%s%=%{v:relnum?v:relnum:v:lnum} '

-- Sync with macOS clipboard
vim.opt.clipboard = 'unnamedplus'

-- Use terminal's 16-color palette
vim.opt.termguicolors = false

-- Use terminal background color
vim.api.nvim_set_hl(0, 'Normal', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'NONE' })
vim.opt.fillchars = { eob = ' ' }
vim.api.nvim_set_hl(0, 'FloatBorder', { ctermfg = 8 })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'Pmenu', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'PmenuSel', { reverse = true })
vim.api.nvim_set_hl(0, 'StatusLine', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'StatusLineNC', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'LineNr', { ctermfg = 8 })
vim.api.nvim_set_hl(0, 'CursorLineNr', { ctermfg = 7 })

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
  { src = 'https://github.com/saghen/blink.cmp', version = 'v1' },
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/nvim-mini/mini.animate',
  'https://codeberg.org/andyg/leap.nvim.git',
  'https://github.com/MunifTanjim/nui.nvim',
  'https://github.com/folke/noice.nvim',
  'https://github.com/junegunn/goyo.vim',
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
  { '<leader>b', group = 'buffer' },
  { '<leader>t', group = 'terminal' },
  { '<leader>q', group = 'quit' },
})
require('snacks').setup({
  input = { enabled = true },
  dashboard = {
    enabled = true,
    preset = {
      keys = {
        { icon = ' ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
        { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
        { icon = ' ', key = 'r', desc = 'Recent Files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
        { icon = ' ', key = 'c', desc = 'Config', action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
        { icon = '󰒲 ', key = 'q', desc = 'Quit', action = ':qa' },
      },
    },
    sections = {
      { section = 'header' },
      { icon = ' ', title = 'Keymaps', section = 'keys', indent = 2, padding = 1 },
      { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
      { icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1, limit = 10 },
    },
  },
  notifier = { enabled = false },
  lazygit = { enabled = true },
  terminal = {
    enabled = true,
    win = {
      position = 'float',
      border = 'single',
      keys = {
        esc_esc = { '<Esc><Esc>', function(self) self:hide() end, mode = 't' },
      },
    },
  },
})
require('nvim-treesitter').install({ 'lua', 'typescript', 'tsx', 'javascript', 'html', 'css', 'json', 'python', 'java',
  'rust' }):wait(300000)

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lua', 'typescript', 'typescriptreact', 'javascript', 'javascriptreact', 'html', 'css', 'json', 'python', 'java', 'rust' },
  callback = function() vim.treesitter.start() end,
})

-- Treesitter incremental selection
local function select_ts_node(node)
  local sr, sc, er, ec = node:range()
  local line_count = vim.api.nvim_buf_line_count(0)
  er = math.min(er, line_count - 1)
  ec = math.max(ec - 1, 0)
  vim.api.nvim_buf_set_mark(0, '<', sr + 1, sc, {})
  vim.api.nvim_buf_set_mark(0, '>', er + 1, ec, {})
  vim.cmd('normal! gv')
end

local function node_for_selection()
  local sr = vim.fn.line('v') - 1
  local sc = vim.fn.col('v') - 1
  local er = vim.fn.line('.') - 1
  local ec = vim.fn.col('.')
  if sr > er or (sr == er and sc > ec) then
    sr, sc, er, ec = er, ec - 1, sr, sc + 1
  end
  local parser = vim.treesitter.get_parser()
  if not parser then return nil end
  return parser:parse()[1]:root():named_descendant_for_range(sr, sc, er, ec)
end

local ts_history = {}

vim.keymap.set('n', '+', function()
  local node = vim.treesitter.get_node()
  if node then
    ts_history = { node }
    select_ts_node(node)
  end
end)

vim.keymap.set('x', '+', function()
  local node = node_for_selection()
  if node then
    local parent = node:parent()
    if parent then
      table.insert(ts_history, parent)
      select_ts_node(parent)
    end
  end
end)

vim.keymap.set('x', '-', function()
  if #ts_history > 1 then
    table.remove(ts_history)
    select_ts_node(ts_history[#ts_history])
  end
end)
require('mini.animate').setup()
vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap-forward)')
vim.keymap.set({ 'n', 'x', 'o' }, 'S', '<Plug>(leap-backward)')
require('noice').setup({
  views = {
    hover = { border = { style = 'single' } },
  },
})
require('fzf-lua').setup({
  buffers = { no_header = true, no_header_i = true, buf_flag = false, buf_nr = false },
})

-- Bubbles theme using cterm palette indices so colors come from the terminal.
-- Lualine accepts numbers for fg/bg and passes them straight to ctermfg/ctermbg
-- when termguicolors is off (see lualine/highlight.lua and color_utils.lua).
local bubbles_theme = {
  normal   = {
    a = { fg = 0, bg = 5 },              -- black on magenta
    b = { fg = 7, bg = 8 },              -- white on bright black
    c = { fg = 7 },                      -- white
  },
  insert   = { a = { fg = 0, bg = 4 } }, -- black on blue
  visual   = { a = { fg = 0, bg = 6 } }, -- black on cyan
  replace  = { a = { fg = 0, bg = 1 } }, -- black on red
  inactive = {
    a = { fg = 7, bg = 0 },
    b = { fg = 7, bg = 0 },
    c = { fg = 7 },
  },
}

require('lualine').setup({
  options = {
    theme = bubbles_theme,
    globalstatus = true,
    section_separators = { left = '', right = '' },
    component_separators = '',
  },
  sections = {
    lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
    lualine_b = { 'filetype', 'filename' },
    lualine_c = {},
    lualine_x = {},
    lualine_y = { 'branch', 'diff' },
    lualine_z = { { 'location', separator = { right = '' }, left_padding = 2 } },
  },
  inactive_sections = {
    lualine_a = { 'filename' },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { 'location' },
  }
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
    vim.keymap.set('n', '<cr>', '<Plug>(fern-action-open-or-expand)', opts)
    vim.keymap.set('n', '=', '<Plug>(fern-action-enter)', opts)
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})

-- LSP
vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim' } },
      workspace = { library = { vim.env.VIMRUNTIME } },
    },
  },
})
vim.lsp.config('ts_ls', {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
})

vim.lsp.config('rust_analyzer', {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml' },
})
vim.lsp.config('jdtls', {
  cmd = function(config)
    local workspace = vim.fn.expand('~/.local/share/jdtls/workspace/') .. vim.fn.fnamemodify(config.root_dir, ':t')
    return { 'jdtls', '-data', workspace }
  end,
  filetypes = { 'java' },
  root_markers = { 'pom.xml', 'build.gradle', 'build.gradle.kts', '.git' },
})
vim.lsp.config('pyright', {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyrightconfig.json', 'pyproject.toml', 'setup.py', 'setup.cfg', '.git' },
  settings = {
    python = { analysis = { autoSearchPaths = true, useLibraryCodeForTypes = true } },
  },
  on_attach = function(client)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
})
vim.lsp.config('ruff', {
  cmd = { 'ruff', 'server' },
  filetypes = { 'python' },
  root_markers = { 'ruff.toml', '.ruff.toml', 'pyproject.toml', '.git' },
})

vim.lsp.config('harper_ls', {
  cmd = { 'harper-ls', '--stdio' },
  filetypes = { 'markdown', 'text', 'tex', 'typst' },
  root_markers = { '.git' },
  init_options = {
    ['harper-ls'] = {
      linters = { SentenceCapitalization = false },
    },
  },
})

vim.lsp.enable('lua_ls')
vim.lsp.enable('ts_ls')
vim.lsp.enable('rust_analyzer')
vim.lsp.enable('jdtls')
vim.lsp.enable('pyright')
vim.lsp.enable('ruff')
vim.lsp.enable('harper_ls')

vim.keymap.set('n', '<leader>cf', function() vim.lsp.buf.format() end, { desc = 'format' })
vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end, { desc = 'go to definition' })
vim.keymap.set('n', 'gr', function() vim.lsp.buf.references() end, { desc = 'references' })
vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, { desc = 'hover' })
vim.keymap.set('n', '<leader>cr', function() vim.lsp.buf.rename() end, { desc = 'rename' })
vim.keymap.set('n', '<leader>ca', function() vim.lsp.buf.code_action() end, { desc = 'code action' })
vim.keymap.set('n', '<leader>cd', function() vim.diagnostic.open_float() end, { desc = 'diagnostic' })
vim.keymap.set('n', '<leader>ch', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end,
  { desc = 'inlay hints' })

require('blink.cmp').setup({
  keymap = { preset = 'enter' },
  completion = {
    list = { selection = { preselect = true, auto_insert = false } },
    menu = { border = 'single' },
    documentation = { auto_show = true, window = { border = 'single' } },
  },
})

-- Clear search highlights with Esc
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<cr>')

-- Fuzzy finding
vim.keymap.set('n', '<leader>ff', '<cmd>FzfLua files<cr>', { desc = 'files' })
vim.keymap.set('n', '<leader>fg', '<cmd>FzfLua live_grep<cr>', { desc = 'grep' })
vim.keymap.set('n', '<leader>fb', '<cmd>FzfLua buffers<cr>', { desc = 'buffers' })

-- Quit with <leader>qq
vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<cr>', { desc = 'delete buffer' })
vim.keymap.set('n', '<leader>qq', '<cmd>confirm qa<cr>', { desc = 'quit' })

-- Git
vim.keymap.set('n', '<leader>tg', function() Snacks.lazygit() end, { desc = 'lazygit' })
vim.keymap.set('n', '<leader>tt', function() Snacks.terminal() end, { desc = 'terminal' })
vim.keymap.set('n', '<leader>tw', '<cmd>Goyo<cr>', { desc = 'writing mode' })

vim.api.nvim_create_autocmd('User', {
  pattern = 'GoyoEnter',
  callback = function() require('lualine').hide() end,
})
vim.api.nvim_create_autocmd('User', {
  pattern = 'GoyoLeave',
  callback = function() require('lualine').hide({ unhide = true }) end,
})

-- Toggle fern file drawer with <leader>e
vim.keymap.set('n', '<leader>e', '<cmd>Fern . -drawer -toggle -reveal=%<cr>', { desc = 'fern' })
