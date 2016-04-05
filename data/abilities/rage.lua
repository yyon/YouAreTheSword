local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local RageAbility = Ability:subclass("Rage")

local Effects = require "enemies/effect"

function RageAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Rage", 1000, "rage", 1000, 10000, true, "casting")
end

function RageAbility:doability()
	local rageeffect = Effects.RageEffect(self.entitydata)

	self:finish()
end


return RageAbility