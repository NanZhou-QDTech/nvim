-- lua/core/lsp.lua
-- LSP framework: servers, capabilities, attach

local LSP = {}
local Config = require("core.config")
local Diagnostic = require("core.diagnostic")

LSP.servers = {
  lua_ls = require("servers.lua_ls"),
  ruff = require("servers.ruff"),
  ty = require("servers.ty"),
  marksman = require("servers.marksman"),
  rumdl = require("servers.rumdl"),
  clangd = require("servers.clangd"),
  powerquery = require("servers.powerquery"),
}

---Build capabilities (blink.cmp + defaults)
---@return table
local function build_capabilities()
  local caps = vim.lsp.protocol.make_client_capabilities()
  local ok, blink = pcall(require, "blink.cmp")
  if ok then caps = blink.get_lsp_capabilities(caps) end
  return caps
end

---Setup LSP keymaps on attach
---@param client vim.lsp.Client
---@param bufnr integer
local function on_attach(client, bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  -- Ruff: disable hover in favor of ty
  if client.name == "ruff" then
    client.server_capabilities.hoverProvider = false
  end

  -- Marksman: disable formatting (use conform)
  if client.name == "marksman" then
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
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

  -- Diagnostics (via core.diagnostic)
  map("n", "[d", Diagnostic.prev, "Previous Diagnostic")
  map("n", "]d", Diagnostic.next, "Next Diagnostic")
  map("n", "<leader>q", vim.diagnostic.setloclist, "Diagnostics List")

  -- Format with Ruff on demand
  map("n", "grf", function()
    vim.lsp.buf.format({ async = true, filter = function(c) return c.name == "ruff" end })
  end, "Format with Ruff")
end

function LSP.setup()
  -- 1. Global capabilities
  local capabilities = build_capabilities()
  vim.lsp.config("*", { capabilities = capabilities })

  -- 2. Per-server configs
  for name, cfg in pairs(LSP.servers) do
    vim.lsp.config(name, cfg)
  end

  -- 3. Enable all servers
  local server_names = vim.tbl_keys(LSP.servers)
  vim.lsp.enable(server_names)

  -- 4. Single LspAttach autocmd
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("NvimCoreLspAttach", { clear = true }),
    callback = function(ev)
      local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
      on_attach(client, ev.buf)
    end,
    desc = "LSP keymaps + client tweaks",
  })

  -- 5. Signcolumn on attach
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("LspSigncolumn", { clear = true }),
    callback = function() vim.opt.signcolumn = "yes:2" end,
  })
end

function LSP.health()
  vim.health.start("nvim-core LSP")
  for name, cfg in pairs(LSP.servers) do
    local enabled = vim.lsp.is_enabled(name)
    if enabled then
      vim.health.ok(name .. " enabled")
    else
      vim.health.warn(name .. " not enabled")
    end
  end
  -- Check binary availability for external servers
  for name, cfg in pairs(LSP.servers) do
    if cfg.cmd and type(cfg.cmd) == "table" then
      local bin = cfg.cmd[1]
      if vim.fn.executable(bin) == 1 then
        vim.health.ok(bin .. " found in PATH")
      else
        vim.health.warn(bin .. " NOT in PATH (server: " .. name .. ")")
      end
    end
  end
end

return LSP