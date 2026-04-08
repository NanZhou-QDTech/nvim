-- ~/.config/nvim/lsp/ruff.lua
-- Native Neovim LSP config for Ruff (linter + formatter)
-- https://docs.astral.sh/ruff/editors/setup/

return {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
  init_options = {
    settings = {
      -- Enable fix-all on save
      fixAll = true,

	  configurationPreference = 'editorFirst',

	  exclude = {
		  '/tests/',
		},

	  lineLength = 100,
	
      -- Enable import organization
      organizeImports = true,

	  configuration = {
			lint = {
				enable = true,
			},
			format = {
				['quote-style'] = 'single',
		    },
		},

      -- Code actions
      codeAction = {
        disableRuleComment = {
          enable = true,
        },
        fixViolation = {
          enable = true,
        },
      },

      -- Log level: "off" | "error" | "warn" | "info" | "debug" | "trace"
      logLevel = "warn",
    },
  },
}
