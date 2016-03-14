local class = require "middleclass"
Ability = require "abilities/ability"

TauntAbility = Ability:subclass("TauntAbility")

local Effects = require "enemies/effect"

function TauntAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Taunt", 20000, "taunt", 0, 0, true, "casting")
	self.nonpc = true
end

function TauntAbility:doability()
	tox, toy = self.entitydata:gettargetpos()
	self.target = self.entitydata:getclosestentity(tox, toy)
	
	Effects.TauntEffect:new(self.target, 20000)
	
	self:finish()
end

return TauntAbility
