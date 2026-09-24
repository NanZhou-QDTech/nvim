-- lua/core/health.lua
-- :checkhealth nvim-core providers

local Health = {}

function Health.register()
  vim.health = vim.health or {}

  -- This is called by :checkhealth
  vim.health.nvim_core = function()
    require("core.config").health()
    require("core.loader").health()
    require("core.lsp").health()
    require("core.format").health()
    require("core.diagnostic").health()
  end
end

function Health.setup()
  -- Register with vim.health
  vim.api.nvim_create_user_command("NvimCoreHealth", function()
    vim.health.start("nvim-core")
    require("core.config").health()
    require("core.loader").health()
    require("core.lsp").health()
    require("core.format").health()
    require("core.diagnostic").health()
  end, { desc = "Run nvim-core health checks" })
end

return Health