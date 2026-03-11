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

-- Register Luau (Roblox)
vim.lsp.config('luau_lsp', {
  cmd = { 'luau-lsp', 'lsp' },
  filetypes = { 'lua', 'luau' },
  root_dir = function(bufnr)
    return vim.fs.dirname(vim.fs.find({ 'default.project.json', '.git' }, {
      upward = true,
      path = vim.api.nvim_buf_get_name(bufnr)
    })[1])
  end,
})

-- Configure standard Lua (lua_ls) to stay out of Roblox projects
vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_dir = function(bufnr)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    -- If there's a Rojo project file, return nil so lua_ls doesn't start
    if #vim.fs.find({ 'default.project.json' }, { upward = true, path = fname }) > 0 then
      return nil
    end
    return vim.fs.dirname(vim.fs.find({ '.git' }, { upward = true, path = fname })[1])
  end,
  settings = {
    Lua = { workspace = { checkThirdParty = false } }
  }
})

-- Start the appropriate LSP
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lua', 'luau' },
  callback = function(args)
    local config = vim.lsp.config.luau_lsp
    -- Check if it's a Roblox project first
    local root_dir = config.root_dir(args.buf)
    
    if root_dir then
      vim.lsp.start({
        name = 'luau_lsp',
        cmd = config.cmd,
        root_dir = root_dir,
      }, { bufnr = args.buf })
    else
      -- Fallback to standard lua_ls
      local lua_config = vim.lsp.config.lua_ls
      local lua_root = lua_config.root_dir(args.buf)
      if lua_root then
        vim.lsp.start({
          name = 'lua_ls',
          cmd = lua_config.cmd,
          root_dir = lua_root,
          settings = lua_config.settings,
        }, { bufnr = args.buf })
      end
    end
  end,
})

vim.lsp.config("*", {
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
  },
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
