require('fzf-lua').setup({
  buffers = { no_header_i = true },
})

-- Hop out of fern (or any sidebar-y buffer) before opening a picker, so the
-- file we pick doesn't replace the drawer.
local function leave_sidebar()
  if vim.bo.filetype ~= 'fern' then return end
  -- Skip fern, ui2 message/cmd splits, terminals, and other non-editor buffers
  -- by accepting only buftype = '' (a normal file/scratch buffer).
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == '' then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
  local fern_win = vim.api.nvim_get_current_win()
  vim.cmd('rightbelow vnew')
  vim.api.nvim_win_set_width(fern_win, vim.g['fern#drawer_width'] or 40)
end

local function pick(cmd)
  return function()
    leave_sidebar()
    vim.cmd(cmd)
  end
end

vim.keymap.set('n', '<leader>ff', pick('FzfLua files'), { desc = 'files' })
vim.keymap.set('n', '<leader>fg', pick('FzfLua live_grep'), { desc = 'grep' })
vim.keymap.set('n', '<leader>fb', pick('FzfLua buffers'), { desc = 'buffers' })
vim.keymap.set('n', '<leader>fr', pick('FzfLua resume'), { desc = 'resume' })
vim.keymap.set('n', '<leader><space>', pick('FzfLua global'), { desc = 'global' })
