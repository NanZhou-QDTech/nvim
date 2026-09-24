-- lua/plugins/mini.lua
local M = {}

function M.setup()
  require("mini.icons").setup({})
  require("mini.comment").setup({})
  require("mini.surround").setup({})
  require("mini.pairs").setup({})

  -- Snippets loader from ~/.config/nvim/snippets/<lang>.json
  local gen_loader = require("mini.snippets").gen_loader
  require("mini.snippets").setup({
    snippets = { gen_loader.from_lang() },
  })
end

return M