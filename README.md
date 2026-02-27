# nvim
NeoVIM Configs

## Plugins

**Plugin Manage**: [Lazy.Nvim Official Doc](https://lazy.folke.io/)
- download
- config

**LSP Client Manage**: [Mason Package List](https://mason-registry.dev/registry/list)
- download

**Abstract Syntax Tree**: [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- parser
- query
requirements
- tar
- curl
- tree-sitter-cli: `cargo install --locded tree-sitter-cli`
- c compiler
  - Windows: MingW/MSYS2
  - Linux: build-essential/cmake

**Fuzzy Finder**: [fzf-lua](https://github.com/ibhagwan/fzf-lua)
- pickers
requirements
- fzf
  - Windows: `scoop install fzf`
optionals
- fd
- ripgrep(rg)

## Language Server Protocal

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
- diagnostic
- static type check
- highlight
- completion
- hover
- refactor
- code actions

[ruff](https://docs.astral.sh/ruff/)
- format

# References
- [Advent of nvim - by TJdevries ](https://github.com/tjdevries/advent-of-nvim)
- [Minimals Neovim config - by SylvanFranklin](https://github.com/SylvanFranklin/.config/tree/main/nvim)
- [Neovim config with less than 10 plugins - by radleylewis](https://github.com/radleylewis/nvim-lite)
- [Official Doc of tree-sitter](https://tree-sitter.github.io/tree-sitter/index.html)
