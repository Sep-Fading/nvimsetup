-- sep/pywal_smart.lua
-- Enhanced pywal configuration with dynamic vibrancy, hue separation, and stealth comments

local pywal = require("pywal")

-- ==========================================================
-- 0. TERMINAL & GUI SETUP
-- ==========================================================

vim.opt.termguicolors = true

vim.cmd([[
    let &t_ZH="\e[3m"
    let &t_ZR="\e[23m"
    let &t_md="\e[1m"
    let &t_me="\e[0m"
]])

vim.g.terminal_color_0 = vim.g.terminal_color_0 or "#000000"

-- ==========================================================
-- 1. COLOR UTILITIES
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

local function get_luminance(r, g, b)
    r, g, b = r / 255, g / 255, b / 255
    r = r <= 0.03928 and r / 12.92 or ((r + 0.055) / 1.055) ^ 2.4
    g = g <= 0.03928 and g / 12.92 or ((g + 0.055) / 1.055) ^ 2.4
    b = b <= 0.03928 and b / 12.92 or ((b + 0.055) / 1.055) ^ 2.4
    return 0.2126 * r + 0.7152 * g + 0.0722 * b
end

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

local function is_monotone_background(hex)
    local r, g, b = hex_to_rgb(hex)
    local h, s, l = rgb_to_hsl(r, g, b)
    return s < 0.15
end

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

local function inject_vibrancy(hex, hue_shift, base_lightness)
    local r, g, b = hex_to_rgb(hex)
    local h, s, l = rgb_to_hsl(r, g, b)
    h = (h + hue_shift) % 1.0
    s = 1.0
    l = base_lightness or 0.62
    r, g, b = hsl_to_rgb(h, s, l)
    return rgb_to_hex(r, g, b)
end

-- Raises contrast against bg iteratively, with optional saturation/lightness boost
local function ensure_contrast(hex, bg_hex, min_contrast, boost_sat, boost_light, vibrancy_mode)
    if not hex then return "#ffffff" end
    bg_hex = bg_hex or "#000000"
    min_contrast = min_contrast or 6.0
    vibrancy_mode = vibrancy_mode or "normal"

    local r, g, b = hex_to_rgb(hex)
    local h, s, l = rgb_to_hsl(r, g, b)

    if boost_sat then
        if vibrancy_mode == "monotone" then
            s = 1.0                             -- full saturation always
        elseif vibrancy_mode == "high" then
            s = math.min(1.0, s * 3.0 + 0.70)
        else
            s = math.min(1.0, s * 2.5 + 0.60)
        end
    end

    if boost_light then
        if vibrancy_mode == "monotone" then
            l = math.max(l, 0.60)
            l = math.min(l, 0.75)  -- neon sweet spot: saturated but not washed
        else
            l = math.max(l, 0.58)
            l = math.min(l, 0.72)
        end
    end

    local attempts = 0
    local step = 0.025

    while attempts < 60 do
        r, g, b = hsl_to_rgb(h, s, l)
        local test_hex = rgb_to_hex(r, g, b)
        if contrast_ratio(test_hex, bg_hex) >= min_contrast then
            return test_hex
        end
        l = l + step
        if l > 0.97 then break end
        attempts = attempts + 1
    end

    return rgb_to_hex(r, g, b)
end

-- Push hue away from another color if they're too close on the wheel
local function separate_hue(hex, other_hex, min_distance)
    min_distance = min_distance or 0.12  -- ~43 degrees
    local r, g, b = hex_to_rgb(hex)
    local h, s, l = rgb_to_hsl(r, g, b)
    local r2, g2, b2 = hex_to_rgb(other_hex)
    local h2, s2, l2 = rgb_to_hsl(r2, g2, b2)

    local diff = math.abs(h - h2)
    if diff > 0.5 then diff = 1 - diff end

    if diff < min_distance then
        local direction = (h > h2) and 1 or -1
        h = (h + direction * (min_distance - diff + 0.05)) % 1.0
        r, g, b = hsl_to_rgb(h, s, l)
        return rgb_to_hex(r, g, b)
    end

    return hex
end

local function create_stealth_comment(bg_hex)
    local r, g, b = hex_to_rgb(bg_hex)
    local h, s, l = rgb_to_hsl(r, g, b)
    l = math.min(0.95, l + 0.25)
    s = math.max(0, s - 0.1)
    r, g, b = hsl_to_rgb(h, s, l)
    return rgb_to_hex(r, g, b)
end

-- ==========================================================
-- 2. PALETTE GENERATION
-- ==========================================================

local function create_color_palette(colors, bg)
    local is_monotone = is_monotone_background(bg)
    local avg_vibrancy = get_palette_vibrancy(colors)
    local is_low_vibrancy = avg_vibrancy < 0.35

    local vibrancy_mode = "normal"
    if is_monotone then
        vibrancy_mode = "monotone"
    elseif is_low_vibrancy then
        vibrancy_mode = "high"
    end

    local c = {}

    if is_monotone then
        c = {
            func    = inject_vibrancy(colors.color4 or bg, 0.55, 0.62),
            string  = inject_vibrancy(colors.color2 or bg, 0.33, 0.60),
            type    = inject_vibrancy(colors.color3 or bg, 0.15, 0.63),
            keyword = inject_vibrancy(colors.color5 or bg, 0.75, 0.65),
            special = inject_vibrancy(colors.color6 or bg, 0.50, 0.62),
            error   = inject_vibrancy(colors.color1 or bg, 0.0,  0.58),
            comment = create_stealth_comment(bg),
            number  = inject_vibrancy(colors.color1 or bg, 0.08, 0.62),
        }
    else
        c = {
            func    = ensure_contrast(colors.color4, bg, 7.0, true, true, vibrancy_mode),
            string  = ensure_contrast(colors.color2, bg, 6.0, true, true, vibrancy_mode),
            type    = ensure_contrast(colors.color3, bg, 6.5, true, true, vibrancy_mode),
            keyword = ensure_contrast(colors.color5, bg, 7.5, true, true, vibrancy_mode),
            special = ensure_contrast(colors.color6, bg, 6.5, true, true, vibrancy_mode),
            error   = ensure_contrast(colors.color1, bg, 7.0, true, false, vibrancy_mode),
            comment = create_stealth_comment(bg),
            number  = ensure_contrast(colors.color1, bg, 6.5, true, true, vibrancy_mode),
        }
    end

    -- Enforce hue separation between visually similar groups
    c.string  = separate_hue(c.string,  c.keyword, 0.12)
    c.type    = separate_hue(c.type,    c.func,    0.10)
    c.special = separate_hue(c.special, c.keyword, 0.10)
    c.number  = separate_hue(c.number,  c.string,  0.08)

    -- Re-check contrast after hue shifts (hue shift can subtly reduce brightness)
    if not is_monotone then
        c.string  = ensure_contrast(c.string,  bg, 6.0, false, true, vibrancy_mode)
        c.type    = ensure_contrast(c.type,    bg, 6.5, false, true, vibrancy_mode)
        c.special = ensure_contrast(c.special, bg, 6.5, false, true, vibrancy_mode)
        c.number  = ensure_contrast(c.number,  bg, 6.5, false, true, vibrancy_mode)
    end

    return c
end

-- ==========================================================
-- 3. PLUGIN CONFIGURATION
-- ==========================================================

pywal.setup({
    custom_highlights = function(colors, id)
        local bg = colors.background or "#000000"
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

            -- ===== LANGUAGE-SPECIFIC =====
            ["@keyword.python"]          = { fg = c.keyword, bold = true },
            ["@function.builtin.python"] = { fg = c.func, bold = true, italic = true },

            ["@keyword.rust"]            = { fg = c.keyword, bold = true },
            ["@type.rust"]               = { fg = c.type, bold = true },
            ["@attribute.rust"]          = { fg = c.special, italic = true },

            ["@constructor.lua"]         = { fg = c.func, bold = true },

            ["@markup.heading"]          = { fg = c.func, bold = true },
            ["@markup.strong"]           = { bold = true },
            ["@markup.emphasis"]         = { italic = true },
            ["@markup.link"]             = { fg = c.func, underline = true },
            ["@markup.raw"]              = { fg = c.string },
        }
    end,
})

-- ==========================================================
-- 4. POST-LOAD FIXES & AUTOCMDS
-- ==========================================================

vim.schedule(function()
    vim.cmd([[
        highlight Comment gui=italic cterm=italic
        highlight @comment gui=italic cterm=italic
        highlight @comment.documentation gui=italic cterm=italic
        highlight @keyword gui=bold cterm=bold
        highlight @keyword.function gui=bold cterm=bold
        highlight @keyword.operator gui=bold cterm=bold
        highlight @operator gui=bold cterm=bold
        highlight Function gui=bold cterm=bold
        highlight @function gui=bold cterm=bold
    ]])
end)

vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        vim.schedule(function()
            local cache_file = io.open(os.getenv("HOME") .. "/.cache/wal/colors.json", "r")
            if cache_file then
                local content = cache_file:read("*all")
                cache_file:close()

                local color6 = content:match('"color6": "(#[0-9a-fA-F]+)"')
                local color5 = content:match('"color5": "(#[0-9a-fA-F]+)"')
                local bg     = content:match('"background": "(#[0-9a-fA-F]+)"') or "#000000"

                if color6 and color5 then
                    local is_monotone = is_monotone_background(bg)
                    local vibrancy_mode = is_monotone and "monotone" or "normal"

                    local c_special, c_keyword
                    if is_monotone then
                        c_special = inject_vibrancy(color6, 0.50, 0.68)
                        c_keyword = inject_vibrancy(color5, 0.75, 0.72)
                    else
                        c_special = ensure_contrast(color6, bg, 6.5, true, true, vibrancy_mode)
                        c_keyword = ensure_contrast(color5, bg, 7.5, true, true, vibrancy_mode)
                    end

                    -- Keep them visually distinct from each other
                    c_special = separate_hue(c_special, c_keyword, 0.10)

                    vim.api.nvim_set_hl(0, "@keyword.operator", { fg = c_special, bold = true })
                    vim.api.nvim_set_hl(0, "@operator",         { fg = c_special, bold = true })
                    vim.api.nvim_set_hl(0, "@keyword",          { fg = c_keyword, bold = true })
                end
            end

            vim.cmd([[
                highlight Comment gui=italic cterm=italic
                highlight @comment gui=italic cterm=italic
                highlight @keyword gui=bold cterm=bold
                highlight Function gui=bold cterm=bold
            ]])
        end)
    end
})

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
