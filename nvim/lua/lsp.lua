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
  cmd = { 'bunx', '-p', 'typescript', '-p', 'typescript-language-server', 'typescript-language-server', '--stdio' },
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

require('lsp_signature').setup({
  hint_enable = false,
  handler_opts = { border = 'single' },
})

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
  formatters = {
    prettier = function(bufnr)
      local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
      local bin = vim.fs.find('node_modules/.bin/prettier', { path = dir, upward = true })[1]
      return bin and { command = bin }
        or { command = 'bunx', prepend_args = { 'prettier' } }
    end,
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
  local dir = vim.fn.fnamemodify(file, ':h')
  local diff = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(dir) .. ' diff HEAD --unified=0 -- ' .. vim.fn.shellescape(file))
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
        table.insert(ranges, { start = { start, 0 }, ['end'] = { start + count, 0 } })
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
