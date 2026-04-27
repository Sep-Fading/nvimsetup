local status, saga = pcall(require, "lspsaga")
if not status then return end

saga.setup({
    ui = {
        border = 'rounded',
        devicon = true,
        title = true,
        expand = '⊞',
        collapse = '⊟',
        code_action = '💡',
    },
    hover = {
        max_width = 0.6,
        open_link = 'gx',
    },
    -- This adds a "breadcrumbs" bar at the top of your window
    symbol_in_winbar = {
        enable = true,
    },

    callhierarchy = {
        layout = 'float',
    },
})

