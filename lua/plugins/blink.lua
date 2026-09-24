-- lua/plugins/blink.lua
local M = {}

function M.setup()
  require("blink.cmp").setup({
    keymap = { preset = "default" },
    sources = {
      default = { "lsp", "snippets", "path", "buffer" },
    },
    completion = {
      menu = { border = "rounded" },
      documentation = { auto_show = true },
      ghost_text = { enabled = true },
    },
    snippets = { preset = "mini_snippets" },
    fuzzy = { implementation = "prefer_rust" },
  })
end

return M