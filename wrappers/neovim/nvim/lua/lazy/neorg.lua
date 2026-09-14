--@type lz.n.PluginSpec
return {
  "neorg",
  ft = "norg",

  after = function()
    require("neorg").setup({
      load = {
        ["core.defaults"] = {},
        ["core.concealer"] = {},
        ["core.dirman"] = {
          config = {
            workspaces = {
              notes = "~/documents/notes",
            },
          },
        },
      },
    })
  end,
}
