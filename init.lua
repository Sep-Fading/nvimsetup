vim.lsp.set_log_level("warn")

-- Loaders
require("core.options")
require("core.keymaps")
require("core.lazy")

-- Theme stuff
vim.o.background = "dark"
vim.cmd.colorscheme("gruvbox")

