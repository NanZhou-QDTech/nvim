# NVIM DESIGN GUIDE

> grr in caveman: rebuild whole config from this file

---

## CORE PHILOSOPHY

- **minimal deps** — only what earns its keep
- **native first** — prefer vim API over plugins
- **explicit > magic** — no hidden autocmds, no mystery mappings
- **Windows native** — pwsh shell, scoop/cargo bins, no wsl bridge

---

## PLUGIN MATRIX (vim.pack)

| plugin | src | version | purpose | notes |
|--------|-----|---------|---------|-------|
| nvim-treesitter | github.com/nvim-treesitter/nvim-treesitter | main | highlight, fold, textobj | PackChanged bootstraps parsers |
| nvim-treesitter-textobjects | github.com/nvim-treesitter/nvim-treesitter-textobjects | main | extra textobjs | kept inert, no setup() |
| nvim-lspconfig | github.com/neovim/nvim-lspconfig | — | lsp configs | after/lsp/*.lua override |
| mason.nvim | github.com/mason-org/mason.nvim | — | LSP/tool installer | WARN log, top-level setup |
| oil.nvim | github.com/stevearc/oil.nvim | — | file explorer | default_file_explorer=true |
| mini.nvim | github.com/nvim-mini/mini.nvim | — | icons, comment, surround, pairs, snippets | snippets loader from_lang() |
| render-markdown.nvim | github.com/MeanderingProgrammer/render-markdown.nvim | — | md render | top-level setup() |
| obsidian.nvim | github.com/epwalsh/obsidian.nvim | — | obsidian vault | guarded: only if ~/working/worknote exists |
| blink.cmp | github.com/saghen/blink.cmp | 2.* | completion | rust fuzzy, mini_snippets preset |
| blink.lib | github.com/saghen/blink.lib | — | blink dep | — |
| conform.nvim | github.com/stevearc/conform.nvim | — | formatting | **only save-time formatter** |
| nvim-lint | github.com/mfussenegger/nvim-lint | — | linting | BufWritePost, linters_by_ft |

**NOT installed**: fzf-lua, none-ls, clangd (binary via mason)

---

## LSP SERVERS (vim.lsp.enable)

| server | source | filetypes | config file |
|--------|--------|-----------|-------------|
| lua_ls | scoop | lua | after/lsp/lua_ls.lua |
| clangd | mason | c,cpp | nvim-lspconfig default |
| ty | cargo | python | after/lsp/ty.lua |
| ruff | scoop | python | after/lsp/ruff.lua |
| marksman | scoop | markdown | after/lsp/marksman.lua |
| rumdl | cargo | markdown | after/lsp/rumdl.lua (filetypes=) |
| powerquery | custom node | powerquery | lsp/powerquery.lua |

**capabilities**: blink.cmp.get_lsp_capabilities() with pcall fallback

---

## KEYMAPS (leader = space)

### navigation
- `gd` `gD` `gri` `grr` `K` — LSP goto
- `gra` `grn` — code action, rename
- `[d` `]d` — prev/next diagnostic (float via on_jump)
- `<leader>q` — diagnostics to loclist

### formatting
- `<leader>fm` — conform.format async
- `:Format` — range format
- `:FormatDisable` / `:FormatEnable` — toggle (guards format_on_save)

### arglist (harpoon-lite)
- `<leader>aa` — add current file
- `<leader>ad` — delete current file
- `<leader>al` — list
- `<leader>a1-5` — jump to slot

### terminal
- `<Esc><Esc>` — exit terminal mode (single Esc reaches program)
- `<A-h/j/k/l>` — window nav from terminal

### misc
- `<Esc>` — nohlsearch
- `G` `n` `N` — center cursor
- `v` `<` `>` — keep visual selection on indent

---

## FORMAT ON SAVE

```lua
format_on_save = function(bufnr)
  if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
  if vim.api.nvim_buf_line_count(bufnr) > 10000 then return end
  return { timeout_ms = 1000, lsp_format = "fallback" }
end
```

| filetype | formatters | fallback |
|----------|------------|----------|
| python | ruff_fix → ruff_format | LSP |
| markdown | rumdl | LSP |
| (other) | — | LSP (`["_"] = { "lsp_format" }`) |

**no ftplugin BufWritePre** — conform owns the single write

---

## TREESITTER

```lua
ensure_installed = {
  "vim","vimdoc","rust","c","cpp","html","css",
  "javascript","json","lua","markdown","python",
  "typescript","vue","bash"
}
```

- `highlight.enable = true`
- `fold.enable = true` (expr = treesitter.foldexpr)
- **FileType autocmd**: start TS; if no parser → `bo.syntax = ""` (builtin syntax loads)

---

## SHELL (pwsh everywhere)

```lua
vim.o.shell = "pwsh"
vim.o.shelltemp = false
vim.o.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command " ..
  "[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();" ..
  "$PSDefaultParameterValues['Out-File:Encoding']='utf8';" ..
  "$PSStyle.OutputRendering = 'PlainText';"
vim.env.__SuppressAnsiEscapeSequences = "1"
vim.o.shellpipe = "> %s 2>&1"
vim.o.shellquote = ""
vim.o.shellxquote = ""
```

affects: `:terminal`, `:!`, `system()`, `:grep` (rg via grepprg)

---

## STATUSLINE

```
[%n] %<%f argidx:%{argc() ? (argidx()+1) . '/' . argc() : ''}  %{g:lsp_client_name} %h%w%m%r%=%-14.(%l,%c%V%) %P
```

- `argidx` hidden when arglist empty
- `g:lsp_client_name` updated on LspAttach/Detach/BufEnter/WinEnter

---

## AUTOCOMMANDS (groups)

| group | events | purpose |
|-------|--------|---------|
| PluginInit | PackChanged | bootstrap treesitter parsers, blink download |
| PluginConfig | — | (obsidian/render-markdown moved to top-level) |
| UserLSPConfig | LspAttach | keymaps, hover/format caps, diagnostics |
| StatuslineUpdate | LspAttach,Detach,BufEnter,BufWinEnter | update g:lsp_client_name |
| (conform) | BufWritePre | single format-on-save |
| (lint) | BufWritePost | try_lint() per ft |
| (treesitter) | FileType | start TS or fallback syntax |
| (shada) | CmdlineEnter (once) | defer shada load |
| (yank) | TextYankPost | vim.hl.hl_op() |

---

## FILETYPE OVERRIDES (after/ftplugin/)

| file | content |
|------|---------|
| python.lua | `vim.diagnostic.config({underline=true})` |
| markdown.lua | `vim.bo.textwidth = 80` |
| lua.lua | `tabstop=2, softtabstop=2, shiftwidth=2` |

---

## OPTIONS (non-default only)

```lua
-- UI
scrolloff=8, sidescrolloff=8, showtabline=2, number, relativenumber, cursorline
colorcolumn="80", textwidth=0 (global), winborder="rounded"
conceallevel=1, tabline="%t"

-- search
hlsearch, ignorecase, smartcase, incsearch
grepprg="rg --vimgrep --no-messages --smart-case"

-- fold
foldlevel=999, foldlevelstart=999, foldmethod=expr, foldexpr=v:lua.vim.treesitter.foldexpr()

-- indent
tabstop=4, softtabstop=4, shiftwidth=4, expandtab, shiftround, autoindent, smartindent

-- completion
completeopt={menu,menuone,noselect,noinsert,fuzzy,popup}
wildmenu, wildmode=longest:full,full, pumheight=10
complete+=o, wildoptions+=fuzzy

-- diagnostic
underline=false, virtual_text={prefix="●",spacing=4}, severity_sort
signs={ERROR="",WARN="",INFO="",HINT=""}
float={border="rounded",source=true,focusable=false,style="minimal"}

-- perf
updatetime=300, timeoutlen=500, redrawtime=5000, maxmempattern=20000
errorbells=false

-- file
autoread, undofile, no backup/writebackup/swapfile, no autochdir

-- clipboard
unnamedplus

-- mouse
mouse=a (popup disabled via aunmenu/autocmd!)

-- shada
defer load on CmdlineEnter
```

**removed**: `syntax=off`, `hidden`, `lazyredraw`, `modifiable`, `maxmempattern=1000(default)`

---

## COMMANDS

| command | action |
|---------|--------|
| `:Format` | conform.format with optional range |
| `:FormatDisable` | `g:disable_autoformat=true` |
| `:FormatEnable` | `g:disable_autoformat=false` |
| `:RestartWithSession` | mksession! + restart source |

---

## GIT / REPO HYGIENE

- `lsp/powerquery.lua` tracked
- `.rumdl_cache/` gitignored
- `none-ls.nvim` pruned from lockfile
- `--locked` not `--locded` in README
- commit msg typo `udpate` in HEAD (pushed — would need force-push to fix)

---

## REBUILD CHECKLIST

- [ ] `nvim --headless -c "qa!"` starts clean
- [ ] `:PackSync` installs all plugins
- [ ] `:TSUpdate` installs parsers
- [ ] `MasonInstall clangd` (or `:Mason` UI)
- [ ] `scoop install ripgrep python ruff ty` + `cargo install rumdl tree-sitter-cli` + `npm i -g @microsoft/language-server` (or your powerquery node server)
- [ ] `~/working/worknote` exists OR edit obsidian path in init.lua
- [ ] `~/.config/nvim/snippets/*.json` for mini.snippets (optional)
- [ ] verify `:terminal` shows `PS >` prompt
- [ ] open .py → `<leader>fm` formats with ruff
- [ ] open .md → save triggers rumdl (tw=80)
- [ ] `:FormatDisable` stops auto-format
- [ ] `[d` `]d` jump with float
- [ ] `grf` formats python with ruff LSP only

---

*end of guide — caveman out*