-- lua/plugins/treesitter.lua
local M = {}

function M.setup()
  require("nvim-treesitter").setup({
    highlight = { enable = true },
    fold = { enable = true, foldopen = "foldopen" },
    -- ensure_installed handled by PackChanged bootstrap
  })

  -- Fallback to builtin syntax when no parser
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("TreesitterFallback", { clear = true }),
    callback = function(ev)
      if pcall(vim.treesitter.start, ev.buf) then
        vim.bo[ev.buf].syntax = ""
      end
    end,
    desc = "TS highlight or syntax fallback",
  })
end

return M