require("luasnip").setup({
  enable_autosnippets = true,
})

require("luasnip.loaders.from_lua").lazy_load({
  lazy_paths = { "/home/gleask/nixos/wrappers/neovim/nvim/snippets" },
})
