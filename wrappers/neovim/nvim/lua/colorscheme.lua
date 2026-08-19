colors = require("tokyonight.colors").setup()

require("tokyonight").setup({
  style = "night",

  on_highlights = function(hl, colors)
    hl["@variable"] = { fg = colors.red }
    hl.ColorColumn = { bg = colors.bg_highlight }
    hl.WinSeparator = { fg = "#868eb6" }
  end,
})

vim.cmd([[colorscheme tokyonight]])

-- Colorize hex codes
require("nvim-highlight-colors").setup({})
