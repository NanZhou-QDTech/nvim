-- lua/core/format.lua (add health)
local Format = {}
local Config = require("core.config")

Format.formatters = {}

function Format.setup() end

function Format.format(opts)
  opts = opts or {}
  require("conform").format(vim.tbl_extend("force", {
    async = true,
    lsp_format = "fallback",
  }, opts))
end

function Format.toggle_autoformat(enable)
  if enable == nil then enable = not vim.g.disable_autoformat end
  vim.g.disable_autoformat = not enable
  vim.notify("Format on save " .. (enable and "enabled" or "disabled"))
end

function Format.is_enabled(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return not vim.g.disable_autoformat and not vim.b[bufnr].disable_autoformat
end

function Format.health()
  vim.health.start("nvim-core Format")
  vim.health.info("FormatDisable: " .. tostring(vim.g.disable_autoformat))
  vim.health.info("Conform loaded: " .. tostring(pcall(require, "conform")))
end

return Format