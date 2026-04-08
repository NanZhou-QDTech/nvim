-- ~/.config/nvim/lsp/ty.lua
-- Native Neovim LSP config for Ty (type checker)
-- https://docs.astral.sh/ty/editors/

return {
  cmd = { "ty", "server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "ty.toml", ".git" },
  settings = {
    ty = {
      -- Diagnostic mode: "openFilesOnly" | "workspace"
      diagnosticMode = "workspace",

      -- Disable language services if you only want type checking
      -- and use another LSP (e.g., ruff) for completions/hover
      -- disableLanguageServices = false,

      -- Hide syntax errors (let ruff handle those)
      showSyntaxErrors = false,

      -- Inlay hints
      inlayHints = {
        variableTypes = true,
        callArgumentNames = true,
      },

      -- Custom rules
      configuration = {
        rules = {
          ["unresolved-reference"] = "error",
          ["possibly-unbound"] = "warn",
        },
      },
    },
  },
}
