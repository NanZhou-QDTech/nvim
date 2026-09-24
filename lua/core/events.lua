-- lua/core/events.lua
-- Centralized autocmd registry

local Events = {}

Events.register = {
  -- { event, pattern?, callback, group, desc, once? }

  -- Treesitter fallback syntax
  { "FileType", nil, function(ev)
    if pcall(vim.treesitter.start, ev.buf) then
      vim.bo[ev.buf].syntax = ""
    end
  end, "TreesitterFallback", "TS highlight or syntax fallback" },

  -- Shada deferred load
  { "CmdlineEnter", nil, function()
    local shada = vim.fn.stdpath("state") .. "/shada/main.shada"
    vim.opt.shadafile = shada
    vim.cmd("rshada! " .. shada)
  end, "ShadaLoad", "Deferred shada load", true },

  -- Highlight yank
  { "TextYankPost", nil, function() vim.hl.hl_op() end, "HighlightYank", "Highlight on yank" },

  -- LSP signcolumn (separate from LspAttach for reliability)
  { "LspAttach", nil, function() vim.opt.signcolumn = "yes:2" end, "LspSigncolumn", "Signcolumn on attach" },
}

function Events.apply()
  for _, spec in ipairs(Events.register) do
    local event, pattern, callback, group, desc, once = unpack(spec)
    vim.api.nvim_create_autocmd(event, {
      pattern = pattern,
      group = vim.api.nvim_create_augroup(group, { clear = true }),
      callback = callback,
      desc = desc,
      once = once,
    })
  end
end

return Events