local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local TauntAbility = Ability:subclass("TauntAbility")

local Effects = require "enemies/effect"

function TauntAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Taunt", 20000, "taunt", 3000, 10000, true, "casting")
	self.nonpc = true
	self.stats = [[Taunt 20s]]
	self.desc = [[All enemies will try to attack target]]
end

function TauntAbility:doability()
	local tox, toy = self:gettargetpos()
	self.target = self.entitydata:getclosestentity(tox, toy, nil, nil, true)

	Effects.TauntEffect:new(self.target, 20000)
	sol.audio.play_sound("zap2")

	self:finish()
end

return TauntAbility
