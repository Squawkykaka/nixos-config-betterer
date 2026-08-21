vim.loader.enable()

local g = vim.g
local o = vim.o

require("vim._core.ui2").enable({})

o.winborder = "rounded"

o.number = true
o.relativenumber = true

o.backup = false
o.writebackup = false
o.undofile = true

g.mapleader = " "
o.mouse = ""
o.timeout = false
o.hidden = false

vim.opt.matchpairs:append("<:>") -- % goes between <>

o.expandtab = true -- spaces as tab
o.tabstop = 2 -- 2 spaces for tabs
o.shiftwidth = 0 -- Reuse value of tabstop
o.shiftround = true -- Round to the nearest indentation level when using `<` and `>`
o.breakindent = true -- Continue indented wrapped line at same level
o.autoindent = true -- keep smartindent and cindent off, and rely on filetype indentation

o.wrap = false
o.textwidth = 80

o.ignorecase = true
o.smartcase = true
o.hlsearch = true -- Highlight search matches

o.showmode = false
o.showcmd = true
