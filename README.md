# nvim
NeoVIM Configs

## Plugins

**Plugin Manage**: [vim.pack](https://neovim.io/doc/user/pack/#_plugin-manager)
- download

**LSP Client Manage**: [Mason Package List](https://mason-registry.dev/registry/list)
- download

**Abstract Syntax Tree Parsers/Queries Download**: [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- parser
- query
requirements
- tar
- curl
- tree-sitter-cli: `cargo install --locked tree-sitter-cli`
- c compiler
  - Windows: MingW/MSYS2
  - Linux: build-essential/cmake

**Grep**: `grepprg` runs [ripgrep](https://github.com/BurntSushi/ripgrep)
- Windows: `scoop install ripgrep`

**Utils Collections**: [mini.nvim](https://github.com/nvim-mini/mini.nvim)
- icons
- comment
- surround
- pairs
- snippets

## Language Server Protocol

### Lua
[lua_ls](https://github.com/LuaLS/lua-language-server)
- diagnostic
- static type check
- highlight
- completion
- hover
- refactor(rename)
- format
- code actions

### C
[clangd](https://clangd.llvm.org/)
- diagnostic
- static type check
- highlight
- completion
- hover
- refactor(rename)
- format
- code actions

### Python
[ty](https://docs.astral.sh/ty/)
- static type check

[ruff](https://docs.astral.sh/ruff/)
- format
- diagnostic
- highlight
- completion
- hover
- refactor
- code actions

# References
- [Advent of nvim - by TJdevries ](https://github.com/tjdevries/advent-of-nvim)
- [Minimals Neovim config - by SylvanFranklin](https://github.com/SylvanFranklin/.config/tree/main/nvim)
- [Neovim config with less than 10 plugins - by radleylewis](https://github.com/radleylewis/nvim-lite)
- [MINI MAX configs](https://github.com/nvim-mini/MiniMax)
- [Official Doc of tree-sitter](https://tree-sitter.github.io/tree-sitter/index.html)
- [mini.nvim wiki](https://nvim-mini.org/mini.nvim/#module)
