local class = require("middleclass")

local dialog = class("dialog")

require "scripts/inputhandler"

local math = require "math"

function dialog:initialize(game)
	local w, h = sol.video.get_quest_size()
	self.screenw, self.screenh = w, h
  	self.game = game
	self.w, self.h = self.screenw, self.screenh
  	self.surface = sol.surface.create(self.w, self.h)
	
	inputhandler:new(self)
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
end

function dialog:on_draw(dst_surface)
	self.surface:draw(dst_surface, self.dst_x, self.dst_y)
end

function dialog:on_key_pressed(key)
	if key == "a" then
		game.dontshowpausemenu = false
		game:set_paused(false)
		sol.menu.stop(self)
	end
end

return dialog
