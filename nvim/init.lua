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

-- Built-in undo tree visualizer (nvim 0.12+, ships with nvim but must be packadd'd)
vim.cmd.packadd('nvim.undotree')
vim.keymap.set('n', '<leader>tu', '<cmd>Undotree<cr>', { desc = 'undotree' })
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  callback = function()
    if vim.fn.mode() ~= 'c' then vim.cmd.checktime() end
  end,
})

vim.opt.termguicolors = true
vim.opt.fillchars = { eob = ' ' }
vim.api.nvim_set_hl(0, 'PmenuSel', { reverse = true })

vim.o.winborder = 'single'

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

-- Force transparency for backgrounds the colorscheme would otherwise tint.
-- ColorScheme autocmd so overrides re-apply if the theme reloads (e.g. via
-- lualine's own ColorScheme handler).
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    for _, group in ipairs({
      'Normal', 'NormalNC', 'NormalFloat',
      'StatusLine', 'StatusLineNC',
      'LineNr', 'CursorLineNr', 'SignColumn',
    }) do
      vim.api.nvim_set_hl(0, group, { bg = 'NONE' })
    end
  end,
})
require('vague').setup({
  transparent = false,
  italic = false,
})
vim.cmd.colorscheme('vague')

-- Window navigation with ctrl+hjkl
vim.keymap.set('n', '<c-h>', '<c-w>h')
vim.keymap.set('n', '<c-j>', '<c-w>j')
vim.keymap.set('n', '<c-k>', '<c-w>k')
vim.keymap.set('n', '<c-l>', '<c-w>l')

-- Directional splits (hjkl = where the new window lands)
vim.keymap.set('n', '<leader>wh', '<cmd>aboveleft vsplit<cr>', { desc = 'split left' })
vim.keymap.set('n', '<leader>wj', '<cmd>belowright split<cr>', { desc = 'split down' })
vim.keymap.set('n', '<leader>wk', '<cmd>aboveleft split<cr>', { desc = 'split up' })
vim.keymap.set('n', '<leader>wl', '<cmd>belowright vsplit<cr>', { desc = 'split right' })
vim.keymap.set('n', '<leader>wd', '<cmd>close<cr>', { desc = 'close window' })

-- Swap the current window's buffer with its neighbor in the given direction.
local function swap_window(dir)
  local src = vim.api.nvim_get_current_win()
  vim.cmd('wincmd ' .. dir)
  local tgt = vim.api.nvim_get_current_win()
  if tgt == src then return end -- no neighbor in that direction
  local src_buf = vim.api.nvim_win_get_buf(src)
  local tgt_buf = vim.api.nvim_win_get_buf(tgt)
  vim.api.nvim_win_set_buf(src, tgt_buf)
  vim.api.nvim_win_set_buf(tgt, src_buf)
  -- Cursor is now in tgt, which holds the originally-active buffer.
end
vim.keymap.set('n', '<leader>wsh', function() swap_window('h') end, { desc = 'swap left' })
vim.keymap.set('n', '<leader>wsj', function() swap_window('j') end, { desc = 'swap down' })
vim.keymap.set('n', '<leader>wsk', function() swap_window('k') end, { desc = 'swap up' })
vim.keymap.set('n', '<leader>wsl', function() swap_window('l') end, { desc = 'swap right' })

require('which-key').setup({
  delay = 0,
  win = {
    border = 'single',
    col = math.huge,
    width = { min = 40, max = 60 },
  },
})
require('which-key').add({
  { '<leader>c',  group = 'code' },
  { '<leader>f',  group = 'find' },
  { '<leader>b',  group = 'buffer' },
  { '<leader>t',  group = 'tool' },
  { '<leader>q',  group = 'quit' },
  { '<leader>w',  group = 'window' },
  { '<leader>ws', group = 'swap' },
})
local saved_mouse
require('snacks').setup({
  input = { enabled = true },
  notifier = { enabled = false },
  lazygit = { enabled = true },
  terminal = {
    enabled = true,
    win = {
      position = 'float',
      border = 'single',
      on_win = function()
        saved_mouse = vim.o.mouse
        vim.o.mouse = ''
      end,
      on_close = function()
        if saved_mouse then
          vim.o.mouse = saved_mouse
          saved_mouse = nil
        end
      end,
      keys = {
        esc_esc = { '<Esc><Esc>', function(self) self:hide() end, mode = 't' },
      },
    },
  },
})
require('nvim-treesitter').install({ 'lua', 'typescript', 'tsx', 'javascript', 'html', 'css', 'json', 'python', 'java',
  'rust', 'typespec' }):wait(300000)

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lua', 'typescript', 'typescriptreact', 'javascript', 'javascriptreact', 'html', 'css', 'json', 'python', 'java', 'rust', 'typespec' },
  callback = function() vim.treesitter.start() end,
})

require('nvim-ts-autotag').setup()
require('guess-indent').setup()

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
require('mini.ai').setup()
vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap-forward)')
vim.keymap.set({ 'n', 'x', 'o' }, 'S', '<Plug>(leap-backward)')
require('noice').setup({
  -- Native LSP handles hover (K) and lsp_signature.nvim handles signature
  -- help. Noice kept overlapping/unbordering those popups.
  lsp = {
    hover = { enabled = false },
    signature = { enabled = false },
  },
})
require('lsp_signature').setup({
  hint_enable = false,
  handler_opts = { border = 'single' },
})
require('fzf-lua').setup({
  buffers = { no_header_i = true },
})

-- Bundled colorscheme lualine themes tend to hard-code a bg for the c section,
-- so override it after load to keep the middle gap transparent.
local theme = require('lualine.themes.auto')
for _, mode in pairs(theme) do
  if mode.c then mode.c.bg = 'NONE' end
end

require('lualine').setup({
  options = {
    theme = theme,
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

-- Override Fern's ctrl+h/j/k/l so window navigation works inside fern
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'fern',
  callback = function()
    local opts = { buffer = true }
    vim.keymap.set('n', '<c-h>', '<c-w>h', opts)
    vim.keymap.set('n', '<c-j>', '<c-w>j', opts)
    vim.keymap.set('n', '<c-k>', '<c-w>k', opts)
    vim.keymap.set('n', '<c-l>', '<c-w>l', opts)
    vim.keymap.set('n', 'm', '<Plug>(fern-action-mark)', opts)
    vim.keymap.set('n', 'R', '<cmd>Fern . -drawer -reveal=%<cr>', opts)
    vim.keymap.set('n', '<cr>', function()
      return vim.fn['fern#smart#leaf'](
        '<Plug>(fern-action-open)',
        '<Plug>(fern-action-expand)',
        '<Plug>(fern-action-collapse)'
      )
    end, { buffer = true, expr = true, replace_keycodes = true })
    vim.keymap.set('n', '=', '<Plug>(fern-action-enter)', opts)
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})

-- Keep fern full-height when quickfix opens (which uses botright and would
-- otherwise chop fern's bottom off).
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'qf',
  callback = function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == 'fern' then
        local cur = vim.api.nvim_get_current_win()
        local width = vim.api.nvim_win_get_width(win)
        vim.api.nvim_set_current_win(win)
        vim.cmd('wincmd H')
        vim.api.nvim_win_set_width(win, width)
        vim.api.nvim_set_current_win(cur)
        break
      end
    end
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

vim.lsp.config('tsp_server', {
  cmd = { 'bunx', '-p', '@typespec/compiler', 'tsp-server', '--stdio' },
  filetypes = { 'typespec' },
  root_markers = { 'tspconfig.yaml', 'package.json', '.git' },
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
vim.lsp.enable('tsp_server')
vim.lsp.enable('harper_ls')

require('conform').setup({
  formatters_by_ft = {
    javascript = { 'prettier' },
    javascriptreact = { 'prettier' },
    typescript = { 'prettier' },
    typescriptreact = { 'prettier' },
    html = { 'prettier' },
    css = { 'prettier' },
    json = { 'prettier' },
    markdown = { 'prettier' },
    python = { 'ruff_organize_imports', 'ruff_format' },
    rust = { 'rustfmt' },
  },
  format_on_save = function(bufnr)
    if vim.g.format_on_save == false then return end
    local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
    if vim.fs.find('.noformat', { path = dir, upward = true, stop = vim.fs.dirname(vim.fn.getcwd()) })[1] then return end
    return { timeout_ms = 2000, lsp_format = 'fallback' }
  end,
})

vim.keymap.set('n', '<leader>cf', function()
  require('conform').format({ async = true, lsp_format = 'fallback' })
end, { desc = 'format' })

local function clean_buffer()
  local view = vim.fn.winsaveview()
  vim.cmd([[silent! keeppatterns %s/\s\+$//e]])
  vim.fn.winrestview(view)
end

vim.keymap.set('n', '<leader>cC', clean_buffer, { desc = 'clean (trim trailing whitespace)' })

-- Auto-clean on write. `fixendofline` (on by default) handles the trailing
-- newline; this just strips trailing whitespace. Use `:noa w` to write raw.
vim.api.nvim_create_autocmd('BufWritePre', {
  callback = clean_buffer,
})

vim.keymap.set('n', '<leader>cF', function()
  local file = vim.fn.expand('%:p')
  local diff = vim.fn.systemlist('git diff --unified=0 -- ' .. vim.fn.shellescape(file))
  if vim.v.shell_error ~= 0 or #diff == 0 then
    vim.notify('No git changes to format', vim.log.levels.INFO)
    return
  end
  local ranges = {}
  for _, line in ipairs(diff) do
    local start, count = line:match('^@@ %-%d+,?%d* %+(%d+),?(%d*) @@')
    if start then
      start = tonumber(start)
      count = tonumber(count) or 1
      if count > 0 then
        table.insert(ranges, { start = { start, 0 }, ['end'] = { start + count - 1, 0 } })
      end
    end
  end
  if #ranges == 0 then
    vim.notify('No changed lines to format', vim.log.levels.INFO)
    return
  end
  for _, range in ipairs(ranges) do
    require('conform').format({ range = range, lsp_format = 'fallback' })
  end
end, { desc = 'format changed lines' })
vim.keymap.set('n', 'gd', function() require('fzf-lua').lsp_definitions() end, { desc = 'go to definition' })
vim.keymap.set('n', 'gr', function() require('fzf-lua').lsp_references() end, { desc = 'references' })
vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, { desc = 'hover' })
vim.keymap.set('n', '<leader>cr', function() vim.lsp.buf.rename() end, { desc = 'rename' })
vim.keymap.set('n', '<leader>ca', function() vim.lsp.buf.code_action() end, { desc = 'code action' })
vim.keymap.set('n', '<leader>cd', function() vim.diagnostic.open_float() end, { desc = 'diagnostic' })
vim.keymap.set('n', '<leader>ch', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end,
  { desc = 'inlay hints' })
vim.keymap.set('n', '<leader>cs', function()
  vim.g.format_on_save = vim.g.format_on_save == false
  vim.notify('Format on save: ' .. (vim.g.format_on_save and 'on' or 'off'))
end, { desc = 'toggle format on save' })

require('blink.cmp').setup({
  keymap = { preset = 'enter' },
  completion = {
    list = { selection = { preselect = true, auto_insert = false } },
    menu = { border = 'single' },
    documentation = { auto_show = true, window = { border = 'single' } },
  },
  -- Blink enables ghost text in cmdline mode by default. Fern's "are you
  -- sure?" delete prompt runs in cmdline, which left stale ghost-text state
  -- that then errored on extmark placement after the buffer shrank.
  cmdline = { completion = { ghost_text = { enabled = false } } },
})

-- Clear search highlights with Esc
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<cr>')

-- Fuzzy finding
vim.keymap.set('n', '<leader>ff', '<cmd>FzfLua files<cr>', { desc = 'files' })
vim.keymap.set('n', '<leader>fg', '<cmd>FzfLua live_grep<cr>', { desc = 'grep' })
vim.keymap.set('n', '<leader>fb', '<cmd>FzfLua buffers<cr>', { desc = 'buffers' })
vim.keymap.set('n', '<leader>fr', '<cmd>FzfLua resume<cr>', { desc = 'resume' })
vim.keymap.set('n', '<leader><space>', '<cmd>FzfLua global<cr>', { desc = 'global' })

-- Quit with <leader>qq
vim.keymap.set('n', '<leader>bd', '<cmd>confirm bdelete<cr>', { desc = 'delete buffer' })
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

-- Open fern drawer (or reveal current file if already open) with <leader>e,
-- close it with <leader>E.
vim.keymap.set('n', '<leader>e', '<cmd>Fern . -drawer -reveal=%<cr>', { desc = 'fern' })
vim.keymap.set('n', '<leader>E', function()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == 'fern' then
      vim.api.nvim_win_close(win, false)
    end
  end
end, { desc = 'close fern' })

-- Startup view: empty main buffer + fern drawer on the side.
-- Handles `nvim` (no args) and `nvim <dir>` (directory arg). Plain file args
-- are left alone.
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    local argv = vim.fn.argv()
    local is_dir_arg = #argv == 1 and vim.fn.isdirectory(argv[1]) == 1
    if not (is_dir_arg or #argv == 0) then return end
    if is_dir_arg then
      vim.cmd.cd(argv[1])
      vim.cmd.enew()
      vim.cmd('silent! bwipeout #')
    end
    -- Defer fern so it runs after any other VimEnter handlers have finished.
    vim.schedule(function()
      vim.cmd('Fern . -drawer')
      vim.cmd.wincmd('p')
    end)
  end,
})
