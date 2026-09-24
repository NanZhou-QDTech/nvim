-- lua/servers/powerquery.lua
return {
  cmd = {
    "node",
    vim.fn.stdpath("data") .. "/lsp-servers/powerquery/server.js",
    "--stdio",
  },
  filetypes = { "powerquery" },
  root_markers = { ".git" },
}