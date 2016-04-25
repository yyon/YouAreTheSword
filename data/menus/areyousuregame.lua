local class = require("middleclass")

require "scripts/inputhandler"

local math = require "math"

local lineify = require("menus/lineify")
local createbox = require "menus/drawbox"

local dialog = class("dialog")

function dialog:initialize(game, title)
  inputhandler:new(self)

  self.game = game
  self.title = title
  local w, h = sol.video.get_quest_size()
	self.screenw, self.screenh = w, h
	self.w, self.h = self.screenw, self.screenh
	center_x, center_y = w/2, h/2
  self.surface = sol.surface.create(self.w, self.h)
	local y = center_y - 70

  self.buttons = {}

  self.buttons.sure_button = menubutton(self, center_x, y, 600, 60, "Are you sure?", function() self:rebuild_surface() end)
  y = y + 70
  self.buttons.yes_button = menubutton(self, center_x, y, 600, 60, "Yes", function() self:yes() end)
  y = y + 70
  self.buttons.no_button = menubutton(self, center_x, y, 600, 60, "No", function() self:no() end)

end

function dialog:yes()
  function self:on_finished() end
  sol.menu.stop(self)
	if self.title ~= nil then sol.menu.stop(self.title) end
  loadfrom(0)
end

function dialog:no()
  sol.menu.stop(self)
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
