require("init")
require("lz.n").load("lazy")

vim.lsp.enable({
  "lua_ls",
  "nil_ls",
  "basedpyright",
  "ts_ls",
  "marksman",
  "tinymist",
  -- "clangd",
})
