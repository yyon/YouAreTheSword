local class = require "middleclass"
Ability = require "abilities/ability"
require "scripts/movementaccuracy"

TeleportAbility = Ability:subclass("TeleportAbility")

function TeleportAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Teleporter", 300, 0, 500, true)
end



function TeleportAbility:doability()
	tox, toy = self.entitydata:gettargetpos()
	tox, toy = self:withinrange(tox, toy)
	
--	self.entitydata:setanimation("walking")
	
--	local angle = self.entitydata.entity:get_angle(tox, toy)
--	local dist = self.entitydata.entity:get_distance(tox, toy)
	
--	self.movement = sol.movement.create("straight")
--	self.movement:set_speed(1000)
--	self.movement:set_target(tox, toy)
--	self.movement:set_angle(angle)
--	self.movement:set_max_distance(dist)
--	self.movement:start(self.entitydata.entity)

	self.entitydata.entity:set_position(tox, toy)
	
	self:finish()
	
--	movementaccuracy(self.movement, angle, self.entitydata.entity)
end

function TeleportAbility:oncancel()
end

function TeleportAbility:onfinish()
end

return TeleportAbility