-- Auto-reload files changed on disk (prompts if buffer is also modified)
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  callback = function()
    if vim.fn.mode() ~= 'c' then vim.cmd.checktime() end
  end,
})

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

-- Clear search highlights with Esc
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<cr>')

vim.keymap.set('n', '<leader>bd', '<cmd>confirm bdelete<cr>', { desc = 'delete buffer' })
vim.keymap.set('n', '<leader>bn', '<cmd>enew<cr>', { desc = 'new buffer' })
vim.keymap.set('n', '<leader>qq', '<cmd>confirm qa<cr>', { desc = 'quit' })
