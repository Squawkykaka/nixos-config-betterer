--@type vim.lsp.Config
return {
  settings = {
    Lua = {
      semantic = { enable = true },
      hint = {
        enable = true,
        paramName = "Literal",
        arrayIndex = "Disable",
      },
      runtime = {
        version = "LuaJIT",
      },
      workspace = {
        preloadFileSize = 10000,
        library = {
          vim.env.VIMRUNTIME,
        }
      }
    }
  }
}
