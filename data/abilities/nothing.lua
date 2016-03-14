local class = require "middleclass"
Ability = require "abilities/ability"

NothingAbility = Ability:subclass("NothingAbility")

local Effects = require "enemies/effect"

function NothingAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Nothing", 0, "nothing", 0, 0, true)
	self.nonpc = true
end

function NothingAbility:doability()
end

return NothingAbility
