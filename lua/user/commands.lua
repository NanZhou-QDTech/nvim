-- lua/user/commands.lua
-- User custom commands

local M = {}

function M.apply()
  vim.api.nvim_create_user_command("RestartWithSession", function()
    vim.cmd("mksession! Session.vim | restart source Session.vim")
  end, { nargs = 0, desc = "Restart with session" })

  -- Add more user commands here
end

return M