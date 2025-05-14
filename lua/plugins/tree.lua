require("nvim-tree").setup({
    filters = {
      custom = {
        "%.meta",
        "%.csproj",
        "%.dll",
        "%.json"
      },
      dotfiles = false,
    },
    renderer = {
      group_empty = false,
    },
})
