-- File explorer powered by snacks.nvim. The explorer source itself (sidebar
-- layout + window-nav keys) is configured in lua/ui.lua's snacks setup; this
-- module owns the drawer keymaps and the startup view.
local explorer = require('snacks').explorer

-- Open the drawer (revealing the current file) with <leader>e, close it with
-- <leader>E. reveal() only moves the tree's target; we also focus the list so
-- the cursor lands on the current file, matching fern's reveal behavior.
vim.keymap.set('n', '<leader>e', function()
  local p = explorer.reveal()
  if p then vim.schedule(function() p:focus('list') end) end
end, { desc = 'explorer' })
vim.keymap.set('n', '<leader>E', function()
  local p = Snacks.picker.get({ source = 'explorer' })[1]
  if p then p:close() end
end, { desc = 'close explorer' })

-- Startup view: explorer drawer alongside an empty main buffer, with focus left
-- in the main window. `nvim <dir>` is handled by snacks' replace_netrw; here we
-- only cover bare `nvim`. Plain file args are left alone.
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    if #vim.fn.argv() ~= 0 then return end
    vim.schedule(function()
      explorer.open({ on_show = function() vim.schedule(function() vim.cmd.wincmd('p') end) end })
    end)
  end,
})
