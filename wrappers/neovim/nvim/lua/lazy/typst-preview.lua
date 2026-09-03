---@module "lz.n"
---@type lz.n.PluginSpec
return {
  "typst-preview.nvim",
  ft = "typst",

  keys = {
    {
      "<leader>p",
      vim.cmd.TypstPreview,
      ft = "typst",
    },
  },
  after = function()
    require("typst-preview").setup({
      open_cmd = "firefox-beta %s",
      dependencies_bin = {
        tinymist = "tinymist",
        websocat = "websocat",
      },
    })
  end,
}
