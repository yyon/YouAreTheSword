local class = require "middleclass"
local Ability = require "abilities/ability"

local NothingAbility = Ability:subclass("NothingAbility")

local Effects = require "enemies/effect"

function NothingAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Nothing", 0, "nothing", 0, 100000, true)
	self.nonpc = true
	
	self.desc = [[Does nothing]]
end

function NothingAbility:doability()
	self:finish()
end

return NothingAbility
