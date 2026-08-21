vim.keymap.set("n", "U", "<C-r>", { desc = "Redo" })

vim.keymap.set({ "n", "x" }, "<Space>", "<Nop>")

local ERROR = vim.diagnostic.severity.ERROR
vim.keymap.set("n", "[e", function()
  vim.diagnostic.jump({ count = -1, severity = ERROR })
end, { desc = "Previous error" })
vim.keymap.set("n", "]e", function()
  vim.diagnostic.jump({ count = 1, severity = ERROR })
end, { desc = "Next error" })



