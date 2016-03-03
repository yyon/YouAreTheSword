local class = require "middleclass"
Ability = require "abilities/ability"

TransformAbility = Ability:subclass("TransformAbility")

function TransformAbility:initialize(entitydata, transform)
	Ability.initialize(self, entitydata, "transform", 0, 1000, 10000, true, "casting")

	self.transform = transform
end

function TransformAbility:doability()
	self.entitydata.entity.swordtransform = self.transform

	self:finish()
end

function TransformAbility:onfinish()
end

return TransformAbility
