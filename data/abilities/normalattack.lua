local class = require "middleclass"
Ability = require "abilities/ability"

NormalAbility = Ability:subclass("NormalAbility")
-- a replacement for sword ability for classes that don't have that animation

function NormalAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "NormalAbility", 50, 500, 0, true)
end

function NormalAbility:doability(tox, toy)
	print("NORMAL")
	for entitydata in self.entitydata:getotherentities() do
		d = self.entitydata.entity:get_distance(entitydata.entity)
		if d < 50 then
			if self.entitydata.entity:get_direction4_to(entitydata.entity) == self.entitydata:getdirection() then
				print("HIT")
				self:dodamage(entitydata, 1, {})
			end
		end
	end
	
	self:finish()
end

return NormalAbility
