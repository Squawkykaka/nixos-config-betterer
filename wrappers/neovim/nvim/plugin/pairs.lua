local npairs = require("nvim-autopairs")
local Rule = require("nvim-autopairs.rule")
local conds = require("nvim-autopairs.conds")

npairs.setup()

Autopairs_utils = {}

Autopairs_utils.surrounding_spaces = function(a1, ins, a2, lang)
  return Rule(ins, ins, lang)
    :with_pair(function(opts)
      return a1 .. a2 == opts.line:sub(opts.col - #a1, opts.col + #a2 - 1)
    end)
    :with_move(conds.none())
    :with_cr(conds.none())
    :with_del(function(opts)
      local col = vim.api.nvim_win_get_cursor(0)[2]
      return a1 .. ins .. ins .. a2 == opts.line:sub(col - #a1 - #ins + 1, col + #ins + #a2) -- insert only works for #ins == 1 anyway
    end)
end

npairs.add_rules({
  Rule("```", "```"):with_pair(conds.not_before_char("`", 3)),
})
