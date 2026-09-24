-- lua/core/lint.lua
-- Linter registry (nvim-lint wrapper)

local Lint = {}

function Lint.setup()
  -- nvim-lint setup is in plugins/lint.lua
end

---Run linters for current buffer
---@param opts? { names?: string|string[] }
function Lint.try_lint(opts)
  require("lint").try_lint(opts and opts.names)
end

return Lint