-- lua/plugins/obsidian.lua
local M = {}
local Config = require("core.config")

function M.setup()
  local vault = Config.get("obsidian_vault")
  if not vault or vim.uv.fs_stat(vault) == nil then return end

  require("obsidian").setup({
    workspaces = { { name = "working", path = vault } },
  })
end

return M