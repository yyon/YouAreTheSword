local entity = ...

local Effects = require "enemies/effect"

local math = require "math"

sol.main.load_file("entities/projectile")(entity)

local speed = 1000
local xs, ys, xe, ye
local returned = 0

function entity:on_created()
	self:set_optimization_distance(0)
end

function entity:getdamage()
  local aspects = {}
  aspects.knockback = 100
  aspects.fromentity = self
  local damage = 0.5
  return damage, aspects
end

function entity:getspritename()
  return "abilities/boomerang"
end

function entity:getspeed()
	return speed
end

function entity:onhit()
	sol.audio.play_sound("arrow")
end

function entity:getmaxdist()
	return 500
end

function entity:onstart()
--	xs, ys = self.movement:get_xy()
--	print(xs, ys)
end

function entity:finish()
	self.movement:stop()
--	if returned == 1 then
--		self:remove()
--	end
--	self:start(self.ability, xs, ys)
--	returned = 1
	if self.ability.entitydata.entity == nil then
		self:remove()
		return
	end
	
	self.collided = {} -- allow 2x hit
	
	local movement = sol.movement.create("target")
	movement:set_target(self.ability.entitydata.entity)
	movement:set_speed(self:getspeed())
	movement:set_ignore_obstacles(true)
	movement:start(self)
	
	function movement.on_position_updated(movement)
		if self.ability.entitydata.entity == nil then
			self:remove()
			return
		end
		local d = self:get_distance(self.ability.entitydata.entity)
		if d < 40 then
			self:remove()
			return
		end
	end
	function movement.on_obstacle_reached(movement)
		self:remove()
	end
	function movement.on_finished(movement)
		self:remove()
	end
end