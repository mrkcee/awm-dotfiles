local gfs = require("gears.filesystem")
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local rubato = require "lib.rubato"

----- Bar -----

screen.connect_signal("request::desktop_decoration", function(s)
    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", }, s, awful.layout.layouts[2])

	----- Making Variables -----
	
	-- Time

	local hour = wibox.widget {
		widget = wibox.widget.textbox,
	}

	local icon = wibox.widget {
		markup = "<span foreground='" .. beautiful.magenta .. "'></span>",
		widget = wibox.widget.textbox,
	}

	local time = wibox.widget {
		{
			{
				hour,
				spacing = dpi(4),
				layout = wibox.layout.fixed.horizontal,
			},
			margins = {top=dpi(4), bottom=dpi(4), left=dpi(9), right=dpi(9)},
			widget = wibox.container.margin,
		},
		shape = function(cr,w,h) gears.shape.rounded_rect(cr,w,h,5) end,
		bg = beautiful.bar,
		widget = wibox.container.background,
	}

	local set_clock = function() -- Update the value of the clock
		_ = os.date("%B %d %I:%M%p")
		hour.markup = "<span foreground='" .. beautiful.fg_normal .. "'>" .. _ .. "</span>"
	end

	local update_clock = gears.timer { -- Timer every 5 sec
		timeout = 5,
		autostart = true,
		call_now = true,
		callback = function()
			set_clock()
		end
	}

	-- layoutBox 
	
	local laybuttons = {
		awful.button({ }, 1, function () awful.layout.inc( 1) end),
      		awful.button({ }, 3, function () awful.layout.inc(-1) end),
    		awful.button({ }, 4, function () awful.layout.inc( 1) end),
        	awful.button({ }, 5, function () awful.layout.inc(-1) end),
	}
	
	local layoutbox = wibox.widget {
		{
			{
				buttons = laybuttons,
				widget = awful.widget.layoutbox,
			},
			margins = { top = dpi(6), bottom = dpi(6), right = dpi(4), left = dpi(4) },
			widget = wibox.container.margin,
		},
		bg = beautiful.bar,
		widget = wibox.container.background,
	}

        -- System tray
	
	local sys_tray = wibox.widget {
		{
			wibox.widget.systray(),
			margins = { top = dpi(8), bottom = dpi(6), right = dpi(6), left = dpi(6) },
			widget = wibox.container.margin,
		},
		bg = beautiful.bar,
		widget = wibox.container.background,

	}

	-- Volume 
        
	local vol_buttons = {
		awful.button({ }, 1, function() awful.spawn.easy_async_with_shell("pactl set-sink-mute @DEFAULT_SINK@ toggle") end)
	}

	local vol_icon = wibox.widget {
		{
			{
				id = "icon",
				markup = "",
				buttons = vol_buttons,
				widget = wibox.widget.textbox,
			},
			margins = dpi(6),
			widget = wibox.container.margin,
		},
		bg = beautiful.bar,
		widget = wibox.container.background,
	}

	awesome.connect_signal("signal::volume", function(vol, mute)
		if mute or vol == 0 then
		        vol_icon:get_children_by_id("icon")[1].markup = "<span foreground='" .. beautiful.fg_normal .. "'></span>"
		elseif vol > 0 and vol < 75 then
		        vol_icon:get_children_by_id("icon")[1].markup = "<span foreground='" .. beautiful.fg_normal .. "'></span>"
		else
		        vol_icon:get_children_by_id("icon")[1].markup = "<span foreground='" .. beautiful.fg_normal .. "'></span>"
		end

	end)

	-- Network
	
	local wifi = wibox.widget {
		{
			{
				id = "icon",
				markup = "",
				widget = wibox.widget.textbox,
			},
			margins = dpi(6),
			widget = wibox.container.margin,
		},
		bg = beautiful.bar,
		widget = wibox.container.background,
	}

	awesome.connect_signal("signal::wifi", function(stat, ssid)
		if stat then
			wifi:get_children_by_id("icon")[1].markup = "<span foreground='" .. beautiful.green .. "'></span>"
		else
			wifi:get_children_by_id("icon")[1].markup = "<span foreground='" .. beautiful.red .. "'></span>"
		end

	end)

	-- Info
	
	local info = wibox.widget {
		{
			{
				sys_tray,
				wifi,
				vol_icon,
				time,
				layout = wibox.layout.fixed.horizontal,
			},
			margins = dpi(6),
			widget = wibox.container.margin,
		},
		shape = function(cr,w,h) gears.shape.rounded_rect(cr,w,h,5) end,
		bg = beautiful.bar,
		widget = wibox.container.background,
	}

	-- Tasklist
	
	local tasklist = awful.widget.tasklist {
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		layout = {
			spacing = dpi(10),
			layout = wibox.layout.fixed.horizontal,
		},
		widget_template = {
			{
				{
					id = "icon_role",
					widget = wibox.widget.imagebox,
				},
				widget = wibox.container.margin,
			},
			forced_width = dpi(40),
			shape = function(cr,w,h) gears.shape.rounded_rect(cr,w,h,5) end,
			bg = beautiful.bar,
			widget = wibox.container.background,
		},
	}

	local task = wibox.widget {
		{
			{
				tasklist,
				layout = wibox.layout.align.horizontal,
			},
			margins = {left = dpi(6), right = dpi(6)},
			widget = wibox.container.margin,
		},
		forced_height = dpi(40),
		shape = function(cr,w,h) gears.shape.rounded_rect(cr,w,h,5) end,
		bg = beautiful.bar .. "00",
		widget = wibox.container.background,
	}

	-- Taglist/Workspaces
	
	local taglist_buttons = gears.table.join(
        	awful.button({ }, 1, function(t) t:view_only() end),
        	awful.button({ modkey }, 1, function(t)
                      	            	if client.focus then
                      	                	client.focus:move_to_tag(t)
                      	            	end
			    	end),
        	awful.button({ }, 3, awful.tag.viewtoggle),
        	awful.button({ modkey }, 3, function(t)
                                  	if client.focus then
                                      		client.focus:toggle_tag(t)
                                  	end
                              	end),
		awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
		awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
    	)
	
	local tags = awful.widget.taglist {
		screen = s,
		filter = awful.widget.taglist.filter.all,
		layout = {
			spacing = dpi(0),
			layout = wibox.layout.fixed.horizontal,
		},
		style = {
			font = beautiful.font_name .. " " .. beautiful.font_size,
		},
		buttons = taglist_buttons,
		widget_template = {
			{
				{
					{
						id = 'text_role',
						forced_width = dpi(25),
						align = 'center',
						widget = wibox.widget.textbox,
					},
					layout = wibox.layout.align.horizontal,
				},
				margins = dpi(4),
				widget = wibox.container.margin,
			},
			id = 'bg',
			widget = wibox.container.background,

			-- Just ignore these things below...

			--create_callback = function(self, c3, _, _)
			--	if c3.selected then
			--		self:get_children_by_id("bg")[1].bg = beautiful.bar_alt
			--	else
			--		self:get_children_by_id("bg")[1].bg = beautiful.bar
			--	end
			--end,

			--update_callback = function(self, c3, _)
			--	if c3.selected then
                        --                self:get_children_by_id("bg")[1].bg = beautiful.bar_alt
                        --        else
                        --                self:get_children_by_id("bg")[1].bg = beautiful.bar
                        --        end
                        --end,
		},

	}

	local tag = wibox.widget {
		{
			{
				tags,
				layout = wibox.layout.fixed.horizontal,
			},
			widget = wibox.container.margin,
		},
		shape = function(cr,w,h) gears.shape.rounded_rect(cr,w,h,5) end,
		bg = beautiful.bar,
		widget = wibox.container.background,
	}

	----- Set up the BAR -----
	
	s.bar = awful.wibar {
		position = 'top',
		width = s.geometry.width, -- dpi(200),
		height = dpi(60),
		screen = s,
		bg = beautiful.bar .. "00",
		visible = true,
		--shape = function(cr,w,h) gears.shape.rounded_rect(cr,w,h,10) end,
	}


	s.bar:setup {
		{
			{
				tag,
				layout = wibox.layout.fixed.horizontal,
			},

			--[[{
				{
					task,
				layout = wibox.layout.align.horizontal,
				},
				halign = 'left',
				widget = wibox.container.place,
		        },--]]	
			nil,
			{
				info,
				layout = wibox.layout.fixed.horizontal,
			},
			layout = wibox.layout.align.horizontal,
		},
	margins = dpi(8),
	widget = wibox.container.margin,
	} -- Tips: Read/Write the codes from bottom for :setup or widget_template

end)
