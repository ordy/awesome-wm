-- Standard awesome library
local gears = require('gears')
local awful = require('awful')
local lain = require('lain')
local vicious = require('vicious')
require('awful.autofocus')
-- Widget and layout library
local wibox = require('wibox')
-- Theme handling library
local beautiful = require('beautiful')
-- Notification library
local naughty = require('naughty')
local watch = require('awful.widget.watch')
local menubar = require('menubar')
local hotkeys_popup = require('awful.hotkeys_popup').widget
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require('awful.hotkeys_popup.keys')

local os = {getenv = os.getenv, setlocale = os.setlocale}
local markup = lain.util.markup
local home = os.getenv('HOME')
local INC_VOLUME_CMD = 'pactl set-sink-volume 1 +5%'
local DEC_VOLUME_CMD = 'pactl set-sink-volume 1 -5%'
local TOG_VOLUME_CMD = 'amixer -D pulse sset Master toggle'

awful.spawn.with_shell('~/.config/awesome/autorun.sh')

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
if awesome.startup_errors then
  -- another config (This code will only ever execute for the fallback config)
  naughty.notify(
    {
      preset = naughty.config.presets.critical,
      title = 'Oops, there were errors during startup!',
      text = awesome.startup_errors
    }
  )
end

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal(
    'debug::error',
    function(err)
      -- Make sure we don't go into an endless error loop
      if in_error then
        return
      end
      in_error = true

      naughty.notify(
        {
          preset = naughty.config.presets.critical,
          title = 'Oops, an error happened!',
          text = tostring(err)
        }
      )
      in_error = false
    end
  )
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(home .. '/.config/awesome/themes/ord/theme.lua')

-- This is used later as the default terminal and editor to run.
terminal = 'alacritty'
editor = os.getenv('EDITOR') or 'vim'
editor_cmd = terminal .. ' -e ' .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = 'Mod4'
modkey2 = 'Mod1'

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
  awful.layout.suit.floating, -- 1
  awful.layout.suit.max, -- 2
  awful.layout.suit.tile, -- 3
  awful.layout.suit.tile.bottom, -- 4
  awful.layout.suit.fair, -- 5
  awful.layout.suit.fair.horizontal -- 6
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
  local instance = nil

  return function()
    if instance and instance.wibox.visible then
      instance:hide()
      instance = nil
    else
      instance = awful.menu.clients({theme = {width = 250}})
    end
  end
end
-- }}}

local SYSTEMCTL = 'systemctl '

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
  {
    'hotkeys',
    function()
      return false, hotkeys_popup.show_help
    end
  },
  {'manual', terminal .. ' -e man awesome'},
  {'edit config', editor_cmd .. ' ' .. awesome.conffile},
  {
    'edit theme',
    editor_cmd .. ' ' .. './.config/awesome/themes/ord/theme.lua'
  }
}

sessionmenu = {
  {'shutdown', SYSTEMCTL .. 'poweroff'},
  {'sleep', SYSTEMCTL .. 'suspend'},
  {'restart', awesome.restart},
  {
    'quit',
    function()
      awesome.quit()
    end
  }
}

monsmenu = {
  {
    'laptop screen',
    function()
      awful.util.spawn('autorandr --load laptop', false)
    end
  },
  {
    'vga screen',
    function()
      awful.util.spawn('autorandr --load vga', false)
    end
  },
  {
    'dual screen',
    function()
      awful.util.spawn('mons -e left')
    end
  }
}

mymainmenu =
  awful.menu(
  {
    items = {
      {'awesome', myawesomemenu},
      {'display', monsmenu},
      {'session', sessionmenu}
    }
  }
)

mylauncher =
  awful.widget.launcher(
  {
    image = beautiful.awesome_icon,
    menu = mymainmenu
  }
)

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibar

-- Create a textclock widget
os.setlocale(os.getenv('LANG')) -- to localize the clock
local clockicon = wibox.widget.textbox(markup('#20f0ff', '  '))
local mytextclock = wibox.widget.textclock(markup('#20f0ff', '%A %d %B ') .. markup('#a07bff', '%H:%M '))
mytextclock.font = beautiful.font
clockicon.font = beautiful.iconfont

-- Calendar
beautiful.cal =
  lain.widget.cal(
  {
    attach_to = {mytextclock},
    notification_preset = {
      font = 'SauceCodePro Nerd Font Medium 9',
      fg = beautiful.fg_normal,
      bg = beautiful.bg_normal
    }
  }
)

-- Battery
--local baticon = wibox.widget.imagebox(beautiful.widget_batt)
local baticon = wibox.widget.textbox(markup('#f3f225', '  '))
baticon.font = beautiful.iconfont
local bat =
  lain.widget.bat(
  {
    settings = function()
      local perc = bat_now.perc ~= 'N/A' and bat_now.perc .. '%' or bat_now.perc

      if bat_now.ac_status == 1 then
        perc = 'AC'
      end

      widget:set_markup(markup.fontfg(beautiful.font, beautiful.fg_normal, perc .. ' '))
    end
  }
)

-- Weather
--local weathericon = wibox.widget.imagebox(beautiful.widget_weather)
local weathericon = wibox.widget.textbox(markup('#43f265', '   '))
weathericon.font = beautiful.iconfont
local weather =
  lain.widget.weather(
  {
    APPID="53478245761d4af6508888611e5d0a95",
    cnt=8,
    city_id = 2786770,
    units="metric",
    notification_preset = {font = beautiful.font, fg = beautiful.fg_normal},
    weather_na_markup = markup.fontfg(beautiful.font, '#43f265', 'N/A'),
    settings = function()
      descr = weather_now['weather'][1]['description']:lower()
      units = math.floor(weather_now['main']['temp'])
      widget:set_markup(markup.fontfg(beautiful.font, '#43f265', descr .. ' @ ' .. units .. '°C'))
    end
  }
)

-- CPU
--local cpuicon = wibox.widget.imagebox(beautiful.widget_cpu)
local cpuicon = wibox.widget.textbox(markup('#20f0ff', '   '))
cpuicon.font = beautiful.iconfont
local cpu =
  lain.widget.cpu(
  {
    settings = function()
      widget:set_markup(markup.fontfg(beautiful.font, '#20f0ff', cpu_now.usage .. '%'))
    end
  }
)

-- Coretemp
--local tempicon = wibox.widget.imagebox(beautiful.widget_temp)
local tempicon = wibox.widget.textbox(markup('#22fcaf', '  '))
tempicon.font = beautiful.iconfont
local temp =
  lain.widget.temp(
  {
    settings = function()
      widget:set_markup(markup.fontfg(beautiful.font, '#22fcaf', coretemp_now .. '°C'))
    end
  }
)

-- Net
--local netdownicon = wibox.widget.imagebox(beautiful.widget_netdown)
local netdownicon = wibox.widget.textbox(markup('#705bff', '   '))
local netdowninfo = wibox.widget.textbox()
--local netupicon = wibox.widget.imagebox(beautiful.widget_netup)
local netupicon = wibox.widget.textbox(markup('#1d96ff', '   '))
local netupinfo = wibox.widget.textbox()
netupicon.font = beautiful.iconfont
netdownicon.font = beautiful.iconfont

local netinfo =
  lain.widget.net(
  {
    settings = function()
      netupinfo:set_markup(markup.fontfg(beautiful.font, '#1d96ff', net_now.sent))
      netdowninfo:set_markup(markup.fontfg(beautiful.font, '#705bff', net_now.received))
    end
  }
)

-- ALSA volume
--local volicon = wibox.widget.imagebox(beautiful.widget_vol)
local volicon = wibox.widget.textbox(markup('#22fcaf', '   '))
volicon.font = beautiful.iconfont
local volume =
  lain.widget.alsa(
  {
    settings = function()
      if volume_now.status == 'off' then
        volume_now.level = volume_now.level .. 'M'
      end

      widget:set_markup(markup.fontfg(beautiful.font, '#22fcaf', volume_now.level .. '% '))
    end
  }
)
volume.widget:buttons(
  awful.util.table.join(
    awful.button(
      {},
      3,
      function()
        -- right click
        awful.util.spawn(TOG_VOLUME_CMD, false)
        volume.update()
      end
    ),
    awful.button(
      {},
      4,
      function()
        -- scroll up
        awful.util.spawn(INC_VOLUME_CMD, false)
        volume.update()
      end
    ),
    awful.button(
      {},
      5,
      function()
        -- scroll down
        awful.util.spawn(DEC_VOLUME_CMD, false)
        volume.update()
      end
    )
  )
)

-- MPD
local mpd =
  lain.widget.mpd(
  {
    settings = function()
      mpd_notification_preset = {
        text = string.format('%s - %s', mpd_now.artist, mpd_now.title)
      }

      if mpd_now.state == 'play' then
        artist = mpd_now.artist .. '  '
        title = mpd_now.title .. ' '
      elseif mpd_now.state == 'pause' then
        artist = 'mpd '
        title = 'paused '
      else
        artist = ''
        title = ''
      end
      widget:set_markup(markup.fontfg(beautiful.font, '#10ebff', artist) .. markup.fontfg(beautiful.font, '#e2e2e2', title))
    end
  }
)
-- MPC Controls
--local mpc_play_pause = wibox.widget.imagebox(beautiful.play)
local mpc_play_pause = wibox.widget.textbox(markup('#705bff', ' '))
mpc_play_pause.font = beautiful.mpcfont
mpc_play_pause:buttons(
  awful.button(
    {},
    1,
    function()
      awful.util.spawn('mpc toggle', false)
      if mpd_now.state == 'play' then
        mpc_play_pause:set_markup(markup('#705bff', ' 契'))
      else
        mpc_play_pause:set_markup(markup('#705bff', ' '))
      end
    end
  )
)

--local mpc_stop = wibox.widget.imagebox(beautiful.stop)
local mpc_stop = wibox.widget.textbox(markup('#705bff', ' 栗'))
mpc_stop.font = beautiful.mpcfont
mpc_stop:buttons(
  awful.button(
    {},
    1,
    function()
      awful.util.spawn('mpc stop', false)
    end
  )
)

-- local mpc_prev = wibox.widget.imagebox(beautiful.prev)
local mpc_prev = wibox.widget.textbox(markup('#705bff', ' '))
mpc_prev.font = beautiful.mpcfont
mpc_prev:buttons(
  awful.button(
    {},
    1,
    function()
      awful.util.spawn('mpc prev', false)
    end
  )
)

--local mpc_next = wibox.widget.imagebox(beautiful.nex)
local mpc_next = wibox.widget.textbox(markup('#705bff', '  '))
mpc_next.font = beautiful.mpcfont
mpc_next:buttons(
  awful.button(
    {},
    1,
    function()
      awful.util.spawn('mpc next', false)
    end
  )
)

-- Create a wibox for each screen and add it
local taglist_buttons =
  gears.table.join(
  awful.button(
    {},
    1,
    function(t)
      t:view_only()
    end
  ),
  awful.button(
    {modkey},
    1,
    function(t)
      if client.focus then
        client.focus:move_to_tag(t)
      end
    end
  ),
  awful.button({}, 3, awful.tag.viewtoggle),
  awful.button(
    {modkey},
    3,
    function(t)
      if client.focus then
        client.focus:toggle_tag(t)
      end
    end
  ),
  awful.button(
    {},
    4,
    function(t)
      awful.tag.viewnext(t.screen)
    end
  ),
  awful.button(
    {},
    5,
    function(t)
      awful.tag.viewprev(t.screen)
    end
  )
)

local tasklist_buttons =
  gears.table.join(
  awful.button(
    {},
    1,
    function(c)
      if c == client.focus then
        c.minimized = true
      else
        c:emit_signal('request::activate', 'tasklist', {raise = true})
      end
    end
  ),
  awful.button(
    {},
    3,
    function()
      awful.menu.client_list({theme = {width = 250}})
    end
  ),
  awful.button(
    {},
    4,
    function()
      awful.client.focus.byidx(1)
    end
  ),
  awful.button(
    {},
    5,
    function()
      awful.client.focus.byidx(-1)
    end
  )
)

local function set_wallpaper(s)
  -- Wallpaper
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == 'function' then
      wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
  end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal('property::geometry', set_wallpaper)

-- Arrange signal handler
for s = 1, screen.count() do
  screen[s]:connect_signal(
    'arrange',
    function()
      local clients = awful.client.visible(s)
      local layout = awful.layout.getname(awful.layout.get(s))

      if #clients > 0 then -- Fine grained borders and floaters control
        for _, c in pairs(clients) do -- Floaters always have borders
          if awful.client.floating.get(c) or layout == 'floating' then
            -- No borders with only one visible client
            c.border_width = beautiful.border_width
          elseif #clients == 1 or layout == 'max' then
            c.border_width = 0
          else
            c.border_width = beautiful.border_width
          end
        end
      end
    end
  )
end
------------------------------------------------------

awful.screen.connect_for_each_screen(
  function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag(
      {'1 web', '2 term', '3 code', '4 files', '5 media'},
      s,
      {
        awful.layout.layouts[1],
        awful.layout.layouts[6],
        awful.layout.layouts[2],
        awful.layout.layouts[3],
        awful.layout.layouts[1]
      }
    )

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(
      gears.table.join(
        awful.button(
          {},
          1,
          function()
            awful.layout.inc(1)
          end
        ),
        awful.button(
          {},
          3,
          function()
            awful.layout.inc(-1)
          end
        ),
        awful.button(
          {},
          4,
          function()
            awful.layout.inc(1)
          end
        ),
        awful.button(
          {},
          5,
          function()
            awful.layout.inc(-1)
          end
        )
      )
    )
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the top wibox
    s.mywibox = awful.wibar({position = 'top', height = 20, screen = s})

    -- Add widgets to the top wibox
    s.mywibox:setup {
      layout = wibox.layout.align.horizontal,
      {
        -- Left widgets
        layout = wibox.layout.fixed.horizontal,
        mylauncher,
        s.mytaglist,
        s.mypromptbox
      },
      s.mytasklist, -- Middle widget
      {
        -- Right widgets
        layout = wibox.layout.fixed.horizontal,
        clockicon,
        mytextclock
      }
    }
    -- Create the bottom wibox
    s.mybwibox = awful.wibar({position = 'bottom', height = 20, screen = s})

    -- Add widgets to the bottom wibox
    s.mybwibox:setup {
      layout = wibox.layout.align.horizontal,
      expand = 'none',
      {
        -- Left widgets
        layout = wibox.layout.fixed.horizontal,
        mpc_play_pause,
        mpc_stop,
        mpc_prev,
        mpc_next,
        --mpdicon,
        mpd
        --
      },
      {
        layout = wibox.layout.fixed.horizontal,
        netdownicon,
        netdowninfo,
        netupicon,
        netupinfo,
        cpuicon,
        cpu,
        tempicon,
        temp,
        weathericon,
        weather
      },
      {
        -- Right widgets
        layout = wibox.layout.fixed.horizontal,
        wibox.widget.systray(),
        volumearc_widget,
        volicon,
        volume,
        baticon,
        bat,
        s.mylayoutbox
      }
    }
  end
)
-- }}}

-- {{{ Mouse bindings
root.buttons(
  gears.table.join(
    awful.button(
      {},
      3,
      function()
        mymainmenu:toggle()
      end
    ),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
  )
)
-- }}}

-- {{{ Key bindings
globalkeys =
  gears.table.join(
  awful.key(
    {modkey},
    'g',
    hotkeys_popup.show_help,
    {
      description = 'show help',
      group = 'awesome'
    }
  ),
  awful.key({modkey}, 'Left', awful.tag.viewprev, {description = 'view previous', group = 'tag'}),
  awful.key(
    {modkey},
    'Right',
    awful.tag.viewnext,
    {
      description = 'view next',
      group = 'tag'
    }
  ),
  awful.key({modkey}, 'Escape', awful.tag.history.restore, {description = 'go back', group = 'tag'}),
  awful.key(
    {modkey},
    'j',
    function()
      awful.client.focus.byidx(1)
    end,
    {description = 'focus next by index', group = 'client'}
  ),
  awful.key(
    {modkey},
    'k',
    function()
      awful.client.focus.byidx(-1)
    end,
    {description = 'focus previous by index', group = 'client'}
  ),
  awful.key(
    {modkey, 'Shift'},
    'w',
    function()
      mymainmenu:show()
    end,
    {
      description = 'show main menu',
      group = 'awesome'
    }
  ), -- Layout manipulation
  awful.key(
    {modkey, 'Shift'},
    'j',
    function()
      awful.client.swap.byidx(1)
    end,
    {description = 'swap with next client by index', group = 'client'}
  ),
  awful.key(
    {modkey, 'Shift'},
    'k',
    function()
      awful.client.swap.byidx(-1)
    end,
    {description = 'swap with previous client by index', group = 'client'}
  ),
  awful.key(
    {modkey, 'Control'},
    'j',
    function()
      awful.screen.focus_relative(1)
    end,
    {description = 'focus the next screen', group = 'screen'}
  ),
  awful.key(
    {modkey, 'Control'},
    'k',
    function()
      awful.screen.focus_relative(-1)
    end,
    {description = 'focus the previous screen', group = 'screen'}
  ),
  awful.key({modkey}, 'u', awful.client.urgent.jumpto, {description = 'jump to urgent client', group = 'client'}),
  awful.key(
    {modkey},
    'Tab',
    function()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end,
    {description = 'go back', group = 'client'}
  ),
  -- Standard program
  awful.key(
    {modkey},
    'Return',
    function()
      awful.spawn(terminal)
    end,
    {description = 'open a terminal', group = 'launcher'}
  ),
  awful.key(
    {modkey, 'Control'},
    'r',
    awesome.restart,
    {
      description = 'reload awesome',
      group = 'awesome'
    }
  ),
  awful.key({modkey, 'Shift'}, 'q', awesome.quit, {description = 'quit awesome', group = 'awesome'}),
  awful.key(
    {modkey},
    'p',
    function()
      awful.spawn('autorandr -c', false)
    end,
    {description = 'Display toggle', group = 'screen'}
  ),
  awful.key(
    {modkey},
    'w',
    function()
      awful.spawn('firefox')
    end,
    {
      description = 'Open a web browser',
      group = 'launcher'
    }
  ),
  awful.key(
    {modkey},
    'x',
    function()
      awful.spawn('pcmanfm')
    end,
    {description = 'Open a file manager', group = 'launcher'}
  ),
  awful.key(
    {modkey},
    's',
    function()
      awful.spawn('spectacle -rbc', false)
    end,
    {description = 'Screen capture rectangle', group = 'launcher'}
  ),
  awful.key(
    {modkey, 'Shift'},
    's',
    function()
      awful.spawn('spectacle -bm -o $RANDOM.jpg', false)
    end,
    {description = 'Screen capture all', group = 'launcher'}
  ),
  -- MPC shortcuts for mpd
  awful.key(
    {modkey2},
    ']',
    function()
      awful.spawn('mpc next', false)
    end,
    {
      description = 'Next song in mpd',
      group = 'client'
    }
  ),
  awful.key(
    {modkey2},
    '[',
    function()
      awful.spawn('mpc prev', false)
    end,
    {description = 'Previous song in mpd', group = 'client'}
  ),
  awful.key(
    {modkey2},
    'space',
    function()
      awful.spawn('mpc toggle', false)
    end,
    {description = 'Previous song in mpd', group = 'client'}
  ),
  -- playerctl shortcuts for Spotidy
  awful.key(
    {modkey},
    ']',
    function()
      awful.spawn('playerctl --player=spotify next', false)
    end,
    {description = 'Next song in playerctl', group = 'client'}
  ),
  awful.key(
    {modkey},
    '[',
    function()
      awful.spawn('playerctl --player=spotify previous', false)
    end,
    {description = 'Previous song in playerctl', group = 'client'}
  ),
  awful.key(
    {modkey, modkey2},
    'space',
    function()
      awful.spawn('playerctl --player=spotify play-pause', false)
    end,
    {description = 'Previous song in playerctl', group = 'client'}
  ),
  awful.key(
    {modkey},
    'l',
    function()
      awful.tag.incmwfact(0.05)
    end,
    {description = 'increase master width factor', group = 'layout'}
  ),
  awful.key(
    {modkey},
    'h',
    function()
      awful.tag.incmwfact(-0.05)
    end,
    {description = 'decrease master width factor', group = 'layout'}
  ),
  awful.key(
    {modkey, 'Shift'},
    'h',
    function()
      awful.tag.incnmaster(1, nil, true)
    end,
    {description = 'increase the number of master clients', group = 'layout'}
  ),
  awful.key(
    {modkey, 'Shift'},
    'l',
    function()
      awful.tag.incnmaster(-1, nil, true)
    end,
    {description = 'decrease the number of master clients', group = 'layout'}
  ),
  awful.key(
    {modkey, 'Control'},
    'h',
    function()
      awful.tag.incncol(1, nil, true)
    end,
    {description = 'increase the number of columns', group = 'layout'}
  ),
  awful.key(
    {modkey, 'Control'},
    'l',
    function()
      awful.tag.incncol(-1, nil, true)
    end,
    {description = 'decrease the number of columns', group = 'layout'}
  ),
  awful.key(
    {modkey},
    'space',
    function()
      awful.layout.inc(1)
    end,
    {
      description = 'select next',
      group = 'layout'
    }
  ),
  awful.key(
    {modkey, 'Shift'},
    'space',
    function()
      awful.layout.inc(-1)
    end,
    {description = 'select previous', group = 'layout'}
  ),
  -- Volume media keys
  awful.key(
    {},
    'XF86AudioRaiseVolume',
    function()
      awful.util.spawn(INC_VOLUME_CMD, false)
      volume.update()
    end
  ),
  awful.key(
    {},
    'XF86AudioLowerVolume',
    function()
      awful.util.spawn(DEC_VOLUME_CMD, false)
      volume.update()
    end
  ),
  awful.key(
    {},
    'XF86AudioMute',
    function()
      awful.util.spawn(TOG_VOLUME_CMD, false)
      volume.update()
    end
  ),
  awful.key(
    {modkey, 'Control'},
    'n',
    function()
      local c = awful.client.restore()
      -- Focus restored client
      if c then
        client.focus = c
        c:raise()
      end
    end,
    {description = 'restore minimized', group = 'client'}
  ), -- Prompt
  awful.key(
    {modkey, 'Shift'},
    'r',
    function()
      awful.screen.focused().mypromptbox:run()
    end,
    {description = 'run prompt', group = 'launcher'}
  ),
  awful.key(
    {modkey, 'Shift'},
    'x',
    function()
      awful.prompt.run {
        prompt = 'Run Lua code: ',
        textbox = awful.screen.focused().mypromptbox.widget,
        exe_callback = awful.util.eval,
        history_path = awful.util.get_cache_dir() .. '/history_eval'
      }
    end,
    {description = 'lua execute prompt', group = 'awesome'}
  ), -- Menubar
  awful.key(
    {modkey},
    'r',
    function()
      awful.spawn.with_shell('$HOME/.config/rofi/launchers/ribbon/launcher.sh')
    end,
    {description = 'show the menubar', group = 'launcher'}
  )
)

clientkeys =
  gears.table.join(
  awful.key(
    {modkey},
    'f',
    function(c)
      c.fullscreen = not c.fullscreen
      c:raise()
    end,
    {description = 'toggle fullscreen', group = 'client'}
  ),
  awful.key(
    {modkey},
    'c',
    function(c)
      c:kill()
    end,
    {
      description = 'close',
      group = 'client'
    }
  ),
  awful.key({modkey, 'Control'}, 'space', awful.client.floating.toggle, {description = 'toggle floating', group = 'client'}),
  awful.key(
    {modkey, 'Control'},
    'Return',
    function(c)
      c:swap(awful.client.getmaster())
    end,
    {description = 'move to master', group = 'client'}
  ),
  awful.key(
    {modkey},
    'o',
    function(c)
      c:move_to_screen()
    end,
    {
      description = 'move to screen',
      group = 'client'
    }
  ),
  awful.key(
    {modkey},
    't',
    function(c)
      c.ontop = not c.ontop
    end,
    {description = 'toggle keep on top', group = 'client'}
  ),
  awful.key(
    {modkey},
    'n',
    function(c)
      -- The client currently has the input focus so it cannot be
      -- minimized, since minimized clients can't have the focus.
      c.minimized = true
    end,
    {description = 'minimize', group = 'client'}
  ),
  awful.key(
    {modkey},
    'm',
    function(c)
      c.maximized = not c.maximized
      c:raise()
    end,
    {description = '(un)maximize', group = 'client'}
  ),
  awful.key(
    {modkey, 'Control'},
    'm',
    function(c)
      c.maximized_vertical = not c.maximized_vertical
      c:raise()
    end,
    {description = '(un)maximize vertically', group = 'client'}
  ),
  awful.key(
    {modkey, 'Shift'},
    'm',
    function(c)
      c.maximized_horizontal = not c.maximized_horizontal
      c:raise()
    end,
    {description = '(un)maximize horizontally', group = 'client'}
  )
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  globalkeys =
    gears.table.join(
    globalkeys, -- View tag only.
    awful.key(
      {modkey},
      '#' .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          tag:view_only()
        end
      end,
      {description = 'view tag #' .. i, group = 'tag'}
    ),
    -- Toggle tag display.
    awful.key(
      {modkey, 'Control'},
      '#' .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end,
      {description = 'toggle tag #' .. i, group = 'tag'}
    ),
    -- Move client to tag.
    awful.key(
      {modkey, 'Shift'},
      '#' .. i + 9,
      function()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:move_to_tag(tag)
          end
        end
      end,
      {description = 'move focused client to tag #' .. i, group = 'tag'}
    ),
    -- Toggle tag on focused client.
    awful.key(
      {modkey, 'Control', 'Shift'},
      '#' .. i + 9,
      function()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:toggle_tag(tag)
          end
        end
      end,
      {description = 'toggle focused client on tag #' .. i, group = 'tag'}
    )
  )
end

clientbuttons =
  gears.table.join(
  awful.button(
    {},
    1,
    function(c)
      client.focus = c
      c:raise()
    end
  ),
  awful.button({modkey}, 1, awful.mouse.client.move),
  awful.button({modkey}, 3, awful.mouse.client.resize)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
  -- All clients will match this rule.
  {
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      keys = clientkeys,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
      size_hints_honor = false,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen + awful.placement.centered
    }
  }, -- Floating clients.
  {
    rule_any = {
      instance = {
        'copyq' -- Includes session name in class.
      },
      class = {
        'Arandr',
        'Gpick',
        'MessageWin', -- kalarm.
        'Wpa_gui',
        'xtightvncviewer'
      },
      name = {
        'Event Tester' -- xev.
      },
      role = {
        'AlarmWindow', -- Thunderbird's calendar.
        'pop-up' -- e.g. Google Chrome's (detached) Developer Tools.
      }
    },
    properties = {floating = true}
  }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal(
  'manage',
  function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
      -- Prevent clients from being unreachable after screen count changes.
      awful.placement.no_offscreen(c)
    end
  end
)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal(
  'mouse::enter',
  function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and awful.client.focus.filter(c) then
      client.focus = c
    end
  end
)

client.connect_signal(
  'focus',
  function(c)
    c.border_color = beautiful.border_focus
  end
)
client.connect_signal(
  'unfocus',
  function(c)
    c.border_color = beautiful.border_normal
  end
)
-- }}}
