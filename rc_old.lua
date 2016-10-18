local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
local lain      = require("lain")
			 require("awful.autofocus")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local naughty   = require("naughty")
local vicious = require("vicious")
local menubar = require("menubar")

-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/pro-medium-dark/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "termite"
editor = os.getenv("EDITOR") or "vim"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
altkey = "Mod1"
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,          --1
    awful.layout.suit.tile,             --2
    awful.layout.suit.tile.bottom,      --3
    awful.layout.suit.max,              --4
    awful.layout.suit.max.fullscreen,   --5
    awful.layout.suit.fair,             --6
    awful.layout.suit.fair.horizontal,  --7
}
-- }}}

-- {{{ Wallpaper
for s = 1, screen.count() do
	awful.util.spawn_with_shell("nitrogen --restore")
end
--awful.util.spawn_with_shell("compton &")

-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "  ", "  ", "  ", "  ", "  "}, s, 
    {layouts[4],layouts[6],layouts[1],layouts[3],layouts[1]})
end
-- }}}

ctl_poweroff = "systemctl poweroff"
ctl_reboot = "systemctl reboot"

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "Edit config", terminal .. " -e \"" .. editor .. " " .. awesome.conffile .. "\"" },
   { "Log out", awesome.quit },
   { "Reboot", ctl_reboot },
   { "Shutdown", ctl_poweroff }
}

mymainmenu = awful.menu({ items = { { "Awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox

-- | Markup | --

markup = lain.util.markup

space3 = markup.font("Terminus 3", " ")
space2 = markup.font("Terminus 2", " ")
vspace1 = '<span font="Terminus 3"> </span>'
vspace2 = '<span font="Terminus 3">  </span>'
clockgf = beautiful.clockgf

-- Create a textclock widget
-- mytextclock = awful.widget.textclock()
-- datewidget = wibox.widget.textbox()
-- vicious.register(datewidget, vicious.widgets.date, "<span color='#009fff'> [ </span>".."%a %B %d, %R<span color='#009fff'> ]</span>", 60)

-- | Clock / Calendar | --

mytextclock    = awful.widget.textclock(markup(clockgf, space3 .. "%H:%M" .. markup.font("Tamsyn 3", " ")))
mytextcalendar = awful.widget.textclock(markup(clockgf, space3 .. "%a %d %b"))

widget_clock = wibox.widget.imagebox()
widget_clock:set_image(beautiful.widget_clock)

clockwidget = wibox.widget.background()
clockwidget:set_widget(mytextclock)
clockwidget:set_bgimage(beautiful.widget_display)

local index = 1
local loop_widgets = { mytextclock, mytextcalendar }
local loop_widgets_icons = { beautiful.widget_clock, beautiful.widget_cal }

clockwidget:buttons(awful.util.table.join(awful.button({}, 1,
    function ()
        index = index % #loop_widgets + 1
        clockwidget:set_widget(loop_widgets[index])
        widget_clock:set_image(loop_widgets_icons[index])
    end)))

-- | NET | --

net_widgetdl = wibox.widget.textbox()
net_widgetul = lain.widgets.net({
    settings = function()
        widget:set_markup(markup.font("Tamsyn 1", "        ") .. net_now.sent)
        net_widgetdl:set_markup(markup.font("Tamsyn 1", "        ") .. net_now.received .. markup.font("Tamsyn 1", " "))
    end
})

widget_netdl = wibox.widget.imagebox()
widget_netdl:set_image(beautiful.widget_netdl)
netwidgetdl = wibox.widget.background()
netwidgetdl:set_widget(net_widgetdl)
netwidgetdl:set_bgimage(beautiful.widget_display)

widget_netul = wibox.widget.imagebox()
widget_netul:set_image(beautiful.widget_netul)
netwidgetul = wibox.widget.background()
netwidgetul:set_widget(net_widgetul)
netwidgetul:set_bgimage(beautiful.widget_display)

-- Battery widget
batterywidget = wibox.widget.textbox()
function getBatteryStatus()
   local fd= io.popen("~/.config/awesome/battery.sh")
   local status = fd:read()
   fd:close()
   return status
end
-- Battery status timer
batteryTimer = timer({timeout = 30})
batteryTimer:connect_signal("timeout", function()
  batterywidget:set_markup(markup("#009fff","[ ") ..getBatteryStatus().. markup("#009fff"," ] "))
end)
batteryTimer:start()
batterywidget:set_markup(markup("#009fff","[ ") ..getBatteryStatus().. markup("#009fff"," ] "))

-- | BAT | --

bat_widget = wibox.widget.textbox()
vicious.register(bat_widget, vicious.widgets.bat, vspace1 .. "$2%" .. vspace1, 9, "BAT0")

widget_bat = wibox.widget.imagebox()
widget_bat:set_image(beautiful.widget_bat)
batwidget = wibox.widget.background()
batwidget:set_widget(bat_widget)
batwidget:set_bgimage(beautiful.widget_display)

-- | Widgets | --

spr = wibox.widget.imagebox()
spr:set_image(beautiful.spr)
spr4px = wibox.widget.imagebox()
spr4px:set_image(beautiful.spr4px)
spr5px = wibox.widget.imagebox()
spr5px:set_image(beautiful.spr5px)

widget_display = wibox.widget.imagebox()
widget_display:set_image(beautiful.widget_display)
widget_display_r = wibox.widget.imagebox()
widget_display_r:set_image(beautiful.widget_display_r)
widget_display_l = wibox.widget.imagebox()
widget_display_l:set_image(beautiful.widget_display_l)
widget_display_c = wibox.widget.imagebox()
widget_display_c:set_image(beautiful.widget_display_c)

-- MPD Widget
-- Buttons
music_play = awful.widget.launcher({
image = beautiful.mpd_play,
command = "mpc toggle"
})
music_stop = awful.widget.launcher({
image = beautiful.mpd_stop,
command = "mpc stop"
})
music_prev = awful.widget.launcher({
image = beautiful.mpd_prev,
command = "mpc prev"
})
music_next = awful.widget.launcher({
image = beautiful.mpd_next,
command = "mpc next"
})
mpd_sepl = wibox.widget.imagebox()
mpd_sepl:set_image(beautiful.mpd_sepl)
mpd_sepr = wibox.widget.imagebox()
mpd_sepr:set_image(beautiful.mpd_sepr)

-- Now Playing
--mpdwidget =  wibox.widget.textbox()
--mpdwidget.width = 620
--string = " "
--vicious.register(mpdwidget, vicious.widgets.mpd,
--function(widget, args)
--		if args["{Artist}"] == "N/A" then
--			string = " " .. args["{Title}"]
--		else
--			string = " " .. args["{Artist}"] .. " - " .. args["{Title}"]
--		end
--	else
--		music_play:set_image(beautiful.mpd_pause)
--		if args["{state}"] == "Stop" then
--			string = " "
--		end
--	end
--  return string
--end, 1)

mpdwidget = lain.widgets.mpd({
    settings = function ()
		if mpd_now.state == "play" then
			music_play:set_image(beautiful.mpd_pause)
			mpd_now.artist = mpd_now.artist:upper():gsub("&.-;", string.lower)
		    mpd_now.title = mpd_now.title:upper():gsub("&.-;", string.lower)
            widget:set_markup(markup.font("Tamsyn 3", " ")
                              .. markup.font("Tamsyn 7",
                              mpd_now.artist
                              .. " - " ..
                              mpd_now.title
                              .. markup.font("Tamsyn 2", " ")))
		    mpd_sepl:set_image(beautiful.mpd_sepl)
		    mpd_sepr:set_image(beautiful.mpd_sepr)    
		elseif mpd_now.state == "pause" then
		    widget:set_markup("MPD PAUSED")
		    music_play:set_image(beautiful.mpd_play)
		    mpd_sepl:set_image(beautiful.mpd_sepl)
		    mpd_sepr:set_image(beautiful.mpd_sepr)                          
		else
		    widget:set_markup("")
		    music_play:set_image(beautiful.mpd_play)
		    mpd_sepl:set_image(nil)
		    mpd_sepr:set_image(nil)
		end
    end
})                          

musicwidget = wibox.widget.background()
musicwidget:set_widget(mpdwidget)
musicwidget:set_bgimage(beautiful.widget_display)
-------

-- ALSA volume
volicon = wibox.widget.imagebox(beautiful.widget_vol)
volumewidget = lain.widgets.alsa({
    settings = function()
        if volume_now.status == "off" then
            volume_now.level = volume_now.level .. "M"
        end

        widget:set_markup(markup("#009fff"," [ ") .. markup("#cc99cc", volume_now.level .. "%") .. markup("#009fff"," ] "))
    end
})
-------

-- Create a wibox for each screen and add it
mywibox = {}
mywibox_bot = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the top wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = "22" })
    -- Create the bottom wibox
    mywibox_bot[s] = awful.wibox({ position = "bottom", screen = s, height = "22" })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])


    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
	right_layout:add(spr)
	right_layout:add(widget_clock)
	right_layout:add(widget_display_l)
	right_layout:add(clockwidget)
	right_layout:add(widget_display_r)
	right_layout:add(spr5px)
	right_layout:add(spr)

    right_layout:add(mylayoutbox[s])

    -- Widgets that are aligned to the bottom left
    local left_layout_bot = wibox.layout.fixed.horizontal()
	left_layout_bot:add(music_play)
	left_layout_bot:add(spr)	  
	left_layout_bot:add(music_stop)
	left_layout_bot:add(spr)	
	left_layout_bot:add(music_prev)
	left_layout_bot:add(spr)	
	left_layout_bot:add(music_next)
	left_layout_bot:add(mpd_sepl)	
	left_layout_bot:add(mpdwidget)
	left_layout_bot:add(mpd_sepr)	
    -- Widgets that are aligned to the bottom right
    local right_layout_bot = wibox.layout.fixed.horizontal()
    right_layout_bot:add(volicon)
	right_layout_bot:add(volumewidget)
    right_layout_bot:add(batterywidget)

	right_layout_bot:add(widget_bat)
	right_layout_bot:add(widget_display_l)
	right_layout_bot:add(batwidget)
	right_layout_bot:add(widget_display_r)
	right_layout_bot:add(spr5px)

	right_layout_bot:add(spr)

	right_layout_bot:add(widget_netdl)
	right_layout_bot:add(widget_display_l)
	right_layout_bot:add(netwidgetdl)
	right_layout_bot:add(widget_display_c)
	right_layout_bot:add(netwidgetul)
	right_layout_bot:add(widget_display_r)
	right_layout_bot:add(widget_netul)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    local layout_bot = wibox.layout.align.horizontal()
    layout_bot:set_left(left_layout_bot)
    layout_bot:set_right(right_layout_bot)

    mywibox[s]:set_widget(layout)
    mywibox_bot[s]:set_widget(layout_bot)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, ",", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),
    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    awful.key({ modkey,           }, "w",     function () awful.util.spawn("chromium")   end),
    awful.key({ modkey,           }, "x",     function () awful.util.spawn("thunar")   end),
    awful.key({ modkey,           }, "p",     function () awful.util.spawn("screenswitch")   end),
    awful.key({ modkey,           }, "dollar",     function () awful.util.spawn("mpc next")   end),
    awful.key({ modkey,           }, "dead_circumflex",     function () awful.util.spawn("mpc prev")   end),
    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),
    -- ALSA volume control
    awful.key({ altkey }, "Up",
        function ()
            os.execute(string.format("amixer set %s 5%%+", volumewidget.channel))
            volumewidget.update()
        end),
    awful.key({ altkey }, "Down",
        function ()
            os.execute(string.format("amixer set %s 5%%-", volumewidget.channel))
            volumewidget.update()
        end),
    awful.key({ altkey }, "m",
        function ()
            os.execute(string.format("amixer sset Master toggle", volumewidget.channel))
            volumewidget.update()
		end)

)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, 	      }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
           c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
					 size_hints_honor = false } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

-- No border for maximized clients
client.connect_signal("focus",
  function(c)
	for s = 1, screen.count() do
		local clients = awful.client.visible(s)		
        local layout  = awful.layout.getname(awful.layout.get(s))

		if #clients == 1 and layout ~= "floating" then
		  for _, c in pairs(clients) do
				if not awful.client.floating.get(c) then                                     
				    c.border_width = 0
				end
			end
		elseif c.maximized then
			c.border_width = 0
		else
		  c.border_width = beautiful.border_width
		  c.border_color = beautiful.border_focus
		end
	end
end)

client.connect_signal("unfocus",
  function(c)
	if c.maximized then
		c.border_width = 0
	else
		c.border_width = beautiful.border_width
		c.border_color = beautiful.border_normal
	end
  end)
-- }}}


