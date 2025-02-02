local wezterm = require 'wezterm';
local distrobox = require 'distrobox';

wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
    local zoomed = ''
    if tab.active_pane.is_zoomed then
        zoomed = '[Z] '
    end

    local index = ''
    if #tabs > 1 then
        index = string.format('WezTerm [%d/%d] ', tab.tab_index + 1, #tabs)
    else
        index = 'WezTerm '
    end

    return zoomed .. index .. tab.active_pane.title
end)

wezterm.on('update-right-status', function(window, pane)
    -- Each element holds the text for a cell in a "powerline" style << fade
    local cells = {}

    -- Figure out the cwd and host of the current pane.
    -- This will pick up the hostname for the remote host if your
    -- shell is using OSC 7 on the remote host.
    local cwd_uri = pane:get_current_working_dir()
    if cwd_uri then
        local cwd = ''
        local hostname = ''

        if type(cwd_uri) == 'userdata' then
            -- Running on a newer version of wezterm and we have
            -- a URL object here, making this simple!

            cwd = cwd_uri.file_path
            hostname = cwd_uri.host or wezterm.hostname()
        else
            -- an older version of wezterm, 20230712-072601-f4abf8fd or earlier,
            -- which doesn't have the Url object
            cwd_uri = cwd_uri:sub(8)
            local slash = cwd_uri:find '/'
            if slash then
                hostname = cwd_uri:sub(1, slash - 1)
                -- and extract the cwd from the uri, decoding %-encoding
                cwd = cwd_uri:sub(slash):gsub('%%(%x%x)', function(hex)
                    return string.char(tonumber(hex, 16))
                end)
            end
        end

        -- Remove the domain name portion of the hostname
        local dot = hostname:find '[.]'
        if dot then
            hostname = hostname:sub(1, dot - 1)
        end
        if hostname == '' then
            hostname = wezterm.hostname()
        end

        table.insert(cells, cwd)
        table.insert(cells, hostname)
    end

    -- I like my date/time in this style: "Wed Mar 3 08:14"
    local date = wezterm.strftime '%a %b %-d %H:%M'
    table.insert(cells, date)

    -- An entry for each battery (typically 0 or 1 battery)
    for _, b in ipairs(wezterm.battery_info()) do
        table.insert(cells, string.format('%.0f%%', b.state_of_charge * 100))
    end

    -- The powerline < symbol
    local LEFT_ARROW = utf8.char(0xe0b3)
    -- The filled in variant of the < symbol
    local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

    -- Color palette for the backgrounds of each cell
    local colors = {'#3c1361', '#52307c', '#663a82', '#7c5295', '#b491c8'}

    -- Foreground color for the text across the fade
    local text_fg = '#c0c0c0'

    -- The elements to be formatted
    local elements = {}
    -- How many cells have been formatted
    local num_cells = 0

    -- Translate a cell into elements
    function push(text, is_last)
        local cell_no = num_cells + 1
        table.insert(elements, {
            Foreground = {
                Color = text_fg
            }
        })
        table.insert(elements, {
            Background = {
                Color = colors[cell_no]
            }
        })
        table.insert(elements, {
            Text = ' ' .. text .. ' '
        })
        if not is_last then
            table.insert(elements, {
                Foreground = {
                    Color = colors[cell_no + 1]
                }
            })
            table.insert(elements, {
                Text = SOLID_LEFT_ARROW
            })
        end
        num_cells = num_cells + 1
    end

    while #cells > 0 do
        local cell = table.remove(cells, 1)
        push(cell, #cells == 0)
    end

    window:set_right_status(wezterm.format(elements))
end)

local config = {
    font = wezterm.font("Noto Sans Mono Rain 95", {
        weight = "Medium"
    }),
    color_scheme = "lovelace",
    font_size = 12.0,
    freetype_load_target = "HorizontalLcd",
    harfbuzz_features = {},
    initial_cols = 180,
    keys = {{
        key = 't',
        mods = 'CTRL|ALT',
        action = wezterm.action.ShowLauncher
    }, {
        key = 'UpArrow',
        mods = 'SHIFT',
        action = wezterm.action.ScrollToPrompt(-1)
    }, {
        key = 'DownArrow',
        mods = 'SHIFT',
        action = wezterm.action.ScrollToPrompt(1)
    }},
    mouse_bindings = {{
        event = {
            Down = {
                streak = 3,
                button = 'Left'
            }
        },
        action = wezterm.action.SelectTextAtMouseCursor 'SemanticZone',
        mods = 'NONE'
    }},
    send_composed_key_when_left_alt_is_pressed = false,
    scrollback_lines = 5000,
    ssh_domains = {{
        name = "sunshowers-linux",
        remote_address = "sunshowers-linux.echoes",
        username = "rain",
        override_proxy_command = "wezterm cli --no-auto-start proxy"
    }},
    ui_key_cap_rendering = "Emacs",
    window_frame = {
        -- 2024-10-26 The Noto Sans fonts look weird
        font = wezterm.font("Cantarell", {
            weight = "Bold"
        })
    }
};

local hostname = wezterm.hostname()

if hostname == 'cumulus' then
    config.font_size = 9.0
end

distrobox.apply_to_config(config)

return config;
