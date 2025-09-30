vim.lsp.set_log_level("warn")

-- Loaders
require("core.options")
require("core.keymaps")
require("core.lazy")


-- LSP Config as of vim.lsp.config introduction
-- Configure Rust Analyzer LSP using Neovim 0.11+ native API

-- Custom root_dir function for LSP
local function find_root_dir_rust(start_dir)
  local util = require('lspconfig.util') -- Use lspconfig's util for root detection
  return util.root_pattern('Cargo.toml', '.git')(start_dir) or util.path.dirname(start_dir)
end

vim.lsp.config('rust_analyzer', {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_dir = find_root_dir_rust,
  settings = {
    ['rust-analyzer'] = {
      cargo = {
        allFeatures = true, -- Enable all Cargo features
      },
      checkOnSave = {
        command = 'clippy', -- Run clippy on save for linting
      },
      diagnostics = {
        enable = true,
        experimental = {
          enable = false, -- Enable experimental diagnostics
        },
      },
    },
  },
})

-- Enable the Rust Analyzer server (auto-starts for Rust files)
vim.lsp.enable('rust_analyzer')


-- Nvim Tree 
require("nvim-tree").setup()

-- Theme stuff
vim.o.background = "dark"
vim.cmd.colorscheme("github_dark_high_contrast")
