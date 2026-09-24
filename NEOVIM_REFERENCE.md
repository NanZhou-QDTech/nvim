# NEOVIM RUNTIME DOC REFERENCE
*Portable config reference — extract from neovim/runtime/doc*
*Check: `:echo has("nvim-0.11")` → 1 = OK for modern API*

---

## CORE SETUP

| topic | doc tag | key points |
|-------|---------|------------|
| starting | `starting.txt` | `--headless`, `--clean`, `-u NORC`, `stdpath()` |
| options | `options.txt` | `vim.o`, `vim.opt`, `vim.bo`, `vim.wo` — buffer/window/global |
| lua-guide | `lua-guide.txt` | `require()`, `vim.api`, `vim.fn`, `vim.uv` (libuv) |
| vim_diff | `vim_diff.txt` | nvim vs vim differences |

---

## PLUGIN MANAGER (vim.pack)

| tag | command | notes |
|-----|---------|-------|
| `pack-add()` | `vim.pack.add({specs})` | specs: string or `{src, version?, opt?}` |
| `pack-update` | `vim.pack.update()` | updates all; `vim.pack.update({names})` subset |
| `pack-del` | `vim.pack.del({name})` | removes inactive plugin |
| `PackChanged` | `autocmd PackChanged` | fires inside `add()` on first install/update |
| lockfile | `nvim-pack-lock.json` | auto-managed; do not edit by hand |

**portable pattern:**
```lua
vim.pack.add({
  "https://github.com/owner/repo",
  { src = "https://github.com/owner/repo", version = "main" },
})
```

---

## LSP (lsp.txt)

### config & enable
| tag | api | notes |
|-----|-----|-------|
| `vim.lsp.config` | `vim.lsp.config(name, config)` | global defaults with `"*"` |
| `vim.lsp.enable` | `vim.lsp.enable({names})` | starts clients for matching filetypes |
| `vim.lsp.config` | `vim.lsp.config[name]` | read effective config |
| `lsp-config-filetype` | `filetypes = {}` | required in config or auto from `root_markers` |

### attach & capabilities
| tag | api |
|-----|-----|
| `LspAttach` | `vim.api.nvim_create_autocmd("LspAttach", {callback})` |
| `vim.lsp.get_clients` | `vim.lsp.get_clients({bufnr, name})` |
| `vim.lsp.protocol.make_client_capabilities` | base caps |
| `vim.lsp.completion.enable` | `enable(true, client_id, bufnr, {autotrigger})` |

### keymaps (default in 0.11+)
| lhs | action |
|-----|--------|
| `grn` | rename |
| `gra` | code_action |
| `grr` | references |
| `gri` | implementation |
| `gd` | definition |
| `gD` | declaration |
| `K` | hover |
| `<C-s>` (insert) | signature_help |

---

## TREESITTER (treesitter.txt)

| tag | api |
|-----|-----|
| `vim.treesitter.start` | `vim.treesitter.start(bufnr, lang?)` |
| `vim.treesitter.stop` | `vim.treesitter.stop(bufnr)` |
| `vim.treesitter.get_parser` | `get_parser(bufnr, lang?)` |
| `vim.treesitter.foldexpr` | `foldexpr()` for `foldmethod=expr` |
| `nvim-treesitter-config` | `require("nvim-treesitter").setup({highlight, fold, ...})` |
| `TSInstall` | `:TSInstall lang` |
| `TSUpdate` | `:TSUpdate` |

**parser list:** `nvim-treesitter.config.get_installed()`

---

## DIAGNOSTIC (diagnostic.txt)

| tag | api |
|-----|-----|
| `vim.diagnostic.config` | global config: `underline`, `virtual_text`, `signs`, `float`, `severity_sort`, `update_in_insert` |
| `vim.diagnostic.jump` | `jump({count, on_jump?})` — **`float` deprecated, use `on_jump`** |
| `vim.diagnostic.open_float` | `open_float({bufnr, scope="cursor"|"line"|"buffer"})` |
| `vim.diagnostic.setloclist` | populate location list |
| `vim.diagnostic.get` | `get(bufnr?, opts?)` → list |
| `vim.diagnostic.set` | `set(namespace, bufnr, diagnostics, opts)` |

### JumpOpts fields
```
count?       integer  (positive=forward, negative=backward)
on_jump?     fun(diagnostic?, bufnr)
wrap?        boolean (default true)
severity?    min/max severity
```

---

## AUTOCOMMANDS (autocmd.txt)

| tag | pattern |
|-----|---------|
| `autocmd-events` | `BufWritePre`, `BufWritePost`, `FileType`, `LspAttach`, `LspDetach`, `TextYankPost`, `CmdlineEnter`, `VimEnter`, `PackChanged` |
| `autocmd-groups` | `vim.api.nvim_create_augroup(name, {clear=true})` |
| `autocmd-callback` | `callback = function(ev) ... end` — `ev.buf`, `ev.match`, `ev.data` |

---

## KEYMAPS (map.txt, lua.txt)

| tag | api |
|-----|-----|
| `vim.keymap.set` | `set(mode, lhs, rhs, {desc, buffer, silent, noremap, expr, replace_keycodes})` |
| `map-modes` | `n`, `v`, `x`, `s`, `o`, `i`, `c`, `t`, `!` |
| `map-rhs` | `string` \| `function` |
| `maparg` | `vim.fn.maparg(lhs, mode)` — inspect mapping |
| `<leader>` | `vim.g.mapleader` (default `\`) |
| `<localleader>` | `vim.g.maplocalleader` |

---

## COMPLETION (ins-completion.txt)

| tag | option |
|-----|--------|
| `completeopt` | `menu`, `menuone`, `noselect`, `noinsert`, `popup`, `fuzzy`, `preview` |
| `complete` | `.` `w` `b` `u` `t` `i` `]` `]` `k` `k` `k` — `o` = omni |
| `wildmode` | `longest:full,full` |
| `wildoptions` | `fuzzy`, `pum`, `tagfile` |

---

## FORMATTING (vim.lsp.buf.format, conform.nvim not in runtime)

| tag | api |
|-----|-----|
| `vim.lsp.buf.format` | `format({async, bufnr, range, filter, timeout_ms, formatting_options})` |
| `vim.lsp.buf.range_format` | deprecated → use `format({range})` |
| `filter` | `function(client) return bool end` — select formatter |

---

## FILETYPE & PATH (filetype.txt, usr_40.txt)

| tag | api |
|-----|-----|
| `vim.filetype.add` | `add({extension={}, filename={}, pattern={}})` |
| `vim.bo.filetype` | buffer-local filetype |
| `path` | `vim.opt.path:append("**")` — `:find` searches recursively |
| `suffixesadd` | `vim.opt.suffixesadd:append({".lua", ".py"})` |

---

## TERMINAL (terminal.txt)

| tag | note |
|-----|------|
| `:terminal` | runs `&shell` if no args |
| `termopen()` | `vim.fn.termopen(cmd, {on_exit, cwd, env})` |
| `terminal-ms-windows` | ConPTY; pwsh needs `shell-pwsh` settings |

---

## SHELL ON WINDOWS (options.txt → `shell-powershell`, `shell-pwsh`)

```vim
set shell=pwsh
set shelltemp=off
set shellcmdflag=-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';$PSStyle.OutputRendering='PlainText';
set shellpipe=> %s 2>&1
set shellquote=
set shellxquote=
let $__SuppressAnsiEscapeSequences = 1
```

Affects: `:terminal`, `:!cmd`, `system()`, `:grep` (via `shellpipe`)

---

## STATUSLINE (statusline.txt)

| item | meaning |
|------|---------|
| `%n` | buffer number |
| `%f` | filename |
| `%h` | help flag |
| `%w` | preview flag |
| `%m` | modified |
| `%r` | readonly |
| `%=` | split point |
| `%l,%c,%V` | line, col, virtual col |
| `%P` | percentage through file |
| `%{expr}` | evaluate Vim expression |

---

## FOLDING (fold.txt, usr_28.txt)

| option | value |
|--------|-------|
| `foldmethod` | `expr` |
| `foldexpr` | `v:lua.vim.treesitter.foldexpr()` |
| `foldlevel` | `999` (open all) |
| `foldlevelstart` | `999` |
| `foldopen` | `foldopen` (in nvim-treesitter setup) |

---

## SEARCH & GREP (options.txt, usr_27.txt)

| option | typical |
|--------|---------|
| `grepprg` | `rg --vimgrep --no-messages --smart-case` |
| `grepformat` | `%f:%l:%c:%m` (auto from `--vimgrep`) |
| `ignorecase` + `smartcase` | on |
| `incsearch` + `hlsearch` | on |

---

## SHADA (shada.txt)

| option | note |
|--------|------|
| `shadafile` | `NONE` to disable; defer load on `CmdlineEnter` |
| `shada` | `!,'100,<50,s10,h` (default) |

---

## CLIPBOARD (clipboard.txt)

| option | value |
|--------|-------|
| `clipboard` | `unnamedplus` (system clipboard via `+` register) |

---

## MOUSE (mouse.txt)

| option | value |
|--------|-------|
| `mouse` | `a` (all modes) |
| disable popup | `aunmenu PopUp` + `autocmd! nvim.popupmenu` |

---

## UNDO (undo.txt)

| option | value |
|--------|-------|
| `undofile` | `true` |
| `undodir` | `stdpath("state") .. "/undo"` |

---

## HIGHLIGHT & SYNTAX (syntax.txt, usr_44.txt)

| option | value |
|--------|-------|
| `syntax` | per-buffer; `""` = off for buffer |
| `synmaxcol` | `300` (perf) |
| `termguicolors` | `true` |
| `vim.hl.hl_op()` | TextYankPost highlight yank |

---

## PYTHON PROVIDER (provider.txt)

```lua
vim.g.python3_host_prog = "/path/to/python"
-- check: :checkhealth provider
```

---

## MINIMAL INIT FOR TESTING

```lua
-- test_init.lua
vim.opt.rtp:prepend(vim.fn.stdpath("config"))
require("init")  -- your config
```

Run: `nvim --headless -u test_init.lua -c "qa!"`

---

## OPENDCODE REFERENCE CHECK

```bash
# verify opencode can read neovim/runtime/doc
ls "$HOME/.local/share/opencode/repos/github.com/neovim/neovim/runtime/doc/*.txt" | head -5
# should list: autocmd.txt diagnostic.txt lsp.txt options.txt ...
```

If missing: `opencode` clones on first use; or manually:
```bash
git clone --depth 1 https://github.com/neovim/neovim ~/.local/share/opencode/repos/github.com/neovim/neovim
```

---

## VERSION CHECKLIST (nvim 0.11+)

- [ ] `vim.lsp.enable()` exists
- [ ] `vim.lsp.config()` exists
- [ ] `vim.pack` module exists
- [ ] `vim.diagnostic.jump()` has `on_jump`
- [ ] `vim.treesitter.foldexpr()` exists
- [ ] `vim.hl.hl_op()` exists
- [ ] `vim.uv` (libuv) available
- [ ] default `gr*` keymaps work

Run: `nvim --headless -c "lua print(vim.version().major..'.'..vim.version().minor)" -c "qa!"`

---

*end — all tags searchable via `:h <tag>` in nvim*