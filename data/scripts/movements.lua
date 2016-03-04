local class = require "middleclass"
local math = require "math"

straightmovement = class("straightmovement")

function straightmovement:initialize()
	self.speed = 100 -- px/sec
	self.wait = 10
	self.angle = 0
	self.maxdist = -1
	self.targetx = nil
	self.targety = nil
end

function straightmovement:set_speed(newspeed)
	self.speed = newspeed*2
end

function straightmovement:set_angle(newangle)
	self.angle = -newangle
end

function straightmovement:set_max_distance(newmaxdist)
	self.maxdist = newmaxdist
end

function straightmovement:set_target(x, y)
	self.targetx, self.targety = x, y
end

function straightmovement:set_smooth()
end

function straightmovement:start(entity)
	self.entity = entity
	
	if self.targetx ~= nil then
		self.angle = self.entity:get_angle(self.targetx, self.targety)
		self.maxdist = self.entity:get_distance(self.targetx, self.targety)
	end
	
	self.orig_x, self.orig_y = self.entity:get_position()
	self.x, self.y = self.orig_x, self.orig_y
	self.actualmovement = self.speed * self.wait / 1000
	self.dx, self.dy = math.cos(self.angle) * self.actualmovement, math.sin(self.angle) * self.actualmovement
	self:tick()
end

function straightmovement:tick()
	x, y = self.x, self.y --self.entity:get_position()
	dx = self.dx
	dy = self.dy
	if self.entity:test_obstacles(dx, dy) then
		self:on_obstacle_reached()
	else
		x = x + self.dx
		y = y + self.dy
		self.x, self.y = x, y
		self.entity:set_position(x, y)
		
		self:on_position_changed()
	
		if self.maxdist == -1 or self.entity:get_distance(self.orig_x, self.orig_y) <= self.maxdist then
			sol.timer.start(self.entity, self.wait, function() self:tick() end)
		else
			self:on_finished()
		end
	end
end

function straightmovement:on_obstacle_reached()
	self:on_finished()
end

function straightmovement:on_position_changed()
end

function straightmovement:on_finished()
end

return {straightmovement=straightmovement}