-- init.lua
-- Entry point ONLY — bootstraps nvim-core framework

-- Leader keys must be set before any keymaps
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap nvim-core
require("core.init").bootstrap()

-- vim: set ft=lua ts=2 sw=2 et: