require('nvim-treesitter').install({ 'lua', 'typescript', 'tsx', 'javascript', 'html', 'css', 'json', 'python', 'java',
  'rust', 'typespec' }):wait(300000)

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lua', 'typescript', 'typescriptreact', 'javascript', 'javascriptreact', 'html', 'css', 'json', 'python', 'java', 'rust', 'typespec' },
  callback = function() vim.treesitter.start() end,
})

require('nvim-ts-autotag').setup()
require('nvim-autopairs').setup({ check_ts = true })
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

-- flash's default keymaps. lazy.nvim ships these as a `keys` spec, so with
-- vim.pack we set them explicitly. `s`/`S` jump and treesitter-select; `r`/`R`
-- act in operator-pending/visual mode (normal-mode `r`/`R` are untouched);
-- `<c-s>` toggles flash labels while searching with `/`.
local flash = require('flash')
flash.setup()
vim.keymap.set({ 'n', 'x', 'o' }, 's', function() flash.jump() end, { desc = 'flash' })
vim.keymap.set({ 'n', 'x', 'o' }, 'S', function() flash.treesitter() end, { desc = 'flash treesitter' })
vim.keymap.set('o', 'r', function() flash.remote() end, { desc = 'remote flash' })
vim.keymap.set({ 'o', 'x' }, 'R', function() flash.treesitter_search() end, { desc = 'treesitter search' })
vim.keymap.set('c', '<c-s>', function() flash.toggle() end, { desc = 'toggle flash search' })

require('blink.cmp').setup({
  keymap = { preset = 'enter' },
  completion = {
    list = { selection = { preselect = true, auto_insert = false } },
    menu = { border = 'single' },
    documentation = { auto_show = true, window = { border = 'single' } },
  },
  -- Blink enables ghost text in cmdline mode by default, but it can leave stale
  -- ghost-text state that errors on extmark placement when a prompt's buffer
  -- shrinks. We don't want cmdline completion ghost text anyway.
  cmdline = { completion = { ghost_text = { enabled = false } } },
})
