-- lua/servers/ruff.lua
return {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
  init_options = {
    settings = {
      fixAll = true,
      configurationPreference = "editorFirst",
      exclude = { "tests", ".git", "__pycache__", ".venv", "venv", "build", "dist" },
      lineLength = 88,
      format = { ["quote-style"] = "single", ["indent-style"] = "space" },
      lint = { select = { "E", "W", "F", "I", "B", "C4", "UP" }, ignore = { "E501" } },
      logLevel = "warn",
    },
  },
}