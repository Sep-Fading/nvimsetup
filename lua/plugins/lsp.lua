local lspconfig  = require('lspconfig')
local cmp_cap = vim.tbl_deep_extend(
    "force",
    require('cmp_nvim_lsp').default_capabilities(),
    {
        workspace = {
            didChangeWatchedFiles = {
                dynamicRegistration = true,
            },
        },
    }
)
cmp_cap.semanticTokensProvider = nil
local pid        = vim.fn.getpid()
local omnisharp_bin = vim.fn.stdpath("data")
    .. "/mason/packages/omnisharp-mono/run"
lspconfig.omnisharp.setup({
  cmd  = { omnisharp_bin, "--languageserver", "--hostPID", tostring(pid) },
  capabilities = cmp_cap,
  handlers = {
    -- better generic-method navigation
    ["textDocument/definition"] = require("omnisharp_extended").handler,
  },
  organize_imports_on_format = true,
  enable_import_completion = false,
})

