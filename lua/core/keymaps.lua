vim.g.mapleader = " "

-- Navigation keys
local keymap = vim.keymap.set
keymap("n", "<leader>e", ":NvimTreeToggle<CR>",
    {desc = "Open nvim tree"})
keymap("n", "<leader><tab>", "<C-^>", 
    {desc = "Jump from file tree to previous buffer"})

-- Formatting
keymap("n", "<leader>F", function()
    vim.lsp.buf.format()
end, { desc = "Format buffer" })

-- Telescope
keymap("n", "<leader>ff", function() 
    require("telescope.builtin").find_files() 
end, { desc = "Find files" })
keymap("n", "<leader>fg", function()
    require("telescope.builtin").live_grep()
end, { desc = "Live grep" })
