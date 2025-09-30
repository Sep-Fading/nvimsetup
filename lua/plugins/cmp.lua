local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({ 
        behaviour = cmp.ConfirmBehavior.Insert,
        select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.close(),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp", keyword_length=3 },
    { name = "luasnip" },
    { name = "path"},
    { name = "nvim_lsp_signature_help"},
    { name = "nvim_lua", keyword_length = 2},
    { name = "vsnip", keyword_length = 2},
    { name = "buffer", keyword_length = 3},
    { name = "calc"},
  }),

  window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
  },
})

