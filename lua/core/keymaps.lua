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

-- LSP keybindings
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspKeymaps', { clear = true }),
  callback = function(args)
    local buf = args.buf
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = buf, desc = 'Go to definition' })
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = buf, desc = 'Hover (inspect)' })
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { buffer = buf, desc = 'Code actions' })
  end,
})
