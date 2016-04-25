local class = require("middleclass")

require "scripts/inputhandler"

local math = require "math"

local lineify = require("menus/lineify")
local createbox = require "menus/drawbox"

local dialog = class("dialog")

function dialog:initialize(game)
  inputhandler:new(self)

  self.game = game
  local w, h = sol.video.get_quest_size()
	self.screenw, self.screenh = w, h
	self.w, self.h = self.screenw, self.screenh
	center_x, center_y = w/2, h/2
  self.surface = sol.surface.create(self.w, self.h)
	local y = center_y - h/2 + 70

  self.buttons = {}

  self.buttons.save1_button = menubutton(self, center_x, y, 600, 60, "Save 1", function() saveto(1) end)
  y = y + 70
  self.buttons.save2_button = menubutton(self, center_x, y, 600, 60, "Save 2", function() saveto(2) end)
  y = y + 70
  self.buttons.save3_button = menubutton(self, center_x, y, 600, 60, "Save 3", function() saveto(3) end)

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
  sol.menu.stop(self)
end


return dialog
