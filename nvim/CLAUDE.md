# nvim config

## Philosophy

Minimal, easy to understand, and fast. Every plugin earns its place. Prefer neovim built-ins over plugins where they're good enough. Avoid plugin managers with heavy abstractions — this config uses `vim.pack`, neovim 0.12's built-in package manager.

## Plugin management

Plugins are declared in a single `vim.pack.add({})` call at the top of `init.lua`. Each entry is either a GitHub URL string or a table with `src` and `version` fields for pinning a branch/tag:

```lua
{ src = 'https://github.com/saghen/blink.cmp', version = 'v1' }
```

The lock file `nvim-pack-lock.json` pins each plugin to a specific commit. To update plugins, run `:lua vim.pack.update()` from within neovim.

## Layout

`init.lua` is the entry point: editor options, the `vim.pack.add` plugin list, then ordered `require`s of the modules under `lua/`. Each module owns one concern end-to-end — its plugin setup, autocmds, and keymaps live together so the file reads top-to-bottom:

- `lua/keymaps.lua` — non-plugin keymaps (window nav, splits, swap, buffer, quit, esc) + the autoread `checktime` autocmd
- `lua/ui.lua` — colorscheme, lualine, which-key, noice, snacks (terminal/lazygit), goyo, undotree
- `lua/editing.lua` — treesitter (incl. incremental selection), nvim-ts-autotag, mini.ai/mini.animate, leap, guess-indent, blink.cmp
- `lua/lsp.lua` — LSP server configs/enables, lsp_signature, conform + format-on-save, whitespace trim, LSP keymaps
- `lua/explorer.lua` — fern (drawer keymaps, FileType autocmds, qf re-anchor, VimEnter startup view)
- `lua/finder.lua` — fzf-lua + the `leave_sidebar` helper that hops out of fern before opening a picker

Modules are imperative side-effect files — they don't return anything. Local helpers stay `local` to the module that uses them; nothing is shared across modules. Keep modules focused: if a new feature spans two concerns, pick the one it belongs to most rather than splitting it.

## Colors

`termguicolors` is disabled — the config intentionally defers to the terminal's 16-color palette. Floating window backgrounds are set to `NONE` (transparent) so they blend with the terminal background. `vim.o.winborder = 'single'` adds a border to all floats globally.

## LSP

Uses neovim's native LSP (`vim.lsp.config` / `vim.lsp.enable`), no plugins. Each language server is configured with explicit `filetypes` to prevent accidental attachment. Currently configured:
- `lua_ls` — Lua (lua-language-server, installed via brew)
- `ts_ls` — TypeScript/JavaScript/React (typescript-language-server, installed via bun)

Indent style for Lua formatting is controlled by `.editorconfig` in this directory.

Completion is handled by blink.cmp (pinned to v1 branch).

## Key conventions

- `<leader>` is space
- keymap `desc` values are all lowercase
- which-key group names are all lowercase
- `<leader>c` — code actions (LSP)
- `<leader>f` — find (fzf)
- `<leader>t` — terminal/tools
- `<leader>q` — quit
- `<leader>e` — file explorer (Fern)
