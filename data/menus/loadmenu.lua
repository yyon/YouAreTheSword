local class = require("middleclass")
local nofile = require("menus/nofile")

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

  self.buttons.load1_button = menubutton(self, center_x, y, 600, 60, "Save 1", function() self:loadfile(1) end)
  y = y + 70
  self.buttons.load2_button = menubutton(self, center_x, y, 600, 60, "Save 2", function() self:loadfile(2) end)
  y = y + 70
  self.buttons.load3_button = menubutton(self, center_x, y, 600, 60, "Save 3", function() self:loadfile(3) end)
  y = y + 70
  self.buttons.exit_button = menubutton(self, center_x, y, 600, 60, "Exit", function() self:finish() end)

end

function dialog:loadfile(file)
  if saveexists(file) then
	function self:on_finished() end
	sol.menu.stop(self)
    loadfrom(file)
  else
    self:launchsubmenu(nofile)
  end
end

function dialog:launchsubmenu(menu)
	sol.menu.stop(self)
	local submenu = menu:new()
	local oldonfinished = submenu.on_finished
	function submenu.on_finished()
		oldonfinished()
		sol.menu.start(game, dialog:new())
	end
	sol.menu.start(game, submenu)
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
