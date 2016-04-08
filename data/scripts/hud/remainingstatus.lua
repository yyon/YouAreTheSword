local class = require("middleclass")

local panel = class("panel")

local entitydata = require "enemies/entitydata"

local math = require "math"

local lineify = require "menus/lineify"

function panel:initialize(game)
  	self.game = game
  	self.surface = sol.surface.create(64, 64)
  	self.dst_x = 0
  	self.dst_y = 0
	self.stage = 0
  	self.back = sol.surface.create("hud/status.png")
	self.sprites = {}
end

function panel:on_started()
  	self:check()
end

function panel:check()
	self:rebuild_surface()
	
  	sol.timer.start(self, 100, function()
    		self:check()
  	end)
end


function panel:rebuild_surface()
	if self.game:is_paused() or self.game:is_suspended() then return end

  	self.surface:clear()
	self.back:draw(self.surface, 0, 0)

	local hero = self.game:get_hero().entitydata
	if hero ~= nil then
		self.enemiesremaining = hero:getremainingmonsters()
	end
	
	if self.enemiesremaining ~= nil then
		local w, h = self.surface:get_size()
		lineify.rendertext(self.surface, tostring(self.enemiesremaining), "LiberationMono-Bold", 25, {255,255,255}, true, w/2, h/2, true, true)

		lineify.rendertext(self.surface, "enemies", "LiberationMono-Regular", 10, {255,255,255}, true, w/2, h/6, true, true)
		lineify.rendertext(self.surface, "remaining", "LiberationMono-Regular", 10, {255,255,255}, true, w/2, 5*h/6, true, true)
	end
end

function panel:set_dst_position(x, y)
  	self.dst_x = x
  	self.dst_y = y
	local w, h = self.surface:get_size()
	self.dst_x = self.dst_x - w
end

function panel:on_draw(dst_surface)
  	local x, y = self.dst_x, self.dst_y
  	local width, height = dst_surface:get_size()
  	if x < 0 then
    		x = width + x
  	end
  	if y < 0 then
    		y = height + y
  	end
	self.surface:draw(dst_surface, x, y)
end

return panel
