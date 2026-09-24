-- lua/user/options.lua
-- User vim.opt overrides

local M = {}

function M.apply()
  local opt = vim.opt

  -- UI
  opt.scrolloff = 8
  opt.sidescrolloff = 8
  opt.showtabline = 2
  opt.number = true
  opt.relativenumber = true
  opt.cursorline = true
  opt.colorcolumn = "80"
  require("vim._core.ui2").enable({})
  opt.conceallevel = 1
  opt.concealcursor = ""
  opt.tabline = "%t"
  opt.background = "dark"
  opt.termguicolors = true
  opt.winborder = "rounded"
  opt.fillchars = { eob = " " }

  -- Split behavior
  opt.splitright = true
  opt.splitbelow = true

  -- Character view
  opt.wrap = false
  opt.whichwrap = "<,>,[,]"
  opt.linebreak = true
  opt.list = true
  opt.showmatch = true
  opt.backspace = "indent,eol,start"
  opt.selection = "inclusive"

  -- Search
  opt.hlsearch = true
  opt.ignorecase = true
  opt.smartcase = true
  opt.incsearch = true
  opt.grepprg = "rg --vimgrep --no-messages --smart-case"

  -- Fold
  opt.foldlevel = 999
  opt.foldlevelstart = 999
  opt.foldmethod = "expr"
  opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

  -- Indent
  opt.tabstop = 4
  opt.softtabstop = 4
  opt.shiftround = true
  opt.shiftwidth = 4
  opt.expandtab = true
  opt.autoindent = true
  opt.smartindent = true

  -- Mouse
  opt.mouse = "a"
  vim.cmd([[
    aunmenu PopUp
    autocmd! nvim.popupmenu
  ]])

  -- Clipboard
  opt.clipboard:append("unnamedplus")

  -- Update time
  opt.updatetime = 300
  opt.timeoutlen = 500
  opt.redrawtime = 5000
  opt.maxmempattern = 20000
  opt.errorbells = false

  -- File
  opt.autoread = true
  opt.autowrite = false
  opt.undofile = true
  opt.autochdir = false

  -- Backup
  opt.backup = false
  opt.writebackup = false
  opt.swapfile = false

  -- Completion
  opt.completeopt = { "menu", "menuone", "noselect", "noinsert", "fuzzy", "popup" }
  opt.wildmenu = true
  opt.wildmode = "longest:full,full"
  opt.pumheight = 10
  opt.complete:prepend({ "o" })
  opt.wildoptions:append({ "fuzzy" })

  -- LSP
  opt.synmaxcol = 300

  -- Diff
  opt.diffopt:append("linematch:60")

  -- Diagnostic (also in core/diagnostic.lua)
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
  opt.confirm = true

  -- Path
  opt.path:append({ "**" })

  -- Shada defer
  opt.shadafile = "NONE"
end

return M