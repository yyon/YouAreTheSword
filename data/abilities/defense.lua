local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local DefenseAbility = Ability:subclass("DefenseAbility")

function DefenseAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Defense", 20000, "shield", 3000, 10000, true, "casting")
	self.heals = true
end

function DefenseAbility:doability()
	local tox, toy = self:gettargetpos()
	self.target = self.entitydata:getclosestentity(tox, toy, false, nil, true)

	Effects.DefenseEffect:new(self.target)
	sol.audio.play_sound("zap2")

	self:finish()
end

return DefenseAbility
