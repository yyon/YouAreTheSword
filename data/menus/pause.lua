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
	local y = center_y

  self.buttons = {}

  self.buttons.resume_button = menubutton(self, center_x, y, 600, 60, "Resume", function() self:finish() end)
	y = y - 70
  self.buttons.save_button = menubutton(self, center_x, y, 600, 60, "Save", nil)
	y = y - 70
  self.buttons.load_button = menubutton(self, center_x, y, 600, 60, "Load", nil)
	y = y - 70
  self.buttons.options_button = menubutton(self, center_x, y, 600, 60, "Options", nil)
	y = y - 70
  self.buttons.quit_button = menubutton(self, center_x, y, 600, 60, "Quit", nil)
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
  game:set_paused(false)
  sol.menu.stop(self)
end


return dialog
