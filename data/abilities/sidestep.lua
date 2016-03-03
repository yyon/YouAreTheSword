local class = require "middleclass"
Ability = require "abilities/ability"

SidestepAbility = Ability:subclass("SidestepAbility")
-- a replacement for sword ability for classes that don't have that animation

RANGE = 300

function SidestepAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "NormalAbility", RANGE, 0, 50, true)
end

function SidestepAbility:doability()
	print("START")
	tox, toy = self.entitydata:gettargetpos()
	
	if self.entitydata.entity:get_distance(tox, toy) > RANGE then
		x, y = self.entitydata.entity:get_position()
		d = self.entitydata.entity:get_distance(tox, toy)
		vx, vy = tox - x, toy - y
		vx, vy = vx / d * RANGE, vy / d * RANGE
		tox, toy = x + vx, y + vy
	end
	
	self.entitydata:setanimation("walking")
	
	self.movement = sol.movement.create("target")
	self.movement:set_speed(1000)
	self.movement:set_target(tox, toy)
	self.movement:set_smooth(true)
	self.movement:start(self.entitydata.entity)
	
	function self.movement.on_finished(movement)
		self:finish()
	end
	function self.movement.on_obstacle_reached(movement)
		self:finish()
	end
end

function SidestepAbility:oncancel()
	self.movement:stop()
end

function SidestepAbility:onfinish()
end

return SidestepAbility
