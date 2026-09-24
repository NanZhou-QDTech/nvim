-- lua/core/init.lua
-- Core bootstrap: load order, error handling, hot reload

local Core = {}

---Bootstrap the entire configuration
---@param opts? { skip_plugins?: boolean, skip_lsp?: boolean }
function Core.bootstrap(opts)
  opts = opts or {}
  local ok, err = pcall(function()
    -- 1. Load & validate config (merges .config.lua)
    require("core.config").load()

    -- 2. Apply user options (vim.opt, etc.)
    require("user.options").apply()

    -- 3. Bootstrap plugins (async, lazy)
    if not opts.skip_plugins then
      require("core.loader").load_all()
    end

    -- 4. Register global keymaps
    require("core.keymaps").apply("global")

    -- 5. Register autocmds
    require("core.events").apply()

    -- 6. Setup LSP (servers, capabilities, attach)
    if not opts.skip_lsp then
      require("core.lsp").setup()
    end

    -- 7. Setup formatting (conform)
    require("core.format").setup()

    -- 8. Setup linting (nvim-lint)
    require("core.lint").setup()

    -- 9. Setup diagnostic UX
    require("core.diagnostic").setup()

    -- 10. Apply user keymaps
    require("user.keymaps").apply()

    -- 11. Apply user commands
    require("user.commands").apply()

    -- 12. Apply user autocmds
    require("user.autocmds").apply()

    -- 13. Register health checks
    vim.api.nvim_create_user_command("NvimCoreHealth", function()
      require("core.loader").health()
      require("core.config").health()
      require("core.lsp").health()
    end, { desc = "Run nvim-core health checks" })

    -- 14. Hot reload command
    vim.api.nvim_create_user_command("NvimCoreReload", function()
      Core.reload()
    end, { desc = "Hot reload nvim-core config" })
  end)

  if not ok then
    vim.notify("Core bootstrap failed: " .. tostring(err), vim.log.levels.ERROR)
    vim.api.nvim_echo({ { "Bootstrap error: " .. tostring(err), "ErrorMsg" } }, true, {})
  end
end

---Hot reload: clear package cache and re-bootstrap
function Core.reload()
  -- Clear all nvim-core modules from package.loaded
  for name, _ in pairs(package.loaded) do
    if name:match("^core%.") or name:match("^plugins%.") or name:match("^servers%.") or name:match("^user%.") then
      package.loaded[name] = nil
    end
  end

  -- Clear autocmds and keymaps we created
  vim.api.nvim_exec_autocmds("User", { pattern = "NvimCorePreReload" })

  -- Re-bootstrap
  Core.bootstrap()
  vim.notify("nvim-core reloaded", vim.log.levels.INFO)
end

---Setup for testing (minimal)
function Core.test_bootstrap()
  Core.bootstrap({ skip_plugins = true, skip_lsp = true })
end

return Core