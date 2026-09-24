# NVIM-CORE FRAMEWORK
*Async plugin loader + modular architecture for Neovim config*

---

## QUICK START

```bash
# 1. Backup old init.lua
mv init.lua init.lua.bak

# 2. Copy framework (already done)
# Structure:
# init.lua                    # 15 lines - entry point
# lua/core/                   # Framework core
# lua/plugins/                # Plugin configs
# lua/servers/                # LSP server configs
# lua/user/                   # User overrides
# .config.example.lua         # Template for local config
# .gitignore                  # ignores .config.lua
```

---

## ARCHITECTURE

```
init.lua → core.init.bootstrap()
    ├─ core.config.load()      # Schema validation, .config.lua merge
    ├─ user.options.apply()    # vim.opt.* (immediate)
    ├─ core.loader.load_all()  # ASYNC plugin loader
    │   ├─ Topological sort by deps
    │   ├─ Load non-lazy immediately
    │   ├─ Register lazy triggers (event, cmd, ft, keys)
    │   └─ Install via vim.pack.add() in vim.schedule
    ├─ core.events.apply()     # Centralized autocmds
    ├─ core.keymaps.apply()    # Global keymaps
    ├─ core.lsp.setup()        # LSP servers + capabilities + attach
    ├─ core.format.setup()     # Conform + FormatDisable
    ├─ core.lint.setup()       # nvim-lint
    ├─ core.diagnostic.setup() # Diagnostic UX
    └─ user.*                  # User keymaps, commands, autocmds
```

---

## ASYNC PLUGIN LOADER (`lua/core/loader.lua`)

### Features
- **Non-blocking**: `vim.pack.add()` runs in `vim.schedule()` → UI stays responsive
- **Dependency resolution**: Topological sort via `deps` field
- **Lazy loading**: `event`, `cmd`, `ft`, `keys`, `cond`
- **Priority ordering**: Higher `priority` = earlier load
- **Error boundaries**: `pcall` on init/config, failed plugins don't block others
- **Progress tracking**: `stats()` returns load times, states
- **Health check**: `:NvimCoreHealth` shows all plugin states

### Plugin Spec
```lua
{
  src = "https://github.com/owner/repo",
  version = "main",           -- optional
  name = "repo",              -- auto-derived
  lazy = true,                -- default true
  priority = 50,              -- default 50
  deps = { "other-plugin" },  -- load after deps
  event = "InsertEnter",      -- or { "Event1", "Event2" }
  cmd = "MyCommand",          -- or { "Cmd1", "Cmd2" }
  ft = "markdown",            -- or { "md", "markdown" }
  keys = "<leader>x",         -- or { "key1", "key2" }
  cond = function() return true end,  -- skip if false
  init = function() ... end,  -- runs BEFORE plugin loads
  config = function() ... end, -- runs AFTER plugin loads
}
```

### Usage
```lua
-- Load all (called by bootstrap)
require("core.loader").load_all()

-- Force load a lazy plugin
require("core.loader").force_load("blink.cmp")

-- Get stats
local stats = require("core.loader").stats()
-- { total=13, loaded=3, failed=0, pending=10, total_time=122.9 }

-- Hook into events
require("core.loader").on("on_plugin_loaded", function(name, time_ms)
  print(name .. " loaded in " .. time_ms .. "ms")
end)
```

---

## CONFIGURATION (`lua/core/config.lua`)

### Schema Validation
```lua
-- Defaults (in core/config.lua)
defaults = {
  shell = "pwsh",
  python_venv = "~/projects/neovimpy/.venv/Scripts/python.exe",
  obsidian_vault = "~/working/worknote",
  format = { timeout_ms = 1000, max_lines = 10000 },
  lsp = { servers = {}, capabilities = {} },
  editor = { number = true, relativenumber = true, ... },
}
```

### User Override (`.config.lua`, gitignored)
```lua
-- Copy .config.example.lua to .config.lua
return {
  obsidian_vault = "D:/notes/vault",
  format = { timeout_ms = 2000 },
  lsp = { servers = { ruff = { enabled = false } } },
}
```

### API
```lua
Config.get("format.timeout_ms")  -- 1000
Config.set("format.timeout_ms", 2000)  -- runtime only
```

---

## LSP FRAMEWORK (`lua/core/lsp.lua`)

### Single Source of Truth
```lua
LSP.servers = {
  lua_ls = require("servers.lua_ls"),
  ruff = require("servers.ruff"),
  -- ...
}
```

### Capabilities
```lua
local caps = vim.lsp.protocol.make_client_capabilities()
local ok, blink = pcall(require, "blink.cmp")
if ok then caps = blink.get_lsp_capabilities(caps) end
vim.lsp.config("*", { capabilities = caps })
```

### Server Config (`lua/servers/*.lua`)
```lua
return {
  filetypes = { "python" },
  cmd = { "ruff", "server" },
  root_markers = { "pyproject.toml", ".git" },
  init_options = { settings = { ... } },
}
```

### Attach Keymaps (in `on_attach`)
- `gd`, `gD`, `gri`, `grr`, `K` — navigation
- `gra`, `grn` — code action, rename
- `[d`, `]d` — diagnostic jump with float
- `grf` — format with ruff only

---

## HEALTH CHECKS

```vim
:NvimCoreHealth
```

Checks:
- Config loaded & validated
- Plugin states (loaded/failed/pending + load times)
- LSP servers enabled + binary availability
- Python provider path
- Shell configuration
- Diagnostic config

---

## HOT RELOAD

```vim
:NvimCoreReload
```
- Clears `package.loaded` for `core.*`, `plugins.*`, `servers.*`, `user.*`
- Fires `User NvimCorePreReload` autocmd
- Re-runs full bootstrap

---

## PERFORMANCE

| Metric | Target |
|--------|--------|
| Cold startup | < 30ms |
| Warm startup | < 10ms |
| Plugin install (parallel) | Non-blocking |
| Lazy plugin trigger | < 5ms |

### Startup Profile
```bash
nvim --startuptime log.txt -c "qa!"
# Check log.txt for require() times
```

---

## MIGRATION FROM MONOLITHIC INIT.LUA

| Old Location | New Location |
|--------------|--------------|
| `vim.opt.*` | `lua/user/options.lua` |
| Global keymaps | `lua/core/keymaps.lua` (Keymaps.global) |
| LSP keymaps | `lua/core/lsp.lua` (on_attach) |
| Autocmds | `lua/core/events.lua` + `lua/user/autocmds.lua` |
| Plugin configs | `lua/plugins/*.lua` |
| LSP server configs | `lua/servers/*.lua` |
| Commands | `lua/user/commands.lua` |
| Hardcoded paths | `Config.get()` or `.config.lua` |

---

## EXTENDING

### Add LSP Server
```lua
-- lua/servers/my_server.lua
return { filetypes = { "myft" }, cmd = { "my-lsp" } }

-- lua/core/lsp.lua
LSP.servers.my_server = require("servers.my_server")
```

### Add Formatter
```lua
-- lua/plugins/conform.lua (in formatters_by_ft)
myft = { "my_formatter" },
```

### Add Lazy Plugin
```lua
-- lua/core/loader.lua (add to specs)
{ src = "https://github.com/owner/repo", lazy = true, event = "VeryLazy", config = ... }
```

### Add Health Check
```lua
-- In any module
function M.health()
  vim.health.start("nvim-core MyModule")
  vim.health.ok("Works")
end
```

---

## FILES CREATED

```
lua/
├── core/
│   ├── init.lua       # Bootstrap (30 lines)
│   ├── config.lua     # Schema + validation + merge
│   ├── loader.lua     # ASYNC plugin loader
│   ├── events.lua     # Autocmd registry
│   ├── keymaps.lua    # Declarative keymaps
│   ├── lsp.lua        # LSP framework
│   ├── format.lua     # Conform wrapper
│   ├── lint.lua       # nvim-lint wrapper
│   ├── diagnostic.lua # Diagnostic UX
│   └── health.lua     # :checkhealth provider
├── plugins/
│   ├── treesitter.lua
│   ├── oil.lua
│   ├── mini.lua
│   ├── blink.lua
│   ├── conform.lua
│   ├── lint.lua
│   ├── render_markdown.lua
│   ├── obsidian.lua
│   └── mason.lua
├── servers/
│   ├── lua_ls.lua
│   ├── ruff.lua
│   ├── ty.lua
│   ├── marksman.lua
│   ├── rumdl.lua
│   ├── clangd.lua
│   └── powerquery.lua
└── user/
    ├── options.lua
    ├── keymaps.lua
    ├── commands.lua
    └── autocmds.lua

.config.example.lua    # Template
.gitignore             # + .config.lua
init.lua               # 15-line entry point
```

---

## VERIFICATION

```bash
# 1. Bootstrap works
nvim --headless -u init.lua -c "lua print('ok')" -c "qa!"

# 2. Plugins load
nvim --headless -u init.lua -c "lua require('core.loader').load_all()" -c "qa!"

# 3. LSP enabled
nvim --headless -u init.lua -c "lua print(vim.lsp.is_enabled('lua_ls'))" -c "qa!"

# 4. Options applied
nvim --headless -u init.lua -c "lua print(vim.o.colorcolumn)" -c "qa!"

# 5. Health check
nvim --headless -u init.lua -c "lua require('core.loader').health()" -c "qa!"
```

---

*Framework ready for production use*