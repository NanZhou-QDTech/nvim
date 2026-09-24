-- lua/user/autocmds.lua
-- User custom autocmds

local M = {}

function M.apply()
  -- Filetype-specific overrides (also in after/ftplugin/)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
      vim.diagnostic.config({ underline = true }, 0)
    end,
    desc = "Python: underline diagnostics",
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "lua",
    callback = function()
      vim.bo.tabstop = 2
      vim.bo.softtabstop = 2
      vim.bo.shiftwidth = 2
    end,
    desc = "Lua: 2-space indent",
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
      vim.bo.textwidth = 80
    end,
    desc = "Markdown: textwidth 80",
  })

  -- Add more user autocmds here
end

return M