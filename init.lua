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

--[[
-- 1. Helper to detect Roblox
local function is_roblox_project(bufnr)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  local result = vim.fs.find({ 'default.project.json', 'rojo.json' }, { 
    upward = true, 
    path = fname 
  })
  return #result > 0
end

-- 2. Define the LSP configs
local configs = {
  luau = {
    name = 'luau_lsp',
    cmd = { 'luau-lsp', 'lsp' },
    root_file = { 'default.project.json', '.git' }
  },
  lua = {
    name = 'lua_ls',
    cmd = { 'lua-language-server' },
    root_file = { '.git', '.stylua.toml' },
    settings = { Lua = { workspace = { checkThirdParty = false } } }
  }
}

-- 3. Unified Autocmd for Lua/Luau files
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lua', 'luau' },
  callback = function(args)
    local target

    if is_roblox_project(args.buf) then
      target = configs.luau
    else
      target = configs.lua
    end

    -- Find the root directory for the chosen LSP
    local root_file = vim.fs.dirname(vim.fs.find(target.root_file, {
      upward = true,
      path = vim.api.nvim_buf_get_name(args.buf)
    })[1])

    local root_dir = root_file and vim.fs.dirname(root_file) or vim.fn.getcwd()

    -- Start the LSP
    vim.lsp.start({
      name = target.name,
      cmd = target.cmd,
      root_dir = root_dir or vim.fn.getcwd(), -- fallback to current dir
      settings = target.settings,
    }, { bufnr = args.buf })
  end,
})
]]

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
