# nvim config

## Philosophy

Minimal, easy to understand, and fast. Every plugin earns its place. Prefer neovim built-ins over plugins where they're good enough. Avoid plugin managers with heavy abstractions — this config uses `vim.pack`, neovim 0.12's built-in package manager.

## Plugin management

Plugins are declared in a single `vim.pack.add({})` call at the top of `init.lua`. Each entry is either a GitHub URL string or a table with `src` and `version` fields for pinning a branch/tag:

```lua
{ src = 'https://github.com/saghen/blink.cmp', version = 'v1' }
```

The lock file `nvim-pack-lock.json` pins each plugin to a specific commit. To update plugins, run `:lua vim.pack.update()` from within neovim.

## Single file

Everything lives in `init.lua`. Don't split into multiple files unless there's a compelling reason — the goal is for the whole config to be readable in one sitting.

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
