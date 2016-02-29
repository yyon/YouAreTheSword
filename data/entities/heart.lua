local entity = ...

Effects = require "enemies/effect"

function entity:on_created()
end

function entity:start(ability, target)
	self.ability = ability
	self:set_optimization_distance(0)
	
	self.target = target
	
	self.heart_sprite = self:create_sprite("abilities/heart")
	self.heart_sprite:set_paused(false)

	self.timer = Effects.SimpleTimer:new(self.ability.entitydata, 2000, function() self:remove() end)

	dist = self:get_distance(tox, toy)
	if dist > RANGE then
		dist = RANGE
	end

	local movement = sol.movement.create("target")
	movement:set_speed(600)
	movement:set_target(target.entity)
	movement:set_smooth(true)
	movement:start(self)
	function movement.on_finished(movement)
		self:heal()
		self:finish()
	end
	function movement.on_obstacle_reached(movement)
		self:finish()
	end
end

function entity:heal()
	self.ability:heal(self.target)
end

function entity:finish()
	self.timer:stop()
	self:remove()
end