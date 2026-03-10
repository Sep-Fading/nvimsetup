vim.lsp.set_log_level("warn")
-- Loaders
require("core.options")
require("core.keymaps")
require("core.lazy")

-- Register the configuration
vim.lsp.config('rust_analyzer', {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_dir = function(bufnr)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local root = vim.fs.dirname(vim.fs.find({ 'Cargo.toml', '.git' }, {
      upward = true,
      path = fname
    })[1])
    return root or vim.fn.fnamemodify(fname, ':p:h')
  end,
  settings = {
    ['rust-analyzer'] = {
      cargo = { allFeatures = true },
      checkOnSave = { command = 'clippy' },
    },
  },
})

-- Start the LSP when opening Rust files
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'rust',
  callback = function(args)
    -- Get the registered config and start it
    local config = vim.lsp.config.rust_analyzer
    local root_dir = config.root_dir(args.buf)

    if root_dir then
      vim.lsp.start({
        name = 'rust_analyzer',
        cmd = config.cmd,
        root_dir = root_dir,
        settings = config.settings,
        capabilities = config.capabilities,
      }, {
        bufnr = args.buf,
      })
    end
  end,
})

-- Nvim Tree 
require("nvim-tree").setup()

-- Theme stuff
vim.o.background = "dark"

-- Force Transparent Background
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

-- Sync clipboard between OS and Neovim.
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)
