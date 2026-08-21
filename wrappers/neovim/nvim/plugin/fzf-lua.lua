vim.env.FZF_DEFAULT_OPTS = nil

require("fzf-lua").setup({
  keymap = {
    fzf = {
      true, -- Inherit from default fzf keybinds
      jump = "accept",

      -- Normal (ish) mode keybinds.
      ["ctrl-j"] = "down",
      ["ctrl-k"] = "up",
      ["ctrl-l"] = "accept",
      ["ctrl-f"] = "jump",
    },
    builtin = {
      true,
      ["<A-j>"] = "preview-down",
      ["<A-k>"] = "preview-up",
      ["<C-Space>"] = "toggle-preview",
    },
  },

  files = {
    fd_opts = "--color=never --hidden --type f --type l --exclude .git --exclude .direnv",
  },
  fzf_colors = true,
  winopts = {
    row = 0.50,
    preview = {
      layout = "vertical",
      vertical = "up:45%",
    },
  },

  fzf_opts = {
    ["--cycle"] = true,
  },
})

vim.keymap.set("n", "<leader>b", FzfLua.buffers, { desc = "Swap buffer" })
vim.keymap.set("n", "<leader>f", FzfLua.files, { desc = "Add new file in project" })
vim.keymap.set("n", "<leader>F", function()
  FzfLua.files({ cwd = vim.fn.expand("%:p:h") })
end, { desc = "Add new file in current folder" })

vim.keymap.set("n", "<leader>s", FzfLua.live_grep, { desc = "Search text in project" })
vim.keymap.set("n", "<leader>S", function()
  FzfLua.live_grep_native({ cwd = vim.fn.expand("%:p:h") })
end, { desc = "Search text in current folder" })
