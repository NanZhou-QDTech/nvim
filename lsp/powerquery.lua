-- Power Query / M language server
-- Server extracted from Microsoft's vscode-powerquery extension (VSIX).
-- Update: re-download the VSIX and replace server.js.
return {
  cmd = {
    "node",
    vim.fn.stdpath("data") .. "/lsp-servers/powerquery/server.js",
    "--stdio",
  },
  filetypes = { "powerquery" },
  root_markers = { ".git" },
}
