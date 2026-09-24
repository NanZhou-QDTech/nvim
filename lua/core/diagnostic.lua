-- lua/core/diagnostic.lua (add health)
local Diagnostic = {}

function Diagnostic.setup()
  vim.diagnostic.config({
    underline = false,
    virtual_text = { prefix = "●", spacing = 4 },
    update_in_insert = false,
    severity_sort = true,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = " ",
        [vim.diagnostic.severity.WARN] = " ",
        [vim.diagnostic.severity.INFO] = " ",
        [vim.diagnostic.severity.HINT] = " ",
      },
    },
    float = {
      border = "rounded",
      source = true,
      header = "",
      prefix = "",
      focusable = false,
      style = "minimal",
    },
  })
end

function Diagnostic.next()
  vim.diagnostic.jump({
    count = 1,
    on_jump = function(diag, buf)
      if diag then vim.diagnostic.open_float({ bufnr = buf, scope = "cursor", focus = false }) end
    end,
  })
end

function Diagnostic.prev()
  vim.diagnostic.jump({
    count = -1,
    on_jump = function(diag, buf)
      if diag then vim.diagnostic.open_float({ bufnr = buf, scope = "cursor", focus = false }) end
    end,
  })
end

function Diagnostic.health()
  vim.health.start("nvim-core Diagnostic")
  vim.health.ok("Diagnostic config applied")
end

return Diagnostic