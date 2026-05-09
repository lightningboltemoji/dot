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

require('noice').setup({
  -- Native LSP handles hover (K) and lsp_signature.nvim handles signature
  -- help. Noice kept overlapping/unbordering those popups.
  lsp = {
    hover = { enabled = false },
    signature = { enabled = false },
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
