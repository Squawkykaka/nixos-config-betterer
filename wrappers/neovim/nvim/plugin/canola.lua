local canola = require("canola")
local fzf_lua = require("fzf-lua")

vim.b.search_char = nil

vim.g.canola = {
  confirm = false,
  cursor = true,
  save = "auto",
  float = {
    padding = 3,
    title = false, -- Don't show the title in a floating window
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
  }
}

vim.api.nvim_create_autocmd("User", {
  pattern = "CanolaWinTitle",
  callback = function(args)
    args.data.title = ""
  end,
})


vim.keymap.set("n", "<leader>e", canola.open_float)
vim.keymap.set("n", "<leader>E", function()
canola.open_float(".")
end)
