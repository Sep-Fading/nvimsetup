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
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action,
    { buffer = buf, desc = 'Code actions' })
    end,})

-- Debugging (nvim-dap)
keymap("n", "<F5>", function()
    require("dap").continue()
end, { desc = "Start / Continue Debugging" })

keymap("n", "<F10>", function()
    require("dap").step_over()
end, { desc = "Step Over" })

keymap("n", "<F11>", function()
    require("dap").step_into()
end, { desc = "Step Into" })

keymap("n", "<F12>", function()
    require("dap").step_out()
end, { desc = "Step Out" })

keymap("n", "<F9>", function()
    require("dap").toggle_breakpoint()
end, { desc = "Toggle Breakpoint" })

keymap("n", "<leader>db", function()
    require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Set Conditional Breakpoint" })

keymap("n", "<leader>du", function()
    require("dapui").toggle()
end, { desc = "Toggle DAP UI" })

keymap("n", "<leader>dr", function()
    require("dap").repl.open()
end, { desc = "Open DAP REPL" })

keymap("n", "<leader>dl", function()
    require("dap").run_last()
end, { desc = "Run Last Debug Session" })

-- Diagnostic navigation (optional but useful alongside DAP/LSP)
keymap("n", "[d", function()
    vim.diagnostic.goto_prev()
end, { desc = "Go to previous diagnostic" })

keymap("n", "]d", function()
    vim.diagnostic.goto_next()
end, { desc = "Go to next diagnostic" })

keymap("n", "gl", function()
    vim.diagnostic.open_float()
end, { desc = "Show diagnostic message" })

