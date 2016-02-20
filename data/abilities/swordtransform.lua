local class = require "middleclass"
Ability = require "abilities/ability"

TransformAbility = Ability:subclass("TransformAbility")

function TransformAbility:initialize(entitydata, transform)
	Ability.initialize(self, entitydata, "transform", 0, 1000, 3000, true)
	
	self.transform = transform
end

function TransformAbility:doability()
	self.entitydata.entity.swordtransform = self.transform
	
	self:finish()
end

function TransformAbility:cancel()
	self:finish()
end

function TransformAbility:finish()
	self:finishability()
end

return TransformAbility