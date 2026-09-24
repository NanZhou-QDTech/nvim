-- lua/servers/clangd.lua
return {
  filetypes = { "c", "cpp", "objc", "objcpp" },
  root_markers = { "compile_commands.json", ".clangd", ".git" },
  cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu" },
}