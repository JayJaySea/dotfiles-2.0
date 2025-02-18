-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")


home = os.getenv("HOME")
config = home .. "/.config/awesome"
-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
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
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.

local function update_tag_info()
    local current = awful.screen.focused().selected_tag.index

    local tgs = awful.screen.focused().tags
    local occupied_tags = '['
    local visible_tags_count = 0

    for i = 1, #tgs do
        local client_count = 0
        for j = 1, #tgs[i]:clients() do
            if tgs[i]:clients()[j].class ~= "eww-top-bar" then
                client_count = client_count + 1
            end
        end
        if client_count > 0 or i == current then
            if visible_tags_count ~= 0 then
                occupied_tags = occupied_tags .. ','
            end
            occupied_tags = occupied_tags .. ' ' .. i
            visible_tags_count = visible_tags_count + 1
        end
    end

    occupied_tags = occupied_tags .. ']'

    awful.spawn(config .. "/scripts/update_tag_info " .. current .. " '" .. occupied_tags .. "'")
end

local function viewtag_occupied(direction)
    local s = awful.screen.focused()
    local tags = s.tags
    local next_index = s.selected_tag.index + direction

    for i = next_index, direction > 0 and #tags or 1, direction do
        local t = tags[i]
        local client_count = #t:clients();

        for j = 1, #t:clients() do
            local class = t:clients()[j].class
            if class == "eww-top-bar" or class == "eww-top-bar2" then
                client_count = client_count - 1
            end
        end

        if client_count > 0 then
            t:view_only()
            update_tag_info()
            return
        end
    end
end

local function viewtag_empty()
    awful.tag.viewnone()
    local tgs = awful.screen.focused().tags
    for i = 1, #tgs do
        local t = tgs[i]
        local client_count = #t:clients();

        for j = 1, #t:clients() do
            if t:clients()[j].class == "eww-top-bar" then
                client_count = client_count - 1
            end
        end

        if client_count == 0 then
            awful.tag.viewtoggle(tgs[i])
            update_tag_info()
            break
        end
    end
end


local theme_path = config .. "/default/theme.lua"
beautiful.init(theme_path)
print(theme_path)


-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
--
-- modkey = "Mod4"
modkey = "Mod1"
rofi_launch = "rofi -show drun" 
clipboard_manager = "rofi -modi \"clipboard:greenclip print\" -show clipboard -run-command '{cmd}'"
notes = "/home/xxxx/.bin/notes"
projects = "/home/xxxx/.bin/projects open"
projects_new = "alacritty -e /home/xxxx/.bin/projects new"
projects_rm = "/home/xxxx/.bin/projects rm"
projects_add = "alacritty -e /home/xxxx/.bin/projects add"
projects_edit = "alacritty -e /home/xxxx/.bin/projects edit"
notes_add = "alacritty -e /home/xxxx/projects/rust/spark-nvim/launch/spark_manage.py add"
notes_open = "/home/xxxx/projects/rust/spark-nvim/launch/spark_manage.py open"

browser_launch = "firefox"
schedule = "alacritty -e /home/xxxx/.bin/schedule"
revive_xrandr = "/home/xxxx/.bin/xrandr_revive"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    -- awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    --awful.layout.suit.tile.top,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
-- local taglist_buttons = gears.table.join(
--                     awful.button({ }, 1, function(t) t:view_only() end),
--                     awful.button({ modkey }, 1, function(t)
--                                               if client.focus then
--                                                   client.focus:move_to_tag(t)
--                                               end
--                                           end),
--                     awful.button({ }, 3, awful.tag.viewtoggle),
--                     awful.button({ modkey }, 3, function(t)
--                                               if client.focus then
--                                                   client.focus:toggle_tag(t)
--                                               end
--                                           end),
--                     awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
--                     awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
--                 )

-- local tasklist_buttons = gears.table.join(
--                      awful.button({ }, 1, function (c)
--                                               if c == client.focus then
--                                                   c.minimized = true
--                                               else
--                                                   c:emit_signal(
--                                                       "request::activate",
--                                                       "tasklist",
--                                                       {raise = true}
--                                                   )
--                                               end
--                                           end),
--                      awful.button({ }, 3, function()
--                                               awful.menu.client_list({ theme = { width = 250 } })
--                                           end),
--                      awful.button({ }, 4, function ()
--                                               awful.client.focus.byidx(1)
--                                           end),
--                      awful.button({ }, 5, function ()
--                                               awful.client.focus.byidx(-1)
--                                           end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    -- s.mywibox = awful.wibar({ position = "top", screen = s })

    -- -- Add widgets to the wibox
    -- s.mywibox:setup {
    --     layout = wibox.layout.align.horizontal,
    --     { -- Left widgets
    --         layout = wibox.layout.fixed.horizontal,
    --         mylauncher,
    --         s.mytaglist,
    --         s.mypromptbox,
    --     },
    --     s.mytasklist, -- Middle widget
    --     { -- Right widgets
    --         layout = wibox.layout.fixed.horizontal,
    --         mykeyboardlayout,
    --         wibox.widget.systray(),
    --         mytextclock,
    --         s.mylayoutbox,
    --     },
    -- }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
    -- awful.button({ }, 4, awful.tag.viewnext),
    -- awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ }, "Print",     function () awful.spawn("flameshot full -c") end,
              {description = "make screenshot", group = "client"}),

    awful.key({ "Shift" }, "Print",     function () awful.spawn("flameshot gui -p " .. home .. "/pictures/screenshots") end,
              {description = "make screenshot", group = "client"}),

    awful.key({ }, "#233",     function () awful.spawn("brightnessctl s +10%") end,
              {description = "lauch rofi", group = "client"}),
    awful.key({ }, "#232",     function () awful.spawn("brightnessctl s 10-%") end,
              {description = "lauch rofi", group = "client"}),

    awful.key({ }, "#123",     function () awful.spawn("pactl set-sink-volume 0 +5%") end,
              {description = "lauch rofi", group = "client"}),
    awful.key({ }, "#122",     function () awful.spawn("pactl set-sink-volume 0 -5%") end,
              {description = "lauch rofi", group = "client"}),
    awful.key({ }, "#121",     function () awful.spawn("pactl set-sink-mute 0 toggle") end,
              {description = "lauch rofi", group = "client"}),

    awful.key({ modkey,            }, "m",     function () awful.spawn(rofi_launch) end,
              {description = "lauch rofi", group = "client"}),

    awful.key({ modkey,            }, "c",     function () awful.spawn(clipboard_manager) end,
              {description = "clipboard manager", group = "client"}),

    awful.key({ modkey,            }, "w",     function () awful.spawn(notes) end,
              {description = "notes", group = "client"}),

    awful.key({ modkey,            }, "o",     function () awful.spawn(projects) end,
              {description = "projects", group = "client"}),

    awful.key({ modkey,            }, "t",     function () awful.spawn(projects_new) end,
              {description = "projects", group = "client"}),

    awful.key({ modkey,            }, "a",     function () awful.spawn(projects_add) end,
              {description = "projects", group = "client"}),

    awful.key({ modkey,            }, "r",     function () awful.spawn(projects_rm) end,
              {description = "projects", group = "client"}),

    awful.key({ modkey,            }, "y",     function () awful.spawn(projects_edit) end,
              {description = "projects", group = "client"}),

    awful.key({ modkey,            }, "i",     function () awful.spawn(notes_open) end,
              {description = "notes", group = "client"}),

    awful.key({ modkey,            }, "s",     function () awful.spawn(notes_add) end,
              {description = "notes", group = "client"}),

    awful.key({ modkey,            }, "u",     function () awful.spawn(revive_xrandr) end,
              {description = "projects", group = "client"}),

    awful.key({ modkey,            }, "b",     function () awful.spawn(browser_launch) end,
              {description = "lauch rofi", group = "client"}),
-- 
    awful.key({ modkey,           }, "p",   function() viewtag_occupied(-1) end,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "n",  function() viewtag_occupied(1) end,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "e",  viewtag_empty,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "Down",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "Up",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "Down", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "Up", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    -- awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
    --           {description = "focus the next screen", group = "screen"}),
    -- awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
    --           {description = "focus the previous screen", group = "screen"}),
    -- awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              -- {description = "jump to urgent client", group = "client"}),
    -- awful.key({ modkey,           }, "Tab",
    --     function ()
    --         awful.client.focus.history.previous()
    --         if client.focus then
    --             client.focus:raise()
    --         end
    --     end,
    --     {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Shift" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "Right",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "Left",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "Left",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "Right",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "Left",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "Right",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),


    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),

    awful.key({ modkey,           }, "space", function () awful.layout.inc(1)                end,
              {description = "select next", group = "layout"}),

    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"})

    -- awful.key({ modkey, "Control" }, "n",
    --           function ()
    --               local c = awful.client.restore()
    --               -- Focus restored client
    --               if c then
    --                 c:emit_signal(
    --                     "request::activate", "key.unminimize", {raise = true}
    --                 )
    --               end
    --           end,
    --           {description = "restore minimized", group = "client"}),

    -- Prompt
    -- awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
    --           {description = "run prompt", group = "launcher"}),

    -- awful.key({ modkey }, "x",
    --           function ()
    --               awful.prompt.run {
    --                 prompt       = "Run Lua code: ",
    --                 textbox      = awful.screen.focused().mypromptbox.widget,
    --                 exe_callback = awful.util.eval,
    --                 history_path = awful.util.get_cache_dir() .. "/history_eval"
    --               }
    --           end,
    --           {description = "lua execute prompt", group = "awesome"})
    -- Menubar
    -- awful.key({ modkey }, "p", function() menubar.show() end,
    --           {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey,            }, "d",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    -- awful.key({ modkey,           }, "n",
    --     function (c)
    --         -- The client currently has the input focus, so it cannot be
    --         -- minimized, since minimized clients can't have the focus.
    --         c.minimized = true
    --     end ,
    --     {description = "minimize", group = "client"}),
    -- awful.key({ modkey,           }, "m",
    --     function (c)
    --         c.maximized = not c.maximized
    --         c:raise()
    --     end ,
    --     {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 10 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                           update_tag_info()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"})
        -- Toggle tag on focused client.
        -- awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
        --           function ()
        --               if client.focus then
        --                   local tag = client.focus.screen.tags[i]
        --                   if tag then
        --                       client.focus:toggle_tag(tag)
        --                   end
        --               end
        --           end,
        --           {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

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
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},
    { rule = { class = "firefox" },
      properties = { opacity = 1, maximized = false, floating = false } },
    { rule = { class = "thunderbird" },
      properties = { opacity = 1, maximized = false, floating = false } },
    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = {}
    },


    { rule = { class = "eww-top-bar" },
        properties = {
            focusable = false,
            border_width = dpi(0)
        }
    },

    { rule = { class = "eww-top-bar2" },
        properties = {
            focusable = false,
            border_width = dpi(0)
        }
    }

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
-- client.connect_signal("mouse::enter", function(c)
--     c:emit_signal("request::activate", "mouse_enter", {raise = false})
-- end)
function is_terminal(c)
    return (c.class and c.class:match("Alacritty")) and true or false
end

function copy_size(c, parent_client)
    if not c or not parent_client then
        return
    end
    if not c.valid or not parent_client.valid then
        return
    end
    c.x=parent_client.x;
    c.y=parent_client.y;
    c.width=parent_client.width;
    c.height=parent_client.height;
end
function check_resize_client(c)
    if(c.child_resize) then
        copy_size(c.child_resize, c)
    end
end

client.connect_signal("property::size", check_resize_client)
client.connect_signal("property::position", check_resize_client)
client.connect_signal("manage", function(c)
    if is_terminal(c) then
        return
    end
    local parent_client=awful.client.focus.history.get(c.screen, 1)
    if parent_client and is_terminal(parent_client) then
        parent_client.child_resize=c
        c.floating=true
        copy_size(c, parent_client)
    end
end)
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

awful.spawn("picom --config /home/xxxx/.config/picom.conf")
awful.spawn("greenclip daemon")
awful.spawn("/home/xxxx/.cargo/bin/informator")
awful.spawn("/home/xxxx/.bin/mergexsel")
awful.spawn("eww open top-bar")
