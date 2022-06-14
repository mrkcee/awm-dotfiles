local gears = require("gears")
local awful = require("awful")
local wibox = require "wibox"
local beautiful = require("beautiful")
local gfs = require("gears.filesystem")
require("awful.autofocus")

----- Menu -----

mainmenu = awful.menu({ 
	items = {
		{ "Refresh", awesome.restart }, 
		{ "Quit", function()
			awesome.quit()
		end},
		{ "Power", function()
			awesome.emit_signal("ui::powermenu:open")
		end},
	},
})

