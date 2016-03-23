local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local TauntAbility = Ability:subclass("TauntAbility")

local Effects = require "enemies/effect"

function TauntAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Taunt", 20000, "taunt", 0, 10000, true, "casting")
	self.nonpc = true
end

function TauntAbility:doability()
	local tox, toy = self:gettargetpos()
	self.target = self.entitydata:getclosestentity(tox, toy)

	Effects.TauntEffect:new(self.target, 20000)
	sol.audio.play_sound("zap2")

	self:finish()
end

return TauntAbility
