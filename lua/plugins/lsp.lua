local pid = vim.fn.getpid()
local capabilities = require('cmp_nvim_lsp').default_capabilities()

capabilities.textDocument.semanticTokens = nil
