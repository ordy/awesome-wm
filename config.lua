local config = {}

local beautiful = require("beautiful")
local gears     = require("gears")
local awful     = require("awful")


local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top
}

local panel     = {}
local launcher  = {}
local wm_layout = {}
local select_screen = 1

function config.set_theme(theme)
    beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/" .. theme .. "/theme.lua")
end

function config.set_wallpaper(wallpaper)
    if wallpaper then
        gears.wallpaper.tiled(wallpaper, select_screen)
    end
end

function config.create_tags(names)
    return awful.tag(names, select_screen, layouts[1])
end

function config.add_panel(pos, size, l_widgets, r_widgets)
    panel = awful.wibox({ position = pos, screen = select_screen, height = size })

    local left_layout = wibox.layout.fixed.horizontal()
    for i = 1, #l_widgets do
        left_layout:add( l_widgets[i] )
    end

    local right_layout = wibox.layout.fixed.horizontal()
    for i = 1, #r_widgets do
        right_layout:add( r_widgets[i] )
    end

    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(widgets.tasklist)
    layout:set_right(right_layout)
    panel:set_bg(beautiful.panel)
    panel:set_widget(layout)
end

return config
