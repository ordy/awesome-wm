local theme = {}
theme.confdir = os.getenv('HOME') .. '/.config/awesome/themes/ord'

theme.font = 'Meiryo UI bold 8'
theme.iconfont = 'SauceCodePro Nerd Font Medium 9'
theme.mpcfont = 'SauceCodePro Nerd Font Medium 12'
theme.taglist_font = 'Meiryo UI bold 8'

theme.menu_bg_normal = '#000000'
theme.menu_bg_focus = '#141414'
theme.bg_normal = '#23232e'
theme.bg_focus = '#15151f'
theme.bg_urgent = '#000000'
theme.fg_normal = '#ccccd5'
theme.fg_focus = '#705bff'
theme.fg_urgent = '#ff2d58'
theme.fg_minimize = '#777777'
theme.border_width = 1
theme.border_normal = '#1c2022'
theme.border_focus = '#323481'
theme.border_marked = '#3ca4d8'
theme.menu_border_width = 1
theme.menu_width = 130
theme.menu_submenu_icon = theme.confdir .. '/icons/submenu.png'
theme.menu_fg_normal = '#aaaaaa'
theme.menu_fg_focus = '#705bff'
theme.menu_bg_normal = '#1e1e25'
theme.menu_bg_focus = '#15151f'

-- Widget icons
theme.widget_temp = theme.confdir .. '/icons/temp.png'
theme.widget_uptime = theme.confdir .. '/icons/ac.png'
theme.widget_cpu = theme.confdir .. '/icons/cpu.png'
theme.widget_weather = theme.confdir .. '/icons/dish.png'
theme.widget_fs = theme.confdir .. '/icons/fs.png'
theme.widget_mem = theme.confdir .. '/icons/mem.png'
theme.widget_note = theme.confdir .. '/icons/note.png'
theme.widget_note_on = theme.confdir .. '/icons/note_on.png'
theme.widget_netdown = theme.confdir .. '/icons/net_down.png'
theme.widget_netup = theme.confdir .. '/icons/net_up.png'
theme.widget_mail = theme.confdir .. '/icons/mail.png'
theme.widget_batt = theme.confdir .. '/icons/bat.png'
theme.widget_clock = theme.confdir .. '/icons/clock.png'
theme.widget_vol = theme.confdir .. '/icons/spkr.png'
theme.prev = theme.confdir .. '/icons/prev.png'
theme.nex = theme.confdir .. '/icons/next.png'
theme.stop = theme.confdir .. '/icons/stop.png'
theme.pause = theme.confdir .. '/icons/pause.png'
theme.play = theme.confdir .. '/icons/play.png'

-- Taglist
theme.taglist_squares_sel = theme.confdir .. '/icons/square_a.png'
theme.taglist_squares_unsel = theme.confdir .. '/icons/square_b.png'
theme.tasklist_disable_icon = true
theme.tasklist_plain_task_name = true

-- Submenu
theme.menu_height = 22
theme.menu_width = 120

-- Layout Icons
theme.layout_tile = theme.confdir .. '/icons/tile.png'
theme.layout_tileleft = theme.confdir .. '/icons/tileleft.png'
theme.layout_tilebottom = theme.confdir .. '/icons/tilebottom.png'
theme.layout_tiletop = theme.confdir .. '/icons/tiletop.png'
theme.layout_fairv = theme.confdir .. '/icons/fairv.png'
theme.layout_fairh = theme.confdir .. '/icons/fairh.png'
theme.layout_max = theme.confdir .. '/icons/max.png'
theme.layout_fullscreen = theme.confdir .. '/icons/fullscreen.png'
theme.layout_floating = theme.confdir .. '/icons/floating.png'

theme.maximized_honor_padding = true
theme.maximized_hide_border = true
theme.fullscreen_hide_border = true

return theme
