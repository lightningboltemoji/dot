-- Built-in undo tree visualizer (nvim 0.12+, ships with nvim but must be packadd'd)
vim.cmd.packadd('nvim.undotree')
vim.keymap.set('n', '<leader>tu', '<cmd>Undotree<cr>', { desc = 'undotree' })

vim.api.nvim_set_hl(0, 'PmenuSel', { reverse = true })

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
    -- Dim the snacks picker (explorer) border so it reads as a quiet frame.
    vim.api.nvim_set_hl(0, 'SnacksPickerBorder', { link = 'WinSeparator' })
    -- vague gives Search, IncSearch and CurSearch the same blue-grey background,
    -- so the *active* match never stands out: during `:s///c` it's IncSearch,
    -- and under the cursor on `n`/`N` it's CurSearch. Paint those amber so you
    -- can always tell which match is about to be acted on.
    vim.api.nvim_set_hl(0, 'IncSearch', { fg = '#141415', bg = '#f3be7c', bold = true })
    vim.api.nvim_set_hl(0, 'CurSearch', { fg = '#141415', bg = '#f3be7c', bold = true })
  end,
})
require('vague').setup({
  transparent = false,
  italic = false,
})
vim.cmd.colorscheme('vague')

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

-- Move to the window in `dir`, but never wrap. The explorer's windows are
-- floats, so a plain `wincmd h/l` from the drawer jumps to the editor even when
-- nothing sits in that direction (e.g. C-h at the left edge "wraps" right).
-- Bail unless the window we'd land on is actually on the requested side.
local function win_move(dir)
  local from = vim.api.nvim_get_current_win()
  local frow, fcol = unpack(vim.api.nvim_win_get_position(from))
  vim.cmd.wincmd(dir)
  local to = vim.api.nvim_get_current_win()
  if to == from then return end
  local trow, tcol = unpack(vim.api.nvim_win_get_position(to))
  local ok = (dir == 'h' and tcol < fcol) or (dir == 'l' and tcol > fcol)
      or (dir == 'k' and trow < frow) or (dir == 'j' and trow > frow)
  if not ok then vim.api.nvim_set_current_win(from) end
end

-- In the explorer, ctrl-hjkl move between the drawer and the editor (window
-- nav), matching the global keymaps — snacks would otherwise swallow them.
-- C-j/C-k are special-cased: while filtering (insert mode) they navigate the
-- result list, which is when you actually want them; in normal mode they stay
-- window nav. The rhs gets the picker win, so win:execute runs the list action.
local function nav(dir, action)
  return {
    function(self)
      if vim.fn.mode() == 'i' then self:execute(action) else win_move(dir) end
    end,
    mode = { 'i', 'n' },
  }
end
local win_nav = {
  ['<c-h>'] = function() win_move('h') end,
  ['<c-l>'] = function() win_move('l') end,
  ['<c-j>'] = nav('j', 'list_down'),
  ['<c-k>'] = nav('k', 'list_up'),
}

local saved_mouse
require('snacks').setup({
  input = { enabled = true },
  notifier = { enabled = false },
  lazygit = { enabled = true },
  explorer = { enabled = true },
  picker = {
    sources = {
      explorer = {
        title = '⚡️',
        layout = { preset = 'sidebar', preview = false },
        win = {
          -- <esc> in the list normally closes the explorer; keep it open.
          list = { keys = vim.tbl_extend('force', win_nav, { ['<esc>'] = false }) },
          input = { keys = win_nav },
        },
      },
    },
  },
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

require('noice').setup({
  -- Native LSP handles hover (K) and lsp_signature.nvim handles signature
  -- help. Noice kept overlapping/unbordering those popups.
  lsp = {
    hover = { enabled = false },
    signature = { enabled = false },
  },
  -- The `:s///c` prompt is delivered on the *cmdline* channel (not as a
  -- confirm/confirm_sub message), so by default it lands in the centered
  -- `cmdline_popup` view — right on top of the match. Match that one prompt by
  -- its y/n/a/q text and send it to the classic bottom cmdline view, where it
  -- can't cover anything. Custom routes win over defaults, so normal `:`/`/`
  -- keep using the centered popup.
  routes = {
    {
      view = 'cmdline',
      filter = { event = 'cmdline', find = '%(y%)es/%(n%)o/%(a%)ll' },
    },
  },
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
    section_separators = { left = '', right = '' },
    component_separators = '',
  },
  sections = {
    lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
    lualine_b = { 'filetype', 'filename' },
    lualine_c = {},
    lualine_x = {},
    lualine_y = { 'branch', 'diff' },
    lualine_z = { { 'location', separator = { right = '' }, left_padding = 2 } },
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

-- Tools
vim.keymap.set('n', '<leader>tg', function()
  local file = vim.api.nvim_buf_get_name(0)
  local dir = file ~= '' and vim.fn.fnamemodify(file, ':h') or vim.fn.getcwd()
  local root = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(dir) .. ' rev-parse --show-toplevel')[1]
  Snacks.lazygit({ cwd = (vim.v.shell_error == 0 and root) or nil })
end, { desc = 'lazygit' })
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
