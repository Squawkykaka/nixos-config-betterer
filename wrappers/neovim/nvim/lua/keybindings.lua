vim.keymap.set("n", "U", "<C-r>", { desc = "Redo" })

vim.keymap.set({ "n", "x" }, "<Space>", "<Nop>")

-- nicer control u and d
vim.keymap.set("n", "<C-u>", "Hzz")
vim.keymap.set("n", "<C-d>", "Lzz")

local ERROR = vim.diagnostic.severity.ERROR
vim.keymap.set("n", "[e", function()
  vim.diagnostic.jump({ count = -1, severity = ERROR })
end, { desc = "Previous error" })
vim.keymap.set("n", "]e", function()
  vim.diagnostic.jump({ count = 1, severity = ERROR })
end, { desc = "Next error" })
