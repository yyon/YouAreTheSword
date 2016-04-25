local class = require("middleclass")
local confirmation = require("menus/confirmation")

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
	local y = center_y - 140

  self.buttons = {}

  self.buttons.save1_button = menubutton(self, center_x, y, 600, 60, "Save 1", function() self:pressed_button(1) end)
  y = y + 70
  self.buttons.save2_button = menubutton(self, center_x, y, 600, 60, "Save 2", function() self:pressed_button(2) end)
  y = y + 70
  self.buttons.save3_button = menubutton(self, center_x, y, 600, 60, "Save 3", function() self:pressed_button(3) end)
  y = y + 70
  self.buttons.exit_button = menubutton(self, center_x, y, 600, 60, "Exit", function() self:finish() end)

end

function dialog:pressed_button(button_num)
  saveto(button_num)
  self:launchsubmenu(confirmation)
end

function dialog:launchsubmenu(menu)
	local myoldonfinished = self.on_finished
	function self:on_finished() end

	sol.menu.stop(self)
	local submenu = menu:new(self.game)
	local oldonfinished = submenu.on_finished
	function submenu.on_finished(submenu)
		oldonfinished()
		local newdialog = dialog:new(self.game)
		newdialog.on_finished = myoldonfinished
		sol.menu.start(self.game, newdialog)
	end
	sol.menu.start(self.game, submenu)
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
