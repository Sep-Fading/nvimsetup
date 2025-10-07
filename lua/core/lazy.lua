-- core/lazy.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- UI
    { "nvim-lualine/lualine.nvim" },
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },

    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            require("which-key").setup()
        end,
    },


    -- Themes
    {
        'projekt0n/github-nvim-theme',
        name = 'github-theme',
        config = function()
            require("plugins.github-theme")
        end,
    },

    {
        "ellisonleao/gruvbox.nvim",
        name = 'gruvbox',
        priority = 1000,
        config = true,
        opts = function()
            require("plugins.gruvbox")
        end,
    },

    -- Dev tools
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },

    },

    {
        "nvim-treesitter/nvim-treesitter",
        config = function()
            require("plugins.tree")
        end,
        build = ":TSUpdate"
    },

    -- LSP, completion & snippets
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        config = function()
            require("mason").setup()
        end
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed =
                {
                    "lua_ls",
                    "pyright",
                },
            })
        end
    },
    {
        "neovim/nvim-lspconfig",
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip"
        },
        config = function()
            require("plugins.cmp")
        end
    },
    -- completion sources
    {
        "hrsh7th/cmp-nvim-lua",
    },
    {
        "hrsh7th/cmp-nvim-lsp-signature-help"
    },
    {
        "hrsh7th/cmp-vsnip"
    },
    {
        "hrsh7th/vim-vsnip"
    },
    {
        "nvimtools/none-ls.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "nvimtools/none-ls-extras.nvim" },
        config = function()
            require("plugins.null-ls")
        end,
    },

    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup()
        end,
    },

    {
        "Hoffs/omnisharp-extended-lsp.nvim",
        event = "VeryLazy", -- optional lazy-load
    },

    {
        'simrat39/rust-tools.nvim'
    },

    -- Debug core + UI + helpers
    { "mfussenegger/nvim-dap",
        config = function()
            require("plugins.dap")
        end,
    },
    { "rcarriga/nvim-dap-ui",           dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } },
    { "theHamsta/nvim-dap-virtual-text" },
    -- Install debug adapters (codelldb) via Mason
    { "jay-babu/mason-nvim-dap.nvim",   dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" } },
})
