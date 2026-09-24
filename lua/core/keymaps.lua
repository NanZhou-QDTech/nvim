-- lua/core/keymaps.lua
-- Declarative keymap registry

local Keymaps = {}

Keymaps.global = {
  -- Terminal
  { "t", "<Esc><Esc>", "<C-\\><C-n>", "Exit terminal mode" },
  { "t", "<A-h>", "<C-\\><C-n><C-w>h", "Window left from terminal" },
  { "t", "<A-l>", "<C-\\><C-n><C-w>l", "Window right from terminal" },
  { "t", "<A-j>", "<C-\\><C-n><C-w>j", "Window up from terminal" },
  { "t", "<A-k>", "<C-\\><C-n><C-w>k", "Window down from terminal" },

  -- General
  { "n", "<Esc>", "<Cmd>nohl<CR>", "Clear highlights" },
  { "n", "G", "Gzz", "Go to bottom centered" },
  { "n", "n", "nzz", "Next search centered" },
  { "n", "N", "Nzz", "Prev search centered" },
  { "v", "<", "<gv", "Outdent keep selection" },
  { "v", ">", ">gv", "Indent keep selection" },

  -- Arglist (harpoon-lite)
  { "n", "<leader>aa", function() vim.cmd("$argadd %"); vim.cmd("argdedup") end, "Arglist add" },
  { "n", "<leader>ad", function() vim.cmd("$argdelete %") end, "Arglist delete" },
  { "n", "<leader>al", function() vim.cmd("args") end, "Arglist show" },
  { "n", "<leader>a1", function() vim.cmd("silent! 1argument") end, "Arglist goto 1" },
  { "n", "<leader>a2", function() vim.cmd("silent! 2argument") end, "Arglist goto 2" },
  { "n", "<leader>a3", function() vim.cmd("silent! 3argument") end, "Arglist goto 3" },
  { "n", "<leader>a4", function() vim.cmd("silent! 4argument") end, "Arglist goto 4" },
  { "n", "<leader>a5", function() vim.cmd("silent! 5argument") end, "Arglist goto 5" },

  -- Format
  { "n", "<leader>fm", function() require("core.format").format() end, "Format buffer" },
  { "v", "<leader>fm", function() require("core.format").format() end, "Format selection" },
}

Keymaps.lsp_attach = {}  -- Populated by core/lsp.lua on_attach

---Apply keymaps for scope
---@param scope "global" | "lsp_attach"
---@param bufnr? integer
function Keymaps.apply(scope, bufnr)
  local maps = Keymaps[scope]
  if not maps then return end
  for _, m in ipairs(maps) do
    local mode, lhs, rhs, desc = m[1], m[2], m[3], m[4]
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end
end

return Keymaps