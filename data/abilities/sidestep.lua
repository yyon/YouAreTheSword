local class = require "middleclass"
Ability = require "abilities/ability"
require "scripts/movementaccuracy"

SidestepAbility = Ability:subclass("SidestepAbility")
-- a replacement for sword ability for classes that don't have that animation

function SidestepAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Sidestep", 300, "sidestep", 0, 50, true)
end

function SidestepAbility:doability()
	tox, toy = self.entitydata:gettargetpos()
	tox, toy = self:withinrange(tox, toy)
	
	self.entitydata:setanimation("walking")
	
	local angle = self.entitydata.entity:get_angle(tox, toy)
	local dist = self.entitydata.entity:get_distance(tox, toy)
	
	self.movement = sol.movement.create("straight")
	self.movement:set_speed(1000)
--	self.movement:set_target(tox, toy)
	self.movement:set_angle(angle)
	self.movement:set_max_distance(dist)
	self.movement:start(self.entitydata.entity)
	
	function self.movement.on_finished(movement)
		self:finish()
	end
	function self.movement.on_obstacle_reached(movement)
		self:finish()
	end
	
	movementaccuracy(self.movement, angle, self.entitydata.entity)
end

function SidestepAbility:oncancel()
	self.movement:stop()
end

function SidestepAbility:onfinish()
end

return SidestepAbility
