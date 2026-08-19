local fzf = require('fzf-lua')

-- `hidden` includes dotfiles; gitignored files stay opt-in behind alt-i.
-- Must be set per-provider — a top-level `hidden` doesn't reach grep.
fzf.setup({
  buffers = { no_header_i = true },
  files = { hidden = true },
  -- fzf-lua's default grep `rg_opts` plus `-g "!.git"`. `files`/`global` already
  -- exclude .git through their own defaults; rg drops it on its own too, but only
  -- while gitignore rules apply — alt-i (`--no-ignore`) lets it back in, and an
  -- explicit glob survives that. `-e` has to stay last.
  grep = {
    hidden = true,
    rg_opts = '--column --line-number --no-heading --color=always --smart-case '
      .. '--max-columns=4096 -g "!.git" -e',
  },
  global = { hidden = true },
  actions = {
    -- alt-h belongs to system-level window management, so toggle hidden lives on
    -- ctrl-h instead (which shadows fzf's ctrl-h = backward-delete-char).
    files = {
      -- `true` inherits fzf-lua's default file actions; without it this table
      -- replaces them wholesale and even `enter` (open the file) stops working.
      true,
      ['alt-h'] = false,
      ['ctrl-h'] = { fn = fzf.actions.toggle_hidden, reuse = true, header = false },
    },
  },
})

-- Hop out of the explorer drawer (a snacks picker window) before opening a
-- picker, so the file we pick doesn't replace the drawer.
local function leave_sidebar()
  local ft = vim.bo.filetype
  if ft ~= 'snacks_picker_list' and ft ~= 'snacks_picker_input' then return end
  -- Accept only buftype = '' (a normal file/scratch buffer), skipping the
  -- explorer, ui2 message/cmd splits, terminals, and other non-editor buffers.
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == '' then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
  vim.cmd('rightbelow vnew')
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
vim.keymap.set('n', '<leader>fm', function()
  leave_sidebar()
  Snacks.picker.marks()
end, { desc = 'marks' })
vim.keymap.set('n', '<leader><space>', pick('FzfLua global'), { desc = 'global' })
