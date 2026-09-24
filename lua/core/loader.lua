-- lua/core/loader.lua
-- Async plugin loader for vim.pack with dependency resolution and lazy loading

local Loader = {}
local Config = require("core.config")

---@class PluginSpec
---@field src string
---@field version? string
---@field name? string          -- auto-derived from src if missing
---@field lazy? boolean         -- default: true
---@field priority? number      -- load order (higher = earlier), default: 50
---@field deps? string[]        -- plugin names this depends on
---@field event? string|string[]   -- autocmd event(s) to trigger load
---@field cmd? string|string[]     -- command(s) to trigger load
---@field ft? string|string[]      -- filetype(s) to trigger load
---@field keys? string|string[]    -- keymap(s) to trigger load
---@field cond? fun():boolean      -- condition function, plugin skipped if false
---@field config? fun()            -- setup function called after load
---@field init? fun()              -- pre-load init (runs before plugin loads)
---@field build? string|fun()      -- build command (not used by vim.pack)

---@type PluginSpec[]
Loader.specs = {
  -- CORE (load immediately, high priority)
  { src = "https://github.com/nvim-lua/plenary.nvim", priority = 100, lazy = false },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main", priority = 100, lazy = false,
    config = function() require("plugins.treesitter").setup() end },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main", priority = 90,
    deps = { "nvim-treesitter" }, lazy = true, event = "BufReadPost" },

  -- UI / EDITOR (lazy, triggered by commands/keys)
  { src = "https://github.com/stevearc/oil.nvim", priority = 80, cmd = "Oil", keys = { "-" },
    config = function() require("plugins.oil").setup() end },
  { src = "https://github.com/nvim-mini/mini.nvim", priority = 70, lazy = false,
    config = function() require("plugins.mini").setup() end },

  -- LSP ECOSYSTEM (lazy, triggered by LspAttach or commands)
  { src = "https://github.com/neovim/nvim-lspconfig", priority = 60, lazy = true, event = "LspAttach" },
  { src = "https://github.com/mason-org/mason.nvim", priority = 55, lazy = true, cmd = "Mason",
    config = function() require("plugins.mason").setup() end },

  -- COMPLETION (lazy, InsertEnter)
  { src = "https://github.com/saghen/blink.lib", priority = 50, lazy = true, event = "InsertEnter" },
  { src = "https://github.com/saghen/blink.cmp", version = "2.*", priority = 50, lazy = true, event = "InsertEnter",
    deps = { "blink.lib" }, config = function() require("plugins.blink").setup() end },

  -- FORMATTING (lazy, BufWritePre)
  { src = "https://github.com/stevearc/conform.nvim", priority = 40, lazy = true, event = "BufWritePre",
    config = function() require("plugins.conform").setup() end },

  -- LINTING (lazy, BufWritePost)
  { src = "https://github.com/mfussenegger/nvim-lint", priority = 40, lazy = true, event = "BufWritePost",
    config = function() require("plugins.lint").setup() end },

  -- MARKDOWN / OBSIDIAN (conditional, markdown ft)
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim", priority = 30, lazy = true, ft = "markdown",
    config = function() require("plugins.render_markdown").setup() end },
  { src = "https://github.com/epwalsh/obsidian.nvim", priority = 25, lazy = true, ft = "markdown",
    cond = function() return vim.uv.fs_stat(Config.get("obsidian_vault")) ~= nil end,
    config = function() require("plugins.obsidian").setup() end },
}

---@alias PluginState "pending" | "installing" | "installed" | "loading" | "loaded" | "failed"

---@class PluginRuntime
---@field spec PluginSpec
---@field state PluginState
---@field error? string
---@field load_start? number
---@field load_time? number

Loader.plugins = {} ---@type table<string, PluginRuntime>
Loader.load_order = {} ---@type string[]
Loader._callbacks = {} ---@type table<string, fun()[]>  -- event -> callbacks

---Derive plugin name from src URL
---@param src string
---@return string
local function name_from_src(src)
  return src:match("([^/]+)%.git$") or src:match("([^/]+)$") or src
end

---Normalize spec: fill defaults, derive name
---@param spec PluginSpec
---@return PluginSpec
local function normalize_spec(spec)
  spec = vim.deepcopy(spec)
  spec.name = spec.name or name_from_src(spec.src)
  spec.lazy = spec.lazy ~= false  -- default true
  spec.priority = spec.priority or 50
  spec.deps = spec.deps or {}
  if type(spec.event) == "string" then spec.event = { spec.event } end
  if type(spec.cmd) == "string" then spec.cmd = { spec.cmd } end
  if type(spec.ft) == "string" then spec.ft = { spec.ft } end
  if type(spec.keys) == "string" then spec.keys = { spec.keys } end
  return spec
end

---Topological sort by dependencies
---@param specs PluginSpec[]
---@return PluginSpec[]
local function topo_sort(specs)
  local graph = {} ---@type table<string, string[]>
  local indegree = {} ---@type table<string, number>
  local by_name = {} ---@type table<string, PluginSpec>

  for _, s in ipairs(specs) do
    by_name[s.name] = s
    graph[s.name] = {}
    indegree[s.name] = 0
  end

  for _, s in ipairs(specs) do
    for _, dep in ipairs(s.deps) do
      if by_name[dep] then
        table.insert(graph[dep], s.name)
        indegree[s.name] = indegree[s.name] + 1
      else
        vim.notify(string.format("Plugin '%s' depends on missing '%s'", s.name, dep), vim.log.levels.WARN)
      end
    end
  end

  local queue = {}
  for name, deg in pairs(indegree) do
    if deg == 0 then table.insert(queue, name) end
  end

  local sorted = {}
  while #queue > 0 do
    table.sort(queue, function(a, b)
      return (by_name[a].priority or 50) > (by_name[b].priority or 50)
    end)
    local name = table.remove(queue, 1)
    table.insert(sorted, by_name[name])
    for _, child in ipairs(graph[name]) do
      indegree[child] = indegree[child] - 1
      if indegree[child] == 0 then table.insert(queue, child) end
    end
  end

  if #sorted ~= #specs then
    vim.notify("Circular dependency detected in plugin specs", vim.log.levels.ERROR)
    return specs  -- fallback
  end
  return sorted
end

---Check if plugin should load now (lazy triggers)
---@param spec PluginSpec
---@return boolean
local function should_load_now(spec)
  if spec.lazy == false then return true end
  if spec.cond and not spec.cond() then return false end
  -- Note: event/cmd/ft/keys are handled by registering triggers, not here
  return false
end

---Register lazy triggers for a plugin
---@param runtime PluginRuntime
local function register_triggers(runtime)
  local spec = runtime.spec
  local name = spec.name

  local function trigger_load()
    if runtime.state == "pending" or runtime.state == "installed" then
      Loader.load_plugin(name)
    end
  end

  if spec.event then
    for _, ev in ipairs(spec.event) do
      vim.api.nvim_create_autocmd(ev, {
        once = true,
        callback = trigger_load,
        desc = string.format("Lazy load %s", name),
      })
    end
  end

  if spec.cmd then
    for _, cmd in ipairs(spec.cmd) do
      vim.api.nvim_create_user_command(cmd, function()
        trigger_load()
        -- Re-execute the command after plugin loads
        vim.schedule(function() vim.cmd(cmd .. " " .. table.concat(vim.v.argv or {}, " ")) end)
      end, { nargs = "*", desc = string.format("Lazy load %s via %s", name, cmd) })
    end
  end

  if spec.ft then
    for _, ft in ipairs(spec.ft) do
      vim.api.nvim_create_autocmd("FileType", {
        pattern = ft,
        once = true,
        callback = trigger_load,
        desc = string.format("Lazy load %s for %s", name, ft),
      })
    end
  end

  if spec.keys then
    for _, key in ipairs(spec.keys) do
      vim.keymap.set("n", key, function()
        trigger_load()
        -- Replay the key after load
        vim.schedule(function() vim.api.nvim_feedkeys(key, "n", false) end)
      end, { desc = string.format("Lazy load %s via %s", name, key) })
    end
  end
end

---Load a single plugin asynchronously
---@param name string
---@return boolean success
function Loader.load_plugin(name)
  local runtime = Loader.plugins[name]
  if not runtime then return false end
  if runtime.state == "loading" or runtime.state == "loaded" then return true end

  runtime.state = "loading"
  runtime.load_start = vim.uv.hrtime()

  local spec = runtime.spec

  -- Run init if provided (pre-load)
  if spec.init then
    local ok, err = pcall(spec.init)
    if not ok then
      runtime.state = "failed"
      runtime.error = "init: " .. err
      vim.notify(string.format("Plugin %s init failed: %s", name, err), vim.log.levels.ERROR)
      return false
    end
  end

  -- vim.pack.add is synchronous for local plugins, but we wrap in vim.schedule
  -- to yield to event loop and allow parallel installation
  vim.schedule(function()
    local ok, err = pcall(function()
      vim.pack.add({ { src = spec.src, version = spec.version } })
    end)

    if not ok then
      runtime.state = "failed"
      runtime.error = "pack.add: " .. err
      vim.notify(string.format("Plugin %s install failed: %s", name, err), vim.log.levels.ERROR)
      Loader._fire("on_plugin_failed", name, err)
      return
    end

    runtime.state = "installed"

    -- Run config/setup after install
    if spec.config then
      local cfg_ok, cfg_err = pcall(spec.config)
      if not cfg_ok then
        runtime.state = "failed"
        runtime.error = "config: " .. cfg_err
        vim.notify(string.format("Plugin %s config failed: %s", name, cfg_err), vim.log.levels.ERROR)
        Loader._fire("on_plugin_failed", name, cfg_err)
        return
      end
    end

    runtime.state = "loaded"
    runtime.load_time = (vim.uv.hrtime() - runtime.load_start) / 1e6
    Loader._fire("on_plugin_loaded", name, runtime.load_time)
  end)

  return true
end

---Load all non-lazy plugins immediately, register triggers for lazy ones
function Loader.load_all()
  local sorted = topo_sort(vim.tbl_map(normalize_spec, Loader.specs))

  -- Initialize runtime table
  for _, spec in ipairs(sorted) do
    Loader.plugins[spec.name] = {
      spec = spec,
      state = "pending",
    }
    table.insert(Loader.load_order, spec.name)
  end

  -- First pass: load non-lazy immediately
  for _, name in ipairs(Loader.load_order) do
    local runtime = Loader.plugins[name]
    if should_load_now(runtime.spec) then
      Loader.load_plugin(name)
    else
      register_triggers(runtime)
    end
  end

  Loader._fire("on_all_loaded")
end

---Get plugin load stats
---@return table
function Loader.stats()
  local stats = { total = 0, loaded = 0, failed = 0, pending = 0, total_time = 0 }
  for _, runtime in pairs(Loader.plugins) do
    stats.total = stats.total + 1
    if runtime.state == "loaded" then
      stats.loaded = stats.loaded + 1
      stats.total_time = stats.total_time + (runtime.load_time or 0)
    elseif runtime.state == "failed" then
      stats.failed = stats.failed + 1
    else
      stats.pending = stats.pending + 1
    end
  end
  return stats
end

---Event system for loader hooks
---@param event string
---@param callback fun(...)
function Loader.on(event, callback)
  Loader._callbacks[event] = Loader._callbacks[event] or {}
  table.insert(Loader._callbacks[event], callback)
end

---@param event string
---@param ... any
function Loader._fire(event, ...)
  for _, cb in ipairs(Loader._callbacks[event] or {}) do
    pcall(cb, ...)
  end
end

---Health check for :checkhealth
function Loader.health()
  local stats = Loader.stats()
  vim.health.start("nvim-core Plugin Loader")
  vim.health.info(string.format("Total: %d | Loaded: %d | Failed: %d | Pending: %d | Total time: %.1fms",
    stats.total, stats.loaded, stats.failed, stats.pending, stats.total_time))

  for name, runtime in pairs(Loader.plugins) do
    if runtime.state == "loaded" then
      vim.health.ok(string.format("%s (%.1fms)", name, runtime.load_time or 0))
    elseif runtime.state == "failed" then
      vim.health.error(string.format("%s: %s", name, runtime.error or "unknown"))
    elseif runtime.state == "pending" then
      vim.health.info(string.format("%s (pending)", name))
    end
  end
end

---Force load a lazy plugin by name
---@param name string
function Loader.force_load(name)
  local runtime = Loader.plugins[name]
  if not runtime then
    vim.notify("Plugin not found: " .. name, vim.log.levels.ERROR)
    return
  end
  Loader.load_plugin(name)
end

return Loader