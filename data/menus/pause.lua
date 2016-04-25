local class = require("middleclass")
local keyconfmenu = require "menus/keyconfig"
local savemenu = require "menus/savemenu"
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

  self.buttons.resume_button = menubutton(self, center_x, y, 600, 60, "Resume", function() self:finish() end)
	y = y + 70
  self.buttons.save_button = menubutton(self, center_x, y, 600, 60, "Save", function() self:start_save() end)
	y = y + 70
  self.buttons.load_button = menubutton(self, center_x, y, 600, 60, "Load", function() self:start_load() end)
	y = y + 70
  self.buttons.restart_level_button = menubutton(self, center_x, y, 600, 60, "Restart Level", function() self:restart_level() end)
  y = y + 70
  self.buttons.restart_game_button = menubutton(self, center_x, y, 600, 60, "Restart Game", function() self:restart_game() end)
  y = y + 70
  self.buttons.options_button = menubutton(self, center_x, y, 600, 60, "Options", function() self:start_config() end)
	y = y + 70
  self.buttons.quit_button = menubutton(self, center_x, y, 600, 60, "Quit", function () sol.main.exit() end)
end

function dialog:start_config()
	self:launchsubmenu(keyconfmenu)
end

function dialog:start_save()
	self:launchsubmenu(savemenu)
end

function dialog:start_load()
	self:launchsubmenu(loadmenu)
end

function dialog:restart_level()
  function self:on_finished() end
	sol.menu.stop(self)
  load()
end

function dialog:restart_game()
  function self:on_finished() end
	sol.menu.stop(self)
  loadfrom(0)
end

function dialog:launchsubmenu(menu)
	local myoldonfinished = self.on_finished
	function self:on_finished() end
	
	sol.menu.stop(self)
	local submenu = menu:new()
	local oldonfinished = submenu.on_finished
	function submenu.on_finished(submenu)
		oldonfinished()
		local newdialog = dialog:new()
		newdialog.on_finished = myoldonfinished
		sol.menu.start(game, newdialog)
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
  game:set_paused(false)
  sol.menu.stop(self)
end


return dialog
