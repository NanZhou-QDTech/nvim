-- Global Options

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.encoding = "UTF-8"
vim.g.python3_host_prog = "C:/Users/youar/projects/neovimpy/.venv/Scripts/python.exe"

-- Editor UI
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.showtabline = 2
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.colorcolumn = "80"
vim.opt.textwidth = 80
require("vim._core.ui2").enable({})
vim.opt.conceallevel = 1
vim.opt.concealcursor = ""
vim.opt.tabline = "%t"
vim.opt.statusline = "[%n] %<%f argidx:%{argidx()+1}/%{argc()} %h%w%m%r%=%-14.(%l,%c%V%) %P"
vim.opt.background = "dark"
vim.opt.termguicolors = true
vim.opt.winborder = "rounded"

-- Editor Split Behavior
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Editor Character View
vim.opt.wrap = false
vim.opt.whichwrap = "<,>,[,]"
vim.opt.linebreak = true
vim.opt.list = true
vim.opt.showmatch = true
vim.opt.backspace = "indent,eol,start"
vim.opt.selection = "inclusive"
vim.opt.fillchars = {
  eob = " ",
}

-- Editor Search
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.grepprg = "rg --vimgrep --no-messages --smart-case"

-- Editor fold
vim.opt.foldlevel = 999
vim.opt.foldlevelstart = 999
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- Editor indent
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftround = true
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

-- Editor Mouse
vim.opt.mouse = "a"
-- disable mouse popup but keep mouse enabled
vim.cmd(
  [[
        aunmenu PopUp
        autocmd! nvim.popupmenu
    ]]
)

-- Editor Clipboard
vim.opt.clipboard:append("unnamedplus")

-- Editor Update Time
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000
vim.opt.lazyredraw = true
vim.opt.errorbells = false

-- File
vim.opt.autoread = true
vim.opt.autowrite = false
vim.opt.undofile = true
vim.opt.autochdir = false

-- Backup
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- Editor Completion
vim.opt.completeopt = {
  "menu",
  "menuone",
  "noselect",
  "noinsert",
  "fuzzy",
  "popup",
}
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.pumheight = 10
vim.opt.wildoptions:append({ "fuzzy" })

-- Editor LSP
vim.opt.syntax = "off"
vim.opt.synmaxcol = 300

-- Buffers
vim.opt.hidden = true
vim.opt.modifiable = true

-- Diff Display
vim.opt.diffopt:append("linematch:60")

-- Diagnostic
vim.diagnostic.config({
  underline = false,
  virtual_text = { prefix = "●", spacing = 4 },
  update_in_insert = false,
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = " ",
    },
  },
  float = {
    border = "rounded",
    source = true,
    header = "",
    prefix = "",
    focusable = false,
    style = "minimal",
  },
})

-- Utils
vim.opt.confirm = true

-- Path
vim.opt.path:append({ "**" })

-- Startup Speed Optimize
vim.opt.shadafile = "NONE"
vim.api.nvim_create_autocmd("CmdlineEnter", {
  once = true,
  callback = function()
    local shada = vim.fn.stdpath("state") .. "/shada/main.shada"
    vim.opt.shadafile = shada
    vim.api.nvim_command("rshada! " .. shada)
  end,
})


-- Keymaps
local set = vim.keymap.set


-- Terminal QOL keymaps
set("t", "<Esc>", "<C-\\><C-n>", { desc = "Return to Normal Mode in Terminal" })
set("t", "<A-h>", "<C-\\><C-n><C-w>h", { desc = "Go to Left Window in Terminal" })
set("t", "<A-l>", "<C-\\><C-n><C-w>l", { desc = "Go to Right Window in Terminal" })
set("t", "<A-j>", "<C-\\><C-n><C-w>j", { desc = "Go to Up Window in Terminal" })
set("t", "<A-k>", "<C-\\><C-n><C-w>k", { desc = "Go to Below Window in Terminal" })


-- Builtin Harpoon-like
set("n", "<leader>aa", function()
    vim.cmd("$argadd %")
    vim.cmd("argdedup") -- fix duplicate
  end,
  { desc = "Arglist Add Current File" })


set("n", "<leader>ad", function()
    vim.cmd("$argdelete %")
  end,
  { desc = "Arglist Delete Current File" })


set("n", "<leader>al", function()
    vim.cmd("args")
  end,
  { desc = "Arglist Show" })


set("n", "<leader>a1", function()
    vim.cmd("silent! 1argument")
  end,
  { desc = "Arglist Go To Number 1 pos" })


set("n", "<leader>a2", function()
    vim.cmd("silent! 2argument")
  end,
  { desc = "Arglist Go To Number 2 pos" })


set("n", "<leader>a3", function()
    vim.cmd("silent! 3argument")
  end,
  { desc = "Arglist Go To Number 3 pos" })


set("n", "<leader>a4", function()
    vim.cmd("silent! 4argument")
  end,
  { desc = "Arglist Go To Number 4 pos" })


set("n", "<leader>a5", function()
    vim.cmd("silent! 5argument")
  end,
  { desc = "Arglist Go To Number 5 pos" })

set("n", "<Esc>", "<CMD>nohl<CR>", { noremap = true, desc = "cancel highlight" })
set("n", "G", "Gzz", { noremap = true, desc = "Go Bottom and Centered" })
set("n", "n", "nzz", { noremap = true, desc = "Search Next and Centered" })
set("n", "N", "Nzz", { noremap = true, desc = "Search Prev and Centered" })
set("v", "<", "<gv", { noremap = true, desc = "Outdent and Keep Visual Selection" })
set("v", ">", ">gv", { noremap = true, desc = "Indent and Keep Visual Selection" })

-- Plugins
-- Builtin Plugins
vim.cmd.packadd("cfilter")
vim.cmd.packadd("nvim.undotree")
vim.cmd.packadd("nvim.difftool")


-- Third Party Plugins
vim.pack.add({
  -- Plenary for useful collection of lua functions
  "https://github.com/nvim-lua/plenary.nvim",
  -- Treesitter Parsers and Queries download and manage
  {
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    version = "main",
  },

  -- Enhance textobject with treesitter
  {
    src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
    version = "main",
  },
  -- LSP config starter packs
  "https://github.com/neovim/nvim-lspconfig",
  -- LSP download and manage
  "https://github.com/mason-org/mason.nvim",
  -- File Browser
  "https://github.com/stevearc/oil.nvim",
  -- QOL plugin collection
  "https://github.com/nvim-mini/mini.nvim",
  -- Markdown file support
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",
  -- Obsidian Integration
  "https://github.com/epwalsh/obsidian.nvim",
  -- LSP Enhance
  "https://github.com/saghen/blink.cmp",       -- AutoCompletion
  "https://github.com/stevearc/conform.nvim",  -- Format
  "https://github.com/mfussenegger/nvim-lint", -- Linting
})


vim.api.nvim_create_augroup("PluginInit", { clear = true })
vim.api.nvim_create_augroup("PluginConfig", { clear = true })
vim.api.nvim_create_augroup("UserLSPConfig", { clear = true })

vim.api.nvim_create_autocmd("PackChanged", {
  group = "PluginInit",
  desc = "Init for some plugins",
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "nvim-treesitterr-textobjects" and kind == "install" then
      vim.g.no_plugin_maps = true
    end
    if name == "nvim-treesitterr" and (kind == "install" or kind == "update") then
      -- Treesitter Initial start
      local treesitter = require("nvim-treesitter")
      local treesitter_config = require("nvim-treesitter.config")
      local treesitter_ensure_installed = {
        "vim",
        "vimdoc",
        "rust",
        "c",
        "cpp",
        "html",
        "css",
        "javascript",
        "json",
        "lua",
        "markdown",
        "python",
        "typescript",
        "vue",
        "bash",
      }
      local treesitter_already_installed = treesitter_config.get_installed()
      local treesitter_parsers_to_install = {}
      for _, parser in ipairs(treesitter_ensure_installed) do
        if not vim.tbl_contains(treesitter_already_installed, parser) then
          table.insert(treesitter_parsers_to_install, parser)
        end
      end
      if #treesitter_parsers_to_install > 0 then
        treesitter.install(treesitter_parsers_to_install)
      end
      -- Treesitter Initial end
      vim.cmd("TSUpdate")
    end
    if name == "blink.cmp" and (kind == "install" or kind == "update") then
      vim.system({ "cargo", "build", "--release" }, { cwd = ev.data.path })
    end
  end,
})

require("nvim-treesitter").setup({
  highlight = { enable = true },
  fold = {
    enable = true,
    foldopen = "foldopen",
  },
})
require("mini.icons").setup({})
require("mini.comment").setup({})
require("mini.surround").setup({})
require("mini.pairs").setup({})
require("mini.snippets").setup({})

require("oil").setup({
  default_file_explorer = false,
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
  columns = {
    "permissions",
    "icon",
    "size",
    "mtime",
  },
  view_options = {
    show_hidden = true,
  },
  win_options = {
    signcolumn = "yes",
  },
  use_default_keymaps = true,
  keymaps = {
    ["g?"] = { "actions.show_help", mode = "n" },
    ["<CR>"] = "actions.select",
    ["<C-s>"] = { "actions.select", opts = { vertical = true } },
    ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
    ["<C-t>"] = { "actions.select", opts = { tab = true } },
    ["<C-p>"] = "actions.preview",
    ["<C-c>"] = { "actions.close", mode = "n" },
    ["<C-l>"] = "actions.refresh",
    ["-"] = { "actions.parent", mode = "n" },
    ["_"] = { "actions.open_cwd", mode = "n" },
    ["`"] = { "actions.cd", mode = "n" },
    ["g~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
    ["gs"] = { "actions.change_sort", mode = "n" },
    ["gx"] = "actions.open_external",
    ["g."] = { "actions.toggle_hidden", mode = "n" },
    ["g\\"] = { "actions.toggle_trash", mode = "n" },
  },
})
set("n", "-", "<CMD>Oil<CR>", { desc = "Open Parent Directory" })


-- Treesitter
vim.api.nvim_create_autocmd("FileType", {
  callback = function() pcall(vim.treesitter.start) end,
})


-- Auto Completions
require("blink.cmp").setup({
  keymap = { preset = "default" },
  -- appearance = { nerd_font_variant = "mono" },
  sources = {
    default = {
      "lsp",
      "snippets",
      "path",
      "buffer",
    },
  },
  completion = {
    menu = {
      border = "rounded",
    },
    documentation = { auto_show = true },
    ghost_text = { enabled = true },
  },
  snippets = {
    preset = "mini_snippets",
  },
  fuzzy = { implementation = "prefer_rust" },
})

-- LSP
vim.api.nvim_create_autocmd("LspAttach", {
  group = "UserLSPConfig",
  callback = function(event)
    vim.opt.signcolumn = "yes:2"
    local client       = assert(vim.lsp.get_client_by_id(event.data.client_id))
    local bufnr        = event.buf
    -- Disable Ruff"s hover in favor of ty"s richer hover
    if client and client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end
    if client and client.name == "marksman" then
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    -- Navigation
    map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
    map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
    map("n", "gri", vim.lsp.buf.implementation, "Go to Implementation")
    map("n", "grr", vim.lsp.buf.references, "References")
    map("n", "K", vim.lsp.buf.hover, "Hover Documentation")

    -- Code actions & Rename
    map("n", "gra", vim.lsp.buf.code_action, "Code Action")
    map("n", "grn", vim.lsp.buf.rename, "Rename Symbol")

    -- Diagnostics
    local diagnostics = vim.diagnostic.get(bufnr)
    local has_diagnostics = #diagnostics > 0
    if has_diagnostics then
      -- map("n", "<leader>e", vim.diagnostic.open_float, "Show Diagnostics")
      map("n", "[d", vim.diagnostic.jump({ count = 1, float = true }), "Previous Diagnostic")
      map("n", "]d", vim.diagnostic.jump({ count = -1, float = true }), "Next Diagnostic")
      map("n", "<leader>q", vim.diagnostic.setloclist, "Diagnostics List")
    end

    -- Format with Ruff on demand
    map("n", "grf", function()
      vim.lsp.buf.format({
        async = true,
        -- Only let ruff handle formatting
        filter = function(c) return c.name == "ruff" end,
      })
    end, "Format with Ruff")
    if client:supports_method("textDocument/completion") then
      vim.o.complete = "o,.,w,b,u,t"
      vim.lsp.completion.enable(true, client.id, bufnr)
    end
  end,
})


vim.api.nvim_create_user_command("Mason", function()
  require("mason").setup({
    -- Log level
    log_level = vim.log.levels.DEBUG, -- Useful for troubleshooting


    -- UI customizations
    ui = {
      border = "rounded", -- Use rounded borders for the Mason window
      icons = {
        package_installed = "✅",
        package_pending = "⏳",
        package_uninstalled = "❌"
      }
    },
  })
  vim.cmd("Mason")
end, { desc = "Init Mason" })

local capabilities = vim.lsp.protocol.make_client_capabilities()
pcall(function()
  capabilities = require("blink.cmp").get_lsp_capabilities()
end)

vim.lsp.config("*",
  {
    capabilities = capabilities,
  })

-- Solve markdown.mdx filetype issues
vim.filetype.add({
  extension = {
    mdx = "markdown"
  },
})

vim.lsp.enable({
  -- Lua
  "lua_ls",
  -- Python
  "ty",
  "ruff",
  -- Markdown
  "marksman",
  "rumdl",
})

-- LSP Enhance
-- Linting
require("lint").linters_by_ft = {
  lua = { "luac" },
  python = { "ruff" },
  markdown = { "rumdl" },
}
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    -- try_lint without arguments runs the linters defined in `linters_by_ft`
    -- for the current filetype
    require("lint").try_lint()

    -- You can call `try_lint` with a linter name or a list of names to always
    -- run specific linters, independent of the `linters_by_ft` configuration
    require("lint").try_lint("cspell")
  end,
})
-- Format
require("conform").setup({
  formatters_by_ft = {
    -- lua = { "stylua" },
    python = { "ruff" },
    markdown = { "rumdl" },

    -- Use LSP Format if no cli
    ["_"] = { "lsp_format" }
  },
  formatters = {},
  format_on_save = function(bufnr)
    if vim.api.nvim_buf_line_count(bufnr) > 10000 then
      return
    end
    return {
      timeout_ms = 500,
      lsp_format = "fallback",
    }
  end,
  notify_on_error = true,
  format_after_save = function(bufnr)
    if vim.g.disable_autoformat then
      return
    end
    return {
      async = true,
      lsp_format = "fallback",
      bufnr = bufnr,
    }
  end
})
vim.api.nvim_create_user_command("Format", function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ["end"] = { args.line2, end_line:len() },
    }
  end
  require("conform").format({ async = true, lsp_format = "fallback", range = range })
end, { range = true })
vim.keymap.set({ "n", "v" }, "<leader>fm", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })
-- Toggle format on save
vim.api.nvim_create_user_command("FormatDisable", function()
  vim.g.disable_autoformat = true
end, { desc = "Disable format on save" })

vim.api.nvim_create_user_command("FormatEnable", function()
  vim.g.disable_autoformat = false
end, { desc = "Enable format on save" })


-- Obsidian Integration
vim.api.nvim_create_autocmd("FileType", {
  group = "PluginConfig",
  pattern = { "markdown" },
  callback = function()
    require("plenary")
    require("render-markdown").setup({})
    require("obsidian").setup({
      workspaces = {
        { name = "work", path = "~/work/worknote" },
      },
    })
  end,
})


-- Utils
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.hl.on_yank() end,
})

vim.api.nvim_create_user_command("RestartWithSession", function()
  vim.cmd("mksession! Session.vim | restart source Session.vim")
end, { nargs = 0 })
