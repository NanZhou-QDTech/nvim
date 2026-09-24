-- lua/plugins/conform.lua
local M = {}
local Config = require("core.config")

function M.setup()
  local fmt_cfg = Config.get("format")

  require("conform").setup({
    formatters_by_ft = {
      python = { "ruff_fix", "ruff_format" },
      markdown = { "rumdl" },
      ["_"] = { "lsp_format" },
    },
    notify_on_error = true,
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end
      if vim.api.nvim_buf_line_count(bufnr) > (fmt_cfg.max_lines or 10000) then
        return
      end
      return {
        timeout_ms = fmt_cfg.timeout_ms or 1000,
        lsp_format = "fallback",
      }
    end,
  })

  -- User commands
  vim.api.nvim_create_user_command("Format", function(args)
    local range = nil
    if args.count ~= -1 then
      local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
      range = { start = { args.line1, 0 }, ["end"] = { args.line2, end_line:len() } }
    end
    require("conform").format({ async = true, lsp_format = "fallback", range = range })
  end, { range = true })

  vim.keymap.set({ "n", "v" }, "<leader>fm", function()
    require("conform").format({ async = true, lsp_format = "fallback" })
  end, { desc = "Format buffer" })

  vim.api.nvim_create_user_command("FormatDisable", function()
    vim.g.disable_autoformat = true
  end, { desc = "Disable format on save" })

  vim.api.nvim_create_user_command("FormatEnable", function()
    vim.g.disable_autoformat = false
  end, { desc = "Enable format on save" })
end

return M