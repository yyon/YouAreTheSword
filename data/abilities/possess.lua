local class = require "middleclass"
Ability = require "abilities/ability"

PossessAbility = Ability:subclass("PossessAbility")

local Effects = require "enemies/effect"

function PossessAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Possess", 20000, "possess", 0, 500, true, "casting")
end

function PossessAbility:doability()
	tox, toy = self.entitydata:gettargetpos()
	self.target = self.entitydata:getclosestentity(tox, toy, true)
	
	if not self.target.entity.ishero then
		Effects.PossessEffect:new(self.target, self.entitydata.team, 20000)
	end
	
	self:finish()
end

return PossessAbility