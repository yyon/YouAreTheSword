local class = require("middleclass")

require "scripts/inputhandler"

local math = require "math"

local lineify = require("menus/lineify")
local createbox = require "menus/drawbox"

local dialog = class("dialog")

function dialog:initialize(game, choicetext1, choicefunction1, choicetext2, choicefunction2)
	inputhandler:new(self)

	local w, h = sol.video.get_quest_size()
	self.screenw, self.screenh = w, h
  	self.game = game
	self.w, self.h = self.screenw, self.screenh
  	self.surface = sol.surface.create(self.w, self.h)
	
	self.buttons = {}
	
	self.buttons.choice1 = menubutton(self, w/2, h/2-35, 600, 60, choicetext1, function() self:finish(choicefunction1) end)
	self.buttons.choice2 = menubutton(self, w/2, h/2+35, 600, 60, choicetext2, function() self:finish(choicefunction2) end)
	
	self:refresh()
end

function dialog:refresh()
	self:rebuild_surface()
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

function dialog:finish(funct)
	if game.dialog ~= nil then
		if game.dialog.isshowingdialog then
			game.dialog:finish()
		end
	end
	sol.menu.stop(self)
	game.dontshowpausemenu = false
	game:set_paused(false)
	if funct ~= nil then
		funct()
	end
end

return dialog
