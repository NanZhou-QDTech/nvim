-- .config.example.lua
-- Copy to .config.lua and modify (gitignored)
-- All values override defaults in core/config.lua

return {
  -- Shell: "pwsh" | "powershell" | "cmd" | "bash" | "zsh" | "fish"
  shell = "pwsh",

  -- Python provider (expanded via vim.fn.expand)
  python_venv = "~/projects/neovimpy/.venv/Scripts/python.exe",

  -- Obsidian vault path (obsidian.nvim only loads if this exists)
  obsidian_vault = "~/working/worknote",

  -- Format on save settings
  format = {
    timeout_ms = 1000,   -- conform timeout (ms)
    max_lines = 10000,   -- skip format if buffer larger
  },

  -- LSP overrides (merge with servers in lua/servers/)
  lsp = {
    servers = {
      -- Example: disable a server
      -- ruff = { enabled = false },
      -- Example: add custom server
      -- my_server = { cmd = { "my-lsp" }, filetypes = { "myft" } },
    },
  },

  -- Editor defaults (merged with user/options.lua)
  editor = {
    number = true,
    relativenumber = true,
    cursorline = true,
    colorcolumn = "80",
    tabstop = 4,
    shiftwidth = 4,
    expandtab = true,
  },
}