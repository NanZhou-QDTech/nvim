-- Auto Format on Save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.py",
  callback = function()
    vim.lsp.buf.format({
      async = false,
      filter = function(c) return c.name == "ruff" end,
    })
  end,
})
