local class = require "middleclass"
Ability = require "abilities/ability"

SidestepAbility = Ability:subclass("SidestepAbility")
-- a replacement for sword ability for classes that don't have that animation

function SidestepAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "NormalAbility", 300, 0, 50, true)
end

function SidestepAbility:doability()
	tox, toy = self.entitydata:gettargetpos()
	tox, toy = self:withinrange(tox, toy)
	
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
