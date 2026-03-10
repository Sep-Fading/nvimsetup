-- sep/pywal_smart.lua
-- Enhanced pywal configuration with dynamic vibrancy and stealth comments

local pywal = require("pywal")

-- ==========================================================
-- 0. TERMINAL & GUI SETUP
-- ==========================================================

vim.opt.termguicolors = true

-- Force proper italic and bold support
vim.cmd([[
    let &t_ZH="\e[3m"
    let &t_ZR="\e[23m"
    let &t_md="\e[1m"
    let &t_me="\e[0m"
]])

-- Ensure terminal supports bold and italic
vim.g.terminal_color_0 = vim.g.terminal_color_0 or "#000000"

-- ==========================================================
-- 1. ENHANCED COLOR UTILITIES
-- ==========================================================

local function hex_to_rgb(hex)
    hex = hex:gsub("#", "")
    return tonumber("0x" .. hex:sub(1, 2)),
        tonumber("0x" .. hex:sub(3, 4)),
        tonumber("0x" .. hex:sub(5, 6))
end

local function rgb_to_hex(r, g, b)
    return string.format("#%02x%02x%02x",
        math.floor(r * 255),
        math.floor(g * 255),
        math.floor(b * 255))
end

-- Calculate relative luminance (WCAG standard)
local function get_luminance(r, g, b)
    r, g, b = r / 255, g / 255, b / 255
    r = r <= 0.03928 and r / 12.92 or ((r + 0.055) / 1.055) ^ 2.4
    g = g <= 0.03928 and g / 12.92 or ((g + 0.055) / 1.055) ^ 2.4
    b = b <= 0.03928 and b / 12.92 or ((b + 0.055) / 1.055) ^ 2.4
    return 0.2126 * r + 0.7152 * g + 0.0722 * b
end

-- Calculate contrast ratio between two colors
local function contrast_ratio(hex1, hex2)
    local r1, g1, b1 = hex_to_rgb(hex1)
    local r2, g2, b2 = hex_to_rgb(hex2)
    local l1 = get_luminance(r1, g1, b1)
    local l2 = get_luminance(r2, g2, b2)
    local lighter = math.max(l1, l2)
    local darker = math.min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)
end

local function hue2rgb(p, q, t)
    if t < 0 then t = t + 1 end
    if t > 1 then t = t - 1 end
    if t < 1 / 6 then return p + (q - p) * 6 * t end
    if t < 1 / 2 then return q end
    if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
    return p
end

-- Convert RGB to HSL
local function rgb_to_hsl(r, g, b)
    r, g, b = r / 255, g / 255, b / 255
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, l = 0, 0, (max + min) / 2

    if max ~= min then
        local d = max - min
        s = l > 0.5 and d / (2 - max - min) or d / (max + min)
        if max == r then
            h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then
            h = (b - r) / d + 2
        elseif max == b then
            h = (r - g) / d + 4
        end
        h = h / 6
    end

    return h, s, l
end

-- Convert HSL to RGB
local function hsl_to_rgb(h, s, l)
    local r, g, b

    if s == 0 then
        r, g, b = l, l, l
    else
        local q = l < 0.5 and l * (1 + s) or l + s - l * s
        local p = 2 * l - q
        r = hue2rgb(p, q, h + 1 / 3)
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - 1 / 3)
    end

    return r, g, b
end

-- Detect if background is monotone (grayscale/low saturation)
local function is_monotone_background(hex)
    local r, g, b = hex_to_rgb(hex)
    local h, s, l = rgb_to_hsl(r, g, b)

    -- Monotone if saturation is very low
    return s < 0.15
end

-- Get average saturation of the color palette
local function get_palette_vibrancy(colors)
    local total_sat = 0
    local count = 0

    for i = 1, 8 do
        local color = colors["color" .. i]
        if color then
            local r, g, b = hex_to_rgb(color)
            local h, s, l = rgb_to_hsl(r, g, b)
            total_sat = total_sat + s
            count = count + 1
        end
    end

    return count > 0 and (total_sat / count) or 0
end

-- Inject vibrancy into monotone palettes by creating colorful variants
local function inject_vibrancy(hex, hue_shift, base_lightness)
    local r, g, b = hex_to_rgb(hex)
    local h, s, l = rgb_to_hsl(r, g, b)

    -- Use the shifted hue with high saturation
    h = (h + hue_shift) % 1.0
    s = 0.75 -- High saturation for vibrancy
    l = base_lightness or 0.65

    r, g, b = hsl_to_rgb(h, s, l)
    return rgb_to_hex(r, g, b)
end

-- Enhanced contrast adjustment with dynamic saturation boosting
local function ensure_contrast(hex, bg_hex, min_contrast, boost_sat, boost_light, vibrancy_mode)
    if not hex then return "#ffffff" end
    bg_hex = bg_hex or "#000000"
    min_contrast = min_contrast or 4.5
    vibrancy_mode = vibrancy_mode or "normal" -- "normal", "high", "monotone"

    local r, g, b = hex_to_rgb(hex)
    local h, s, l = rgb_to_hsl(r, g, b)

    -- Apply vibrancy boost based on mode
    if boost_sat then
        if vibrancy_mode == "monotone" then
            -- Aggressive saturation boost for monotone backgrounds
            s = math.min(1.0, s * 2.0 + 0.4)
        elseif vibrancy_mode == "high" then
            -- Strong boost for low-vibrancy palettes
            s = math.min(1.0, s * 1.6 + 0.3)
        else
            -- Normal boost
            s = math.min(1.0, s * 1.3 + 0.2)
        end
    end

    if boost_light then
        if vibrancy_mode == "monotone" then
            l = math.max(l, 0.65)
            l = math.min(l, 0.88)
        else
            l = math.max(l, 0.6)
            l = math.min(l, 0.85)
        end
    end

    -- Iteratively adjust lightness to meet contrast requirements
    local attempts = 0
    local max_attempts = 50
    local step = 0.02

    while attempts < max_attempts do
        r, g, b = hsl_to_rgb(h, s, l)
        local test_hex = rgb_to_hex(r, g, b)
        local ratio = contrast_ratio(test_hex, bg_hex)

        if ratio >= min_contrast then
            return test_hex
        end

        if l < 0.5 then
            l = l + step
        else
            l = l + step * 0.5
        end

        if l > 0.95 then
            break
        end

        attempts = attempts + 1
    end

    return rgb_to_hex(r, g, b)
end

-- Create stealth comment color (very low contrast)
local function create_stealth_comment(bg_hex)
    local r, g, b = hex_to_rgb(bg_hex)
    local h, s, l = rgb_to_hsl(r, g, b)

    -- Keep hue similar to background for stealth
    -- Just barely lighter than background
    l = math.min(0.95, l + 0.25) -- Subtle lightness increase
    s = math.max(0, s - 0.1)     -- Reduce saturation for neutrality

    r, g, b = hsl_to_rgb(h, s, l)
    return rgb_to_hex(r, g, b)
end

-- Create distinct variants for different syntax groups
local function create_color_palette(colors, bg)
    local is_monotone = is_monotone_background(bg)
    local avg_vibrancy = get_palette_vibrancy(colors)
    local is_low_vibrancy = avg_vibrancy < 0.3

    -- Determine vibrancy mode
    local vibrancy_mode = "normal"
    if is_monotone then
        vibrancy_mode = "monotone"
    elseif is_low_vibrancy then
        vibrancy_mode = "high"
    end

    -- For pure monotone backgrounds, inject vibrant colors
    if is_monotone then
        return {
            func    = inject_vibrancy(colors.color4 or bg, 0.55, 0.68), -- Blue
            string  = inject_vibrancy(colors.color2 or bg, 0.33, 0.65), -- Green
            type    = inject_vibrancy(colors.color3 or bg, 0.15, 0.70), -- Yellow
            keyword = inject_vibrancy(colors.color5 or bg, 0.75, 0.72), -- Magenta
            special = inject_vibrancy(colors.color6 or bg, 0.50, 0.68), -- Cyan
            error   = inject_vibrancy(colors.color1 or bg, 0.0, 0.60),  -- Red
            comment = create_stealth_comment(bg),                       -- Stealth
            number  = inject_vibrancy(colors.color1 or bg, 0.08, 0.68), -- Orange
        }
    else
        -- Use pywal colors but enhance them
        return {
            func    = ensure_contrast(colors.color4, bg, 5.5, true, true, vibrancy_mode),
            string  = ensure_contrast(colors.color2, bg, 4.5, true, true, vibrancy_mode),
            type    = ensure_contrast(colors.color3, bg, 5.0, true, true, vibrancy_mode),
            keyword = ensure_contrast(colors.color5, bg, 6.0, true, true, vibrancy_mode),
            special = ensure_contrast(colors.color6, bg, 5.0, true, true, vibrancy_mode),
            error   = ensure_contrast(colors.color1, bg, 6.0, true, false, vibrancy_mode),
            comment = create_stealth_comment(bg),
            number  = ensure_contrast(colors.color1, bg, 5.0, true, true, vibrancy_mode),
        }
    end
end

-- ==========================================================
-- 2. PLUGIN CONFIGURATION
-- ==========================================================

pywal.setup({
    custom_highlights = function(colors, id)
        -- Determine background color (assuming dark background)
        local bg = colors.background or "#000000"

        -- Generate optimized color palette with dynamic vibrancy
        local c = create_color_palette(colors, bg)

        return {
            -- ===== STANDARD VIM GROUPS =====
            Function                     = { fg = c.func, bold = true },
            String                       = { fg = c.string },
            Character                    = { fg = c.string },
            Number                       = { fg = c.number },
            Float                        = { fg = c.number },
            Boolean                      = { fg = c.special, bold = true },
            Constant                     = { fg = c.special },

            Statement                    = { fg = c.keyword, bold = true },
            Conditional                  = { fg = c.keyword, bold = true },
            Repeat                       = { fg = c.keyword, bold = true },
            Label                        = { fg = c.keyword, bold = true },
            Keyword                      = { fg = c.keyword, bold = true },
            Exception                    = { fg = c.error, bold = true },

            Include                      = { fg = c.keyword, bold = true },
            Define                       = { fg = c.keyword },
            Macro                        = { fg = c.special },
            PreProc                      = { fg = c.keyword },
            PreCondit                    = { fg = c.keyword },

            Type                         = { fg = c.type, bold = true },
            StorageClass                 = { fg = c.keyword, bold = true },
            Structure                    = { fg = c.type },
            Typedef                      = { fg = c.type },

            Operator                     = { fg = c.special, bold = true },
            Delimiter                    = { fg = colors.foreground },

            Special                      = { fg = c.special },
            SpecialChar                  = { fg = c.special },
            Tag                          = { fg = c.func },
            SpecialComment               = { fg = c.comment, italic = true },
            Debug                        = { fg = c.error },

            Identifier                   = { fg = colors.foreground },
            Error                        = { fg = c.error, bold = true },
            ErrorMsg                     = { fg = c.error, bold = true },
            WarningMsg                   = { fg = c.number, bold = true },

            Comment                      = { fg = c.comment, italic = true },
            LineNr                       = { fg = c.comment },
            CursorLineNr                 = { fg = c.keyword, bold = true },

            -- ===== TREESITTER GROUPS =====
            ["@variable"]                = { fg = colors.foreground },
            ["@variable.builtin"]        = { fg = c.special, italic = true },
            ["@variable.parameter"]      = { fg = colors.foreground, italic = true },
            ["@variable.member"]         = { fg = colors.foreground },

            ["@constant"]                = { fg = c.special },
            ["@constant.builtin"]        = { fg = c.special, bold = true },
            ["@constant.macro"]          = { fg = c.special },

            ["@string"]                  = { fg = c.string },
            ["@string.escape"]           = { fg = c.special, bold = true },
            ["@string.special"]          = { fg = c.special },
            ["@character"]               = { fg = c.string },
            ["@character.special"]       = { fg = c.special },

            ["@number"]                  = { fg = c.number },
            ["@number.float"]            = { fg = c.number },

            ["@boolean"]                 = { fg = c.special, bold = true },

            ["@function"]                = { fg = c.func, bold = true },
            ["@function.builtin"]        = { fg = c.func, bold = true, italic = true },
            ["@function.call"]           = { fg = c.func },
            ["@function.macro"]          = { fg = c.special },
            ["@function.method"]         = { fg = c.func, bold = true },
            ["@function.method.call"]    = { fg = c.func },

            ["@constructor"]             = { fg = c.type, bold = true },

            ["@keyword"]                 = { fg = c.keyword, bold = true },
            ["@keyword.function"]        = { fg = c.keyword, bold = true },
            ["@keyword.operator"]        = { fg = c.special, bold = true },
            ["@keyword.return"]          = { fg = c.keyword, bold = true },
            ["@keyword.exception"]       = { fg = c.error, bold = true },
            ["@keyword.conditional"]     = { fg = c.keyword, bold = true },
            ["@keyword.repeat"]          = { fg = c.keyword, bold = true },
            ["@keyword.import"]          = { fg = c.keyword, bold = true },

            ["@operator"]                = { fg = c.special, bold = true },

            ["@punctuation.bracket"]     = { fg = colors.foreground },
            ["@punctuation.delimiter"]   = { fg = colors.foreground },
            ["@punctuation.special"]     = { fg = c.special },

            ["@comment"]                 = { fg = c.comment, italic = true },
            ["@comment.documentation"]   = { fg = c.comment, italic = true },
            ["@comment.error"]           = { fg = c.error, bold = true },
            ["@comment.warning"]         = { fg = c.number, bold = true },
            ["@comment.todo"]            = { fg = c.keyword, bold = true, italic = true },
            ["@comment.note"]            = { fg = c.func, bold = true, italic = true },

            ["@type"]                    = { fg = c.type, bold = true },
            ["@type.builtin"]            = { fg = c.type, bold = true },
            ["@type.definition"]         = { fg = c.type, bold = true },
            ["@type.qualifier"]          = { fg = c.keyword, bold = true },

            ["@attribute"]               = { fg = c.special },
            ["@property"]                = { fg = colors.foreground },

            ["@label"]                   = { fg = c.keyword },

            ["@namespace"]               = { fg = c.type },
            ["@module"]                  = { fg = c.type },

            ["@tag"]                     = { fg = c.func, bold = true },
            ["@tag.attribute"]           = { fg = c.type },
            ["@tag.delimiter"]           = { fg = colors.foreground },

            -- ===== UI ELEMENTS =====
            Pmenu                        = { bg = "#1a1a1a", fg = colors.foreground },
            PmenuSel                     = { bg = c.func, fg = "#000000", bold = true },
            PmenuSbar                    = { bg = "#2a2a2a" },
            PmenuThumb                   = { bg = c.func },

            Visual                       = { bg = "#2a2a2a" },
            VisualNOS                    = { bg = "#2a2a2a" },

            Search                       = { bg = c.number, fg = "#000000", bold = true },
            IncSearch                    = { bg = c.keyword, fg = "#000000", bold = true },
            CurSearch                    = { bg = c.keyword, fg = "#000000", bold = true },

            StatusLine                   = { bg = "#1a1a1a", fg = colors.foreground },
            StatusLineNC                 = { bg = "#0a0a0a", fg = c.comment },

            -- ===== LANGUAGE-SPECIFIC ENHANCEMENTS =====
            -- Python
            ["@keyword.python"]          = { fg = c.keyword, bold = true },
            ["@function.builtin.python"] = { fg = c.func, bold = true, italic = true },

            -- Rust
            ["@keyword.rust"]            = { fg = c.keyword, bold = true },
            ["@type.rust"]               = { fg = c.type, bold = true },
            ["@attribute.rust"]          = { fg = c.special, italic = true },

            -- Lua
            ["@constructor.lua"]         = { fg = c.func, bold = true },

            -- Markdown
            ["@markup.heading"]          = { fg = c.func, bold = true },
            ["@markup.strong"]           = { bold = true },
            ["@markup.emphasis"]         = { italic = true },
            ["@markup.link"]             = { fg = c.func, underline = true },
            ["@markup.raw"]              = { fg = c.string },
        }
    end,
})

-- ==========================================================
-- 3. POST-LOAD FIXES & AUTOCMDS
-- ==========================================================

-- Force styles after colorscheme loads
vim.schedule(function()
    -- Ensure comment italics persist
    vim.cmd([[
        highlight Comment gui=italic cterm=italic
        highlight @comment gui=italic cterm=italic
        highlight @comment.documentation gui=italic cterm=italic
    ]])

    -- Force bold where needed
    vim.cmd([[
        highlight @keyword gui=bold cterm=bold
        highlight @keyword.function gui=bold cterm=bold
        highlight @keyword.operator gui=bold cterm=bold
        highlight @operator gui=bold cterm=bold
        highlight Function gui=bold cterm=bold
        highlight @function gui=bold cterm=bold
    ]])
end)

-- Persist styles across any colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        vim.schedule(function()
            -- Re-read pywal colors
            local cache_file = io.open(os.getenv("HOME") .. "/.cache/wal/colors.json", "r")
            if cache_file then
                local content = cache_file:read("*all")
                cache_file:close()

                -- Extract colors
                local color6 = content:match('"color6": "(#[0-9a-fA-F]+)"')
                local color5 = content:match('"color5": "(#[0-9a-fA-F]+)"')
                local bg = content:match('"background": "(#[0-9a-fA-F]+)"') or "#000000"

                if color6 and color5 then
                    local is_monotone = is_monotone_background(bg)
                    local vibrancy_mode = is_monotone and "monotone" or "normal"

                    local c_special, c_keyword
                    if is_monotone then
                        c_special = inject_vibrancy(color6, 0.50, 0.68)
                        c_keyword = inject_vibrancy(color5, 0.75, 0.72)
                    else
                        c_special = ensure_contrast(color6, bg, 5.0, true, true, vibrancy_mode)
                        c_keyword = ensure_contrast(color5, bg, 6.0, true, true, vibrancy_mode)
                    end

                    -- Force critical highlights
                    vim.api.nvim_set_hl(0, "@keyword.operator", { fg = c_special, bold = true })
                    vim.api.nvim_set_hl(0, "@operator", { fg = c_special, bold = true })
                    vim.api.nvim_set_hl(0, "@keyword", { fg = c_keyword, bold = true })
                end
            end

            -- Re-apply italic and bold
            vim.cmd([[
                highlight Comment gui=italic cterm=italic
                highlight @comment gui=italic cterm=italic
                highlight @keyword gui=bold cterm=bold
                highlight Function gui=bold cterm=bold
            ]])
        end)
    end
})

-- Additional safeguard: reapply after any highlight clearing
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        vim.schedule(function()
            vim.cmd([[
                highlight Comment gui=italic cterm=italic
                highlight @comment gui=italic cterm=italic
            ]])
        end)
    end
})
