-- lua/plugins/lint.lua
local M = {}

function M.setup()
  require("lint").linters_by_ft = {
    lua = { "luac" },
    python = { "ruff" },
    markdown = { "rumdl" },
  }

  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    group = vim.api.nvim_create_augroup("LintOnSave", { clear = true }),
    callback = function()
      require("lint").try_lint()
    end,
    desc = "Lint on save",
  })
end

return M