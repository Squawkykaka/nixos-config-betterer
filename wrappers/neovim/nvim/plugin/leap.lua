vim.keymap.set({ "n", "x", "o" }, "gw", "<Plug>(leap)")
vim.keymap.set({ "n", "x", "o" }, "gW", "<Plug>(leap-from-window)")

vim.keymap.set({ "x", "o" }, "an", function()
  require("leap.treesitter").select({
    opts = require("leap.user").with_traversal_keys("n", "N"),
  })
end)
