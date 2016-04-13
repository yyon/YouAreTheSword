local class = require("middleclass")

require "scripts/inputhandler"

local math = require "math"

local lineify = require("menus/lineify")
local createbox = require "menus/drawbox"

local dialog = class("dialog")

local keylistener = class("keylistener")

function dialog:initialize(game)
	inputhandler:new(self)
	
	local w, h = sol.video.get_quest_size()
	self.screenw, self.screenh = w, h
  	self.game = game
	self.w, self.h = self.screenw, self.screenh
  	self.surface = sol.surface.create(self.w, self.h)
	
	self.buttons = {}
	self.buttons.upbutton1 = menubutton(self, w/2 - 305, 40, 600, 60, "", function() self:config("test", 1) end)
	self.buttons.upbutton2 = menubutton(self, w/2 + 305, 40, 600, 60, "", function() self:config("test", 2) end)
	self.buttons.exitbutton = menubutton(self, w/2, 110, 600, 60, "exit", function() self:finish() end)
end

function dialog:refresh()
	
	self:rebuild_surface()
end

function dialog:config(type, button)
	local b = self.buttons[button]
	local keylistenermenu = keylistener:new(game, self, type, b)
	sol.menu.start(game, keylistenermenu)
end

function dialog:on_started()
  	self:check()
end

function dialog:check()
  	self:rebuild_surface()
  	sol.timer.start(self, 500, function()
    		self:check()
  	end)
end

function dialog:rebuild_surface()
	self.surface:clear()
	for _, button in pairs(self.buttons) do
		button:draw(self.surface)
	end
end

function dialog:on_draw(dst_surface)
	self.surface:draw(dst_surface, self.dst_x, self.dst_y)
end

function dialog:finish()
	game.dontshowpausemenu = false
	game:set_paused(false)
	sol.menu.stop(self)
end

function keylistener:initialize(game, parentmenu, type, num)
	inputhandler:new(self)
	
	self.parentmenu = parentmenu
	self.type = type
	self.num = num
	
	local w, h = sol.video.get_quest_size()
	self.screenw, self.screenh = w, h
  	self.game = game
	self.w, self.h = self.screenw, self.screenh
  	self.surface = sol.surface.create(self.w, self.h)
	
	self.box = createbox(800, 600, true, false)
	lineify.rendertext(self.box, "Press key or mouse button\nPress delete to clear", "LiberationMono-Regular", 25, {255,255,255}, true, 400, 300, true, true)
	
	print "Key listener"
end

function keylistener:on_started()
  	self:check()
end

function keylistener:check()
  	self:rebuild_surface()
  	sol.timer.start(self, 500, function()
    		self:check()
  	end)
end

function keylistener:rebuild_surface()
	self.surface:clear()
	self.box:draw(self.surface, self.screenw/2 - 400, self.screenh/2 - 300)
end

function keylistener:on_draw(dst_surface)
	self.surface:draw(dst_surface, self.dst_x, self.dst_y)
end

function keylistener:onkey(key)
	self:finish(key)
end
function keylistener:onmouse(button)
	button = button .. "_mouse"
	self:finish(button)
end

function keylistener:finish(key)
	print(key)
	sol.menu.stop(self)
	self.parentmenu:refresh()
end


return dialog
