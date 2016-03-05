local class = require "middleclass"
Ability = require "abilities/ability"
require "scripts/movementaccuracy"

TeleportAbility = Ability:subclass("TeleportAbility")

function TeleportAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Teleporter", 600, 0, 2550, true)
end

function TeleportAbility:doability()
	tox, toy = self.entitydata:gettargetpos()
	tox, toy = self:withinrange(tox, toy)
	
	self.entitydata.entity:set_position(tox, toy)

	self:finish()
end

return TeleportAbility