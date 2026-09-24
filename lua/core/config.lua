-- lua/core/config.lua
-- Typed configuration schema with validation and merge

local Config = {}

Config.defaults = {
  shell = "pwsh",
  python_venv = "~/projects/neovimpy/.venv/Scripts/python.exe",
  obsidian_vault = "~/working/worknote",
  format = {
    timeout_ms = 1000,
    max_lines = 10000,
  },
  lsp = {
    servers = {},
    capabilities = {},
  },
  editor = {
    number = true,
    relativenumber = true,
    cursorline = true,
    colorcolumn = "80",
    tabstop = 4,
    shiftwidth = 4,
    expandtab = true,
  },
}

Config._merged = nil

---Load config: defaults < .config.lua < vim.g overrides
function Config.load()
  local merged = vim.deepcopy(Config.defaults)

  -- Load .config.lua if exists (gitignored user overrides)
  local config_path = vim.fn.stdpath("config") .. "/.config.lua"
  if vim.uv.fs_stat(config_path) then
    local ok, user_cfg = pcall(dofile, config_path)
    if ok and type(user_cfg) == "table" then
      merged = vim.tbl_deep_extend("force", merged, user_cfg)
    end
  end

  -- Allow vim.g.nvim_core_config to override (for testing)
  if vim.g.nvim_core_config then
    merged = vim.tbl_deep_extend("force", merged, vim.g.nvim_core_config)
  end

  -- Validate
  Config._validate(merged, Config.defaults, "")

  Config._merged = merged

  -- Apply shell config early (needed by other modules)
  if merged.shell == "pwsh" then
    vim.o.shell = "pwsh"
    vim.o.shelltemp = false
    vim.o.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command "
      .. "[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();"
      .. "$PSDefaultParameterValues['Out-File:Encoding']='utf8';"
      .. "$PSStyle.OutputRendering='PlainText';"
    vim.env.__SuppressAnsiEscapeSequences = "1"
    vim.o.shellpipe = "> %s 2>&1"
    vim.o.shellquote = ""
    vim.o.shellxquote = ""
  end

  -- Python provider
  local py = vim.fn.expand(merged.python_venv)
  if vim.uv.fs_stat(py) then
    vim.g.python3_host_prog = py
  end
end

---Get config value by dot-path (e.g., "format.timeout_ms")
---@param path string
---@return any
function Config.get(path)
  if not Config._merged then Config.load() end
  local cur = Config._merged
  for part in path:gmatch("[^%.]+") do
    if type(cur) ~= "table" then return nil end
    cur = cur[part]
  end
  return cur
end

---Set config value (runtime only, not persisted)
---@param path string
---@param value any
function Config.set(path, value)
  if not Config._merged then Config.load() end
  local parts = vim.split(path, "%.", { plain = true })
  local cur = Config._merged
  for i = 1, #parts - 1 do
    cur = cur[parts[i]]
  end
  cur[parts[#parts]] = value
end

---Validate merged config against defaults schema
---@param merged table
---@param defaults table
---@param prefix string
function Config._validate(merged, defaults, prefix)
  for key, def_val in pairs(defaults) do
    local path = prefix == "" and key or prefix .. "." .. key
    local val = merged[key]

    if val == nil then
      -- Use default, no error
    elseif type(def_val) == "table" and not vim.islist(def_val) then
      if type(val) ~= "table" then
        vim.notify(string.format("Config %s: expected table, got %s", path, type(val)), vim.log.levels.WARN)
      else
        Config._validate(val, def_val, path)
      end
    elseif type(val) ~= type(def_val) then
      vim.notify(string.format("Config %s: expected %s, got %s", path, type(def_val), type(val)), vim.log.levels.WARN)
    end
  end
end

function Config.health()
  vim.health.start("nvim-core Config")
  if Config._merged then
    vim.health.ok("Config loaded")
    for k, v in pairs(Config._merged) do
      vim.health.info(string.format("%s = %s", k, vim.inspect(v)))
    end
  else
    vim.health.warn("Config not loaded yet")
  end

  -- Check python provider
  local py = vim.g.python3_host_prog
  if py and vim.uv.fs_stat(py) then
    vim.health.ok("Python provider: " .. py)
  else
    vim.health.warn("Python provider not set or not found")
  end

  -- Check shell
  vim.health.info("Shell: " .. vim.o.shell)
end

return Config