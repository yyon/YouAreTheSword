local class = require("middleclass")
local keyconfmenu = require "menus/keyconfig"
local loadmenu = require "menus/loadmenu"


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
	local y = center_y - h/4

  self.buttons = {}

  self.buttons.continue_button = menubutton(self, center_x, y, 600, 60, "Continue", function() self:continue() end)
	y = y + 70
  self.buttons.new_button = menubutton(self, center_x, y, 600, 60, "Start new game", function() self:start_new() end)
	y = y + 70
  self.buttons.load_button = menubutton(self, center_x, y, 600, 60, "Load game", function() self:start_load() end)
	y = y + 70
  self.buttons.options_button = menubutton(self, center_x, y, 600, 60, "Options", function() self:start_config() end)
	y = y + 70
  self.buttons.quit_button = menubutton(self, center_x, y, 600, 60, "Quit", function () sol.main.exit() end)
end

function dialog:start_config()
	self:launchsubmenu(keyconfmenu)
end

function dialog:start_load()
	self:launchsubmenu(loadmenu)
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


function dialog:start_new()
	sol.menu.stop(self)
	loadfrom(0)
end

function dialog:continue()
	sol.menu.stop(self)
	load()
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
