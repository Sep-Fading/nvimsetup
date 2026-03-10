local alpha = require'alpha'
local dashboard = require'alpha.themes.dashboard'
-- Set a cool logo (You can change this to ASCII art)
dashboard.section.header.val = {
    [[                               __                ]],
    [[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
    [[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
    [[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
    [[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
    [[ \/_/\/_/\/____/\/____/ \/__/    \/_/\/_/\/_/\/_/]],
}

-- Buttons to jump to files
dashboard.section.buttons.val = {
    dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
    dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
    dashboard.button("r", "  Recent", ":Telescope oldfiles <CR>"),
    dashboard.button("q", "  Quit NVIM", ":qa<CR>"),
}

dashboard.section.header.opts.hl = "String"
alpha.setup(dashboard.config)
