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
    vim.keymap.set('n', 'R', '<Plug>(fern-action-rename)', opts)
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
