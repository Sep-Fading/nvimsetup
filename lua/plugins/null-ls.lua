local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/"
local null_ls = require("null-ls")

null_ls.setup({
    debug = true,
    sources = {
        -- Python
        null_ls.builtins.formatting.black,
        
        -- JavaScript / TypeScript
        require("none-ls.diagnostics.eslint"),
        null_ls.builtins.formatting.prettier,
    },

    -- Format on save
    on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format({ bufnr = bufnr })
                end,
            })
        end
    end,
})
