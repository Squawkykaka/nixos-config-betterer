local canola = require("canola")

vim.b.search_char = nil

vim.g.canola = {
  confirm = false,
  cursor = true,
  save = "auto",
  float = {
    padding = 3,
  },
  delete = {
    wipe = true, -- Autodelete open buffers when file deleted
  },
  keymaps = {
    ["<Esc>"] = {
      callback = "actions.close",
      mode = "n",
    },
    ["<Tab>"] = "actions.preview",
  },
}

vim.api.nvim_create_autocmd("User", {
  pattern = "CanolaWinTitle",
  callback = function(args)
    args.data.title = "test"
  end,
})

vim.keymap.set("n", "<leader>e", function()
  -- canola's menu thing is borked rn
  vim.o.winborder = ""
  canola.open_float()
  vim.o.winborder = "rounded"
end)
vim.keymap.set("n", "<leader>E", function()
  canola.open_float(".")
end)
