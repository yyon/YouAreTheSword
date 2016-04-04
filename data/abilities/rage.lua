local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local RageAbility = Ability:subclass("Rage")

local Effects = require "enemies/effect"

function RageAbility:doability()

	self:finish()
end


return RageAbility