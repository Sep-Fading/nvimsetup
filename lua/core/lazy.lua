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


    -- Themes and looks
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

    {
        "AlphaTechnolog/pywal.nvim",
        name = "pywal",
        config = function()
            require("pywal").setup()
            require("sep.pywal_smart")
            vim.cmd("colorscheme pywal")
        end,
    },

    {
        'goolord/alpha-nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function ()
            require("plugins.alphanvim")
        end
    },

    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require("plugins.lualine")
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

                handlers = 
                {
                    ["lua_ls"] = function() end,
                    ["luau_lsp"] = function() end,
                }
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
    {
        "mfussenegger/nvim-dap",
        config = function()
            require("plugins.dap")
        end,
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" }
    },
    { "theHamsta/nvim-dap-virtual-text" },
    -- Install debug adapters (codelldb) via Mason
    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" }
    },

    -- Leetcode
    {
    "kawre/leetcode.nvim",
    build = ":TSUpdate html", -- if you have `nvim-treesitter` installed
    dependencies = {
        -- include a picker of your choice, see picker section for more details
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
    },
    opts = {
        -- configuration goes here
        lang = "python3"
    },

    -- Roblox / Luau Support
    {
        "lopi-py/luau-lsp.nvim",
        opts = {
            platform = {
                type = "roblox",
            },
            types = {
                roblox_security_level = "PluginSecurity",
            },
            sourcemap = {
                enabled = true,
                autogenerate = true,
                rojo_project_file = "default.project.json",
                sourcemap_file = "sourcemap.json",
            },
            plugin = {
                enabled = true,
                port = 3667,
            },
            fflags = {
                enable_new_solver = true,
                sync = true,
                override = {
                    LuauTableTypeMaximumStringifierLength = "100",
                },
            },
        },
        dependencies = { "nvim-lua/plenary.nvim" },
    },
}
})
