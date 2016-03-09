local class = require "middleclass"
Ability = require "abilities/ability"

NormalAbility = Ability:subclass("NormalAbility")
-- a replacement for sword ability for classes that don't have that animation

function NormalAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "NormalAbility", 50, 500, 0, true, "sword")
end

function NormalAbility:doability(tox, toy)
	self.entitydata:setanimation("sword")
	
	for entitydata in self.entitydata:getotherentities() do
		d = self.entitydata.entity:get_distance(entitydata.entity)
		if d < 100 then
			if self.entitydata.entity:get_direction4_to(entitydata.entity) == self.entitydata:getdirection() or d<10 then
				print("HIT")
				self:dodamage(entitydata, 1, {})
			end
		end
	end
	
	self:finish()
end

return NormalAbility