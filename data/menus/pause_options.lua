local class = require("middleclass")

require "scripts/inputhandler"

local math = require "math"

local lineify = require("menus/lineify")
local createbox = require "menus/drawbox"

local dialog = class("dialog")

local keylistener = class("keylistener")

function dialog:initialize(game)
  inputhandler:new(self)

  self.game = game
  local w, h = sol.video.get_quest_size()
	self.screenw, self.screenh = w, h
	self.w, self.h = self.screenw, self.screenh
  self.surface = sol.surface.create(self.w, self.h)

  self.buttons = {}

  self.buttons.resume_button = menubutton(self, center_x, center_y, 50, 30, selection_menu.options.resume, function() pause:on_finished() end)
  self.buttons.save_button = menubutton(self, center_x, center_y - 50, 50, 30, selection_menu.options.save, nil)
  self.buttons.load_button = menubutton(self, center_x, center_y - 100, 50, 30, selection_menu.options.load, nil)
  self.buttons.options_button = menubutton(self, center_x, center_y - 150, 50, 30, selection_menu.options.options, nil)
  self.buttons.quit_button = menubutton(self, center_x, center_y - 200, 50, 30, selection_menu.options.quit, nil)
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
